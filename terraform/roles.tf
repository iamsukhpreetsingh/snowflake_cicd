resource "snowflake_account_role" "app_role" {
  name    = var.app_role_name
  comment = "Application role managed by Terraform (${var.env})"
}

resource "snowflake_account_role" "read_only_role" {
  name    = var.read_only_role_name
  comment = "Read-only role managed by Terraform (${var.env})"
}
