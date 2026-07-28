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
  default     = "TERRAFORM_DB2"
}

variable "warehouse_name" {
  type        = string
  description = "Name of the application warehouse"
  default     = "TF_APP_WH2"
}

variable "warehouse_size" {
  type        = string
  description = "Size of the warehouse (XSMALL, SMALL, MEDIUM, LARGE, XLARGE, XXLARGE)"
  default     = "SMALL"
}

variable "app_role_name" {
  type        = string
  description = "Name of the application role with full access"
  default     = "TF_APP_ROLE2"
}

variable "read_only_role_name" {
  type        = string
  description = "Name of the read-only role"
  default     = "TF_READ_ONLY_ROLE"
}

variable "schema_name" {
  type        = string
  description = "Name of the application schema"
  default     = "TF_APP_SCHEMA"
}
