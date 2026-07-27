import os
import re
import sys
import tempfile
import subprocess


def preprocess_schemachange_sql(content: str, env_db: str) -> str:
    content = content.replace("{{ db }}", env_db)
    content = content.replace("{{env_var(\"SNOWFLAKE_DATABASE\")}}", env_db)
    content = content.replace("{{env_var('SNOWFLAKE_DATABASE')}}", env_db)
    
    def replace_identifier(match):
        expr = match.group(1)
        parts = re.findall(r"\"([^\"]*)\"", expr)
        if not parts:
            parts = re.findall(r"'([^']*)'", expr)
        return ".".join(parts) if parts else expr

    content = re.sub(
        r"IDENTIFIER\s*\((.*?)\)",
        replace_identifier,
        content,
        flags=re.IGNORECASE | re.DOTALL,
    )

    return content


def main():
    sql_dir = "objects"
    env_db = os.environ.get("SNOWFLAKE_DATABASE", "DEV_DB")
    
    exit_code = 0
    
    with tempfile.TemporaryDirectory(prefix=".lint_tmp_") as tmpdir:
        for root, _, files in os.walk(sql_dir):
            for file in files:
                if file.endswith('.sql'):
                    src_path = os.path.join(root, file)
                    rel_path = os.path.relpath(src_path, sql_dir)
                    dst_path = os.path.join(tmpdir, rel_path)
                    
                    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                    
                    with open(src_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    parsed_content = preprocess_schemachange_sql(content, env_db)
                    
                    with open(dst_path, 'w', encoding='utf-8') as f:
                        f.write(parsed_content)
        
        result = subprocess.run(
            [
                "sqlfluff",
                "lint",
                tmpdir,
                "--config",
                ".sqlfluff",
            ],
            capture_output=True,
            text=True,
        )
        
        output = result.stdout.replace(tmpdir + os.sep, '')
        
        print(output)
        
        if result.returncode != 0:
            exit_code = result.returncode
    
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
