# ======================================================
# Database & Schema Resources
# ======================================================
# Database: Top-level container for all application data.
#           Provides data retention policy (7 days by default).
# Schema: Logical grouping within database for organizing objects (tables, views, etc.)
# External Staging Schema: Dedicated schema for staging-related objects that need
#                          to be accessible across all application schemas.

resource "snowflake_database" "app_database" {
  name                        = var.database_name
  comment                     = "Managed by Terraform (${var.env})"
  data_retention_time_in_days = 7
}

resource "snowflake_schema" "external_staging" {
  database = snowflake_database.app_database.name
  name     = var.staging_schema_name
  comment  = "Schema for external stages and file formats, managed by Terraform (${var.env})"
}