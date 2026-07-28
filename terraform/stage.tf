# ======================================================
# External Stage Resource
# ======================================================
# Creates a named external stage pointing to S3 for loading/unloading data.
# Integration flow:
#   1. storage_integration.tf creates S3 integration (for secure access)
#   2. file_format.tf defines CSV parsing rules
#   3. This stage references both to enable: COPY INTO <table> FROM @<stage_name>
# The stage URL points to S3 bucket location. Data can be loaded directly
# from S3 into Snowflake tables using COPY command.

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