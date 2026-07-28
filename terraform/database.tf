resource "snowflake_database" "databases" {
  for_each = var.database_names

  name                        = each.value
  comment                     = "Managed by Terraform (${var.env})"
  data_retention_time_in_days = 7
}