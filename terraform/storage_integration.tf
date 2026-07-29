resource "snowflake_storage_integration" "s3_integration" {
  name                        = var.storage_integration_name
  comment                     = "S3 integration for ${var.env} environment"
  enabled                     = true
  type                        = "EXTERNAL_STAGE"
  
  storage_provider            = "S3"
  storage_aws_role_arn        = var.aws_role_arn
  storage_allowed_locations   = [var.s3_bucket_path]
  
  # Optional: block specific paths if needed
  # storage_blocked_locations = []
}