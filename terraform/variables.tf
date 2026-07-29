# ======================================================
# Input Variables
# ======================================================
# These variables must be provided via terraform.tfvars or environment.
# Grouped by category for clarity.

# --- Authentication & Connection ---
variable "organization_name" {
  type        = string
  description = "Snowflake organization name"
}

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

# --- Database Objects ---
variable "database_name" {
  type        = string
  description = "Name of the application database"
}

variable "warehouse_name" {
  type        = string
  description = "Name of the application warehouse"
  default     = "COMPUTE_WH"
}

variable "warehouse_size" {
  type        = string
  description = "Size of the warehouse (XSMALL, SMALL, MEDIUM, LARGE, XLARGE, XXLARGE)"
  default     = "SMALL"
}

# --- Roles ---
variable "app_role_name" {
  type        = string
  description = "Name of the application role with full access"
  default     = "APP_ROLE"
}

variable "read_only_role_name" {
  type        = string
  description = "Name of the read-only role"
  default     = "READ_ONLY_ROLE"
}

# --- Schema ---
variable "schema_name" {
  type        = string
  description = "Name of the application schema"
}

# --- Environment Tag ---
variable "env" {
  type        = string
  description = "Environment tag used in comments"
  default     = "dev"
}

# --- S3 Storage Integration ---
variable "storage_integration_name" {
  type        = string
  description = "Name of the Snowflake storage integration object"
  default     = "S3_INT"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket, e.g. arn:aws:s3:::my-bucket"
}

variable "s3_bucket_path" {
  type        = string
  description = "Path prefix inside the bucket allowed for STORAGE_ALLOWED_LOCATIONS, e.g. arn:aws:s3:::my-bucket/data/"
}

variable "aws_role_arn" {
  type        = string
  description = "ARN of the IAM role Snowflake will assume, e.g. arn:aws:iam::123456789012:role/snowflake-s3-role"
}

# --- External Stage ---
variable "stage_name" {
  type        = string
  description = "Name of the external stage"
  default     = "S3_EXTERNAL_STAGE"
}

variable "stage_url" {
  type        = string
  description = "S3 URL for the stage, e.g. s3://my-bucket/data/"
}

# --- File Format ---
variable "file_format_name" {
  type        = string
  description = "Name of the CSV file format"
  default     = "CSV_FILE_FORMAT"
}

# --- Schema Names ---
variable "staging_schema_name" {
  type        = string
  description = "Schema for external stages and file formats"
  default     = "EXTERNAL_STAGING"
}

# --- Custom Role ---
variable "transformer_role_name" {
  type        = string
  description = "Name of the data transformer role"
  default     = "TRANSFORMER_ROLE"
}