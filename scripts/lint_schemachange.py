import os
import re
import sys
import tempfile
import subprocess

def preprocess_schemachange_sql(content: str, env_db: str) -> str:
    """
    Replaces Schemachange variables and unwraps IDENTIFIER() 
    so static linters can read the actual schema/table names.
    """
    # 1. Replace the Schemachange variable with the Dev database name
    content = content.replace('$DB_NAME', env_db)
    
    # 2. Unwrap IDENTIFIER('DEV_DB.FROM_DEV.CUSTOMERS') -> DEV_DB.FROM_DEV.CUSTOMERS
    # This regex looks for IDENTIFIER('...') and extracts what is inside the quotes
    pattern = r"IDENTIFIER\(\s*'([^']+)'\s*\)"
    content = re.sub(pattern, r'\1', content, flags=re.IGNORECASE)
    
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
        result = subprocess.run(
            ['sqlfluff', 'lint', tmpdir, '--dialect', 'snowflake'],
            capture_output=True,
            text=True
        )
        
        # Clean up the output: replace the temp directory path with your actual path
        # so the GitHub PR annotations point to the correct files
        output = result.stdout.replace(tmpdir + os.sep, '')
        
        print(output)
        
        # Exit with the linter's exit code (0 = pass, 1 = fail)
        sys.exit(result.returncode)

if __name__ == "__main__":
    main()