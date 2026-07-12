import os
import sys
import time
import snowflake.connector


def create_backup():
    db = os.environ['SNOWFLAKE_DATABASE']
    run_id = os.environ.get('GITHUB_RUN_ID', str(int(time.time())))
    backup_db = f"{db}_ROLLBACK_{run_id}"

    conn = snowflake.connector.connect(
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        account=os.environ['SNOWFLAKE_ACCOUNT'],
        warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
        role=os.environ['SNOWFLAKE_ROLE'],
    )
    cursor = conn.cursor()
    cursor.execute(f"CREATE OR REPLACE DATABASE {backup_db} CLONE {db}")
    print(f"✅ Backup created: {backup_db}")
    cursor.close()
    conn.close()

    # Expose to later steps via GITHUB_OUTPUT
    with open(os.environ['GITHUB_OUTPUT'], 'a') as f:
        f.write(f"backup_db={backup_db}\n")


if __name__ == "__main__":
    create_backup()