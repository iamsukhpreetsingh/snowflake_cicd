import os
import time
import snowflake.connector


def get_account_identifier():
    org = os.environ.get('SNOWFLAKE_ORGANIZATION_NAME')
    account = os.environ.get('SNOWFLAKE_ACCOUNT_NAME')
    if org and account:
        return f"{org}-{account}"
    if os.environ.get('SNOWFLAKE_ACCOUNT'):
        return os.environ['SNOWFLAKE_ACCOUNT']
    raise EnvironmentError("Missing Snowflake account identifier env vars.")


def create_backup():
    db = os.environ['SNOWFLAKE_DATABASE']
    run_id = os.environ.get('GITHUB_RUN_ID', str(int(time.time())))
    backup_db = f"{db}_TF_ROLLBACK_{run_id}"

    conn = snowflake.connector.connect(
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        account=get_account_identifier(),
        warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
        role=os.environ['SNOWFLAKE_ROLE'],
    )
    cursor = conn.cursor()
    # CREATE DATABASE ... CLONE requires the source database to already exist.
    # On a first-ever apply (database doesn't exist yet), skip the backup.
    cursor.execute(f"SHOW DATABASES LIKE '{db}'")
    exists = cursor.fetchone() is not None

    if exists:
        cursor.execute(f"CREATE OR REPLACE DATABASE {backup_db} CLONE {db}")
        print(f"✅ Backup created: {backup_db}")
    else:
        backup_db = ""
        print(f"ℹ️  Database {db} does not exist yet — nothing to back up. First apply.")

    cursor.close()
    conn.close()

    with open(os.environ['GITHUB_OUTPUT'], 'a') as f:
        f.write(f"backup_db={backup_db}\n")


if __name__ == "__main__":
    create_backup()