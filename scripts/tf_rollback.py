import os
import sys
import snowflake.connector


def get_account_identifier():
    org = os.environ.get('SNOWFLAKE_ORGANIZATION_NAME')
    account = os.environ.get('SNOWFLAKE_ACCOUNT_NAME')
    if org and account:
        return f"{org}-{account}"
    if os.environ.get('SNOWFLAKE_ACCOUNT'):
        return os.environ['SNOWFLAKE_ACCOUNT']
    raise EnvironmentError("Missing Snowflake account identifier env vars.")


def rollback(backup_db: str):
    if not backup_db:
        print("ℹ️  No backup snapshot to roll back to (first-ever apply). Nothing to do.")
        return

    db = os.environ['SNOWFLAKE_DATABASE']

    conn = snowflake.connector.connect(
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        account=get_account_identifier(),
        warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
        role=os.environ['SNOWFLAKE_ROLE'],
    )
    cursor = conn.cursor()
    cursor.execute(f"CREATE OR REPLACE DATABASE {db} CLONE {backup_db}")
    print(f"⏪ Rolled back {db} to snapshot {backup_db}")
    cursor.close()
    conn.close()


if __name__ == "__main__":
    rollback(sys.argv[1] if len(sys.argv) > 1 else "")