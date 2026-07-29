import os
import sys
import time
import snowflake.connector


def get_account_identifier():
    org = os.environ.get('SNOWFLAKE_ORGANIZATION_NAME')
    account = os.environ.get('SNOWFLAKE_ACCOUNT_NAME')

    if org and account:
        return f"{org}-{account}"

    # Fallback: a single combined SNOWFLAKE_ACCOUNT env var was set directly
    if os.environ.get('SNOWFLAKE_ACCOUNT'):
        return os.environ['SNOWFLAKE_ACCOUNT']

    raise EnvironmentError(
        "Missing Snowflake account identifier: set either "
        "SNOWFLAKE_ORGANIZATION_NAME + SNOWFLAKE_ACCOUNT_NAME, "
        "or SNOWFLAKE_ACCOUNT directly."
    )


def create_backup():
    db = os.environ['SNOWFLAKE_DATABASE']
    run_id = os.environ.get('GITHUB_RUN_ID', str(int(time.time())))
    backup_db = f"{db}_ROLLBACK_{run_id}"

    conn = snowflake.connector.connect(
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        account=get_account_identifier(),
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