resource "snowflake_database" "app_database" {
  name                        = var.database_name
  comment                     = "Application database managed by Terraform (${var.env})"
  data_retention_time_in_days = 7
}
