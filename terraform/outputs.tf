output "database_name" {
  value       = snowflake_database.app_database.name
  description = "Name of the application database"
}

output "database_fully_qualified_name" {
  value       = snowflake_database.app_database.fully_qualified_name
  description = "Fully qualified name of the database"
}

output "warehouse_name" {
  value       = snowflake_warehouse.app_warehouse.name
  description = "Name of the application warehouse"
}

output "app_role_name" {
  value       = snowflake_account_role.app_role.name
  description = "Name of the application role"
}

output "read_only_role_name" {
  value       = snowflake_account_role.read_only_role.name
  description = "Name of the read-only role"
}

output "schema_name" {
  value       = snowflake_schema.app_schema.name
  description = "Name of the application schema"
}

output "schema_fully_qualified_name" {
  value       = snowflake_schema.app_schema.fully_qualified_name
  description = "Fully qualified schema name (database.schema)"
}

output "environment" {
  value       = var.env
  description = "Current environment"
}
