resource "snowflake_schema" "external_staging" {
  database = snowflake_database.app_database.name
  name     = var.staging_schema_name
  comment  = "Schema for external stages and file formats, managed by Terraform (${var.env})"
}