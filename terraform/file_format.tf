# ======================================================
# File Format Resource
# ======================================================
# Defines how Snowflake parses data files (CSV in this case).
# This file format is used by the external stage (stage.tf) when
# loading data from S3. Configuration includes:
# - field_delimiter: Character separating columns
# - skip_header: Number of header rows to skip
# - field_optionally_enclosed_by: Quote character for fields
# - null_if: Values to treat as NULL
# - compression: Auto-detect compression (GZIP, etc.)

resource "snowflake_file_format" "csv_format" {
  name     = var.file_format_name
  database = snowflake_database.app_database.name
  schema   = snowflake_schema.external_staging.name

  format_type                    = "CSV"
  field_delimiter                = ","
  skip_header                    = 1
  field_optionally_enclosed_by   = "\""
  null_if                        = ["NULL", ""]
  empty_field_as_null            = true
  error_on_column_count_mismatch = false
  compression                    = "AUTO"
  comment                        = "CSV file format managed by Terraform (${var.env})"
}