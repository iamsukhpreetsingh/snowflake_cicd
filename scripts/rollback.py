import os
import sys
import snowflake.connector


def rollback(backup_db: str):
    db = os.environ['SNOWFLAKE_DATABASE']

    conn = snowflake.connector.connect(
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        account=os.environ['SNOWFLAKE_ACCOUNT'],
        warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
        role=os.environ['SNOWFLAKE_ROLE'],
    )
    cursor = conn.cursor()

    print(f"⏪ Rolling back {db} to snapshot {backup_db}...")
    cursor.execute(f"DROP DATABASE IF EXISTS {db}")
    cursor.execute(f"CREATE DATABASE {db} CLONE {backup_db}")
    print(f"✅ {db} restored to pre-deploy state.")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    rollback(sys.argv[1])