variable "account_name" {
  type        = string
  description = "Snowflake account identifier (e.g., MDPVAJJ-NJB64163)"
}

variable "user" {
  type        = string
  description = "Snowflake username for authentication"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "Snowflake password for authentication"
}

variable "role" {
  type        = string
  description = "Snowflake role to use for operations"
}

variable "warehouse" {
  type        = string
  description = "Snowflake warehouse to use for operations"
}

variable "database_name" {
  type        = string
  description = "Name of the application database"
}

variable "database_names" {
  description = "List of databases to create"
  type        = set(string)
}

variable "warehouse_name" {
  type        = string
  description = "Name of the application warehouse"
}

variable "warehouse_size" {
  type        = string
  description = "Size of the warehouse (XSMALL, SMALL, MEDIUM, LARGE, XLARGE, XXLARGE)"
  default     = "SMALL"
}

variable "app_role_name" {
  type        = string
  description = "Name of the application role with full access"
}

variable "read_only_role_name" {
  type        = string
  description = "Name of the read-only role"
}

variable "schema_name" {
  type        = string
  description = "Name of the application schema"
}