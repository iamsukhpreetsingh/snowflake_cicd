variable "account_name" {
  type        = string
  description = "Snowflake account identifier (e.g., MDPVAJJ-NJB64163)"
}

variable "user" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "role" {
  type = string
}

variable "warehouse" {
  type = string
}

variable "database_name" {
  type        = string
  description = "Name of the application database"
  default     = "APP_DATABASE_1"
}

variable "warehouse_name" {
  type        = string
  description = "Name of the application warehouse"
  default     = "APP_WH"
}

variable "warehouse_size" {
  type        = string
  description = "Size of the warehouse (XSMALL, SMALL, MEDIUM, LARGE, XLARGE)"
  default     = "SMALL"
}

variable "app_role_name" {
  type        = string
  description = "Name of the application role"
  default     = "APP_ROLE1"
}

variable "read_only_role_name" {
  type        = string
  description = "Name of the read-only role"
  default     = "READ_ONLY_ROLE"
}