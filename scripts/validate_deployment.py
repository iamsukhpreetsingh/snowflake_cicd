import os
import re
import sys
import snowflake.connector


def extract_object_name(sql_text: str):
    """Pull schema.object out of an IDENTIFIER('{{ db }}.SCHEMA.OBJECT') pattern."""
    match = re.search(
        r"IDENTIFIER\(\s*'\{\{\s*db\s*\}\}\.([A-Za-z0-9_]+\.[A-Za-z0-9_]+)'\s*\)",
        sql_text,
        re.IGNORECASE,
    )
    return match.group(1) if match else None


def validate(since_timestamp: str):
    db = os.environ['SNOWFLAKE_DATABASE']

    try:
        conn = snowflake.connector.connect(
            user=os.environ['SNOWFLAKE_USER'],
            password=os.environ['SNOWFLAKE_PASSWORD'],
            account=os.environ['SNOWFLAKE_ACCOUNT'],
            warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
            database=db,
            role=os.environ['SNOWFLAKE_ROLE'],
        )
    except Exception as e:
        print(f"❌ Could not connect to Snowflake: {e}")
        sys.exit(1)

    cursor = conn.cursor()
    errors = []

    try:
        cursor.execute(f"""
            SELECT SCRIPT, SCRIPT_TYPE, STATUS
            FROM {db}.PUBLIC.CHANGE_HISTORY
            WHERE INSTALLED_ON >= TO_TIMESTAMP_TZ(%s || ' +00:00')
              AND STATUS = 'Success'
            ORDER BY INSTALLED_ON
        """, (since_timestamp,))
        recent_scripts = cursor.fetchall()

        if not recent_scripts:
            print("ℹ️  No new scripts were applied in this run — nothing to validate.")
        else:
            print(f"Found {len(recent_scripts)} script(s) applied in this run, validating objects...")
            for script_name, script_type, status in recent_scripts:
                script_path = os.path.join("objects", script_name)
                if not os.path.exists(script_path):
                    errors.append(f"Could not find local file for {script_name} to verify — skipped.")
                    continue

                with open(script_path, "r", encoding="utf-8") as f:
                    sql_text = f.read()

                obj = extract_object_name(sql_text)
                if not obj:
                    print(f"  ⚠️  {script_name}: no recognizable object pattern, skipping direct check.")
                    continue

                fq_name = f"{db}.{obj}"
                try:
                    cursor.execute(f"SELECT COUNT(*) FROM {fq_name} LIMIT 1")
                    print(f"  ✅ {script_name} → {fq_name}")
                except Exception as e:
                    errors.append(f"Object {fq_name} (from {script_name}) check failed: {e}")
    except Exception as e:
        errors.append(f"Could not query change history: {e}")

    try:
        cursor.execute(f"""
            SELECT COUNT(*) FROM TABLE({db}.INFORMATION_SCHEMA.TASK_HISTORY(
                SCHEDULED_TIME_RANGE_START => DATEADD(minute, -5, CURRENT_TIMESTAMP())
            ))
            WHERE STATE = 'FAILED'
        """)
        fail_count = cursor.fetchone()[0]
        if fail_count > 0:
            errors.append(f"Found {fail_count} task failures in the last 5 minutes!")
        else:
            print("✅ No recent task failures.")
    except Exception as e:
        errors.append(f"Task history check failed: {e}")

    cursor.close()
    conn.close()

    if errors:
        print("\n❌ VALIDATION FAILED:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)
    else:
        print("\n✅ All post-deployment validations passed.")


if __name__ == "__main__":
    validate(sys.argv[1])