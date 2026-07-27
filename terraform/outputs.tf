output "database_name" {
  value       = snowflake_database.app_database.name
  description = "Name of the application database"
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

output "fully_qualified_schema" {
  value       = "\"${snowflake_database.app_database.name}\".\"${snowflake_schema.app_schema.name}\""
  description = "Fully qualified schema name"
}
