resource "snowflake_stage" "s3_external_stage" {
  name                = var.stage_name
  database            = snowflake_database.app_database.name
  schema              = snowflake_schema.external_staging.name
  url                 = var.stage_url
  storage_integration = snowflake_storage_integration.s3_integration.name
  file_format         = "FORMAT_NAME = ${snowflake_database.app_database.name}.${snowflake_schema.external_staging.name}.${snowflake_file_format.csv_format.name}"
  comment             = "External stage on S3, managed by Terraform (${var.env})"

  depends_on = [snowflake_file_format.csv_format]
}