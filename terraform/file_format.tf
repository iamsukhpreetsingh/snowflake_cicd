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