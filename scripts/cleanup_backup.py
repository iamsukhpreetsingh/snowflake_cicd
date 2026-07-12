import os
import sys
import snowflake.connector


def cleanup(backup_db: str):
    conn = snowflake.connector.connect(
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        account=os.environ['SNOWFLAKE_ACCOUNT'],
        warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
        role=os.environ['SNOWFLAKE_ROLE'],
    )
    cursor = conn.cursor()
    cursor.execute(f"DROP DATABASE IF EXISTS {backup_db}")
    print(f"🧹 Cleaned up backup snapshot {backup_db}")
    cursor.close()
    conn.close()


if __name__ == "__main__":
    cleanup(sys.argv[1])