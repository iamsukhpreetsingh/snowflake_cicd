# ======================================================
# Role Resources (Access Control)
# ======================================================
# Snowflake roles for managing access control:
# - app_role: Application role with full access privileges
# - read_only_role: Role with read-only access for reporting/analysis
# These roles can be granted to users or other roles to control
# what objects they can access and what operations they can perform.

resource "snowflake_account_role" "app_role" {
  name    = var.app_role_name
  comment = "Application role managed by Terraform (${var.env})"
}

resource "snowflake_account_role" "read_only_role" {
  name    = var.read_only_role_name
  comment = "Read-only role managed by Terraform (${var.env})"
}
