import os
import re
import sys
import tempfile
import subprocess

import re

def preprocess_schemachange_sql(content: str, env_db: str) -> str:
    # Replace schemachange variables
    content = content.replace("$DB_NAME", env_db)

    # Replace IDENTIFIER(...) with the evaluated object name
    def replace_identifier(match):
        expr = match.group(1)

        # Extract all quoted string literals
        parts = re.findall(r"'([^']*)'", expr)

        # Join them together
        return "".join(parts)

    content = re.sub(
        r"IDENTIFIER\s*\((.*?)\)",
        replace_identifier,
        content,
        flags=re.IGNORECASE | re.DOTALL,
    )

    return content

def main():
    sql_dir = "objects"
    env_db = "DEV_DB" # Always lint against the DEV context
    
    # Create a hidden temporary directory
    with tempfile.TemporaryDirectory(prefix=".lint_tmp_") as tmpdir:
        # Walk through your pipelines folder
        for root, _, files in os.walk(sql_dir):
            for file in files:
                if file.endswith('.sql'):
                    src_path = os.path.join(root, file)
                    # Maintain folder structure in temp dir
                    rel_path = os.path.relpath(src_path, sql_dir)
                    dst_path = os.path.join(tmpdir, rel_path)
                    
                    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
                    
                    # Read, transform, and write to temp dir
                    with open(src_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                    parsed_content = preprocess_schemachange_sql(content, env_db)
                    
                    with open(dst_path, 'w', encoding='utf-8') as f:
                        f.write(parsed_content)
        
        # Run SQLFluff against the temporary directory
        subprocess.run(
    [
        "sqlfluff",
        "fix",
        tmpdir,
        "--config",
        ".sqlfluff",
        "--force",
    ],
    check=False,
)
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
        
        # Clean up the output: replace the temp directory path with your actual path
        # so the GitHub PR annotations point to the correct files
        output = result.stdout.replace(tmpdir + os.sep, '')
        
        print(output)
        
        # Exit with the linter's exit code (0 = pass, 1 = fail)
        sys.exit(result.returncode)

if __name__ == "__main__":
    main()