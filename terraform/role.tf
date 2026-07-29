# ======================================================
# Role Resource
# ======================================================
# Custom role for data transformation tasks.
# - Used by ETL pipelines and data processing workflows
# - Can be granted specific privileges on schemas/tables

resource "snowflake_account_role" "transformer_role" {
  name    = var.transformer_role_name
  comment = "Data transformer role managed by Terraform (${var.env})"
}