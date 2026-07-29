# ======================================================
# Application Schema Resource
# ======================================================
# Primary schema for application objects (tables, views, procedures).
# Uses the database created in database.tf. Includes data retention policy

resource "snowflake_schema" "app_schema" {
  database                    = snowflake_database.app_database.name
  name                        = var.schema_name
  comment                     = "Application schema managed by Terraform (${var.env})"
  data_retention_time_in_days = 7
}
