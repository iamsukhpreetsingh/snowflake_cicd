resource "snowflake_schema" "app_schema" {
  database                    = snowflake_database.app_database.name
  name                        = var.schema_name
  comment                     = "Application schema managed by Terraform (${var.env})"
  data_retention_time_in_days = 7
}
