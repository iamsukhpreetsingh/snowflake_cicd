resource "snowflake_storage_integration" "s3_integration" {
  name    = var.storage_integration_name
  comment = "S3 storage integration managed by Terraform (${var.env})"
  type    = "EXTERNAL_STAGE"
  enabled = true

  storage_provider          = "S3"
  storage_aws_role_arn      = var.aws_role_arn
  storage_allowed_locations = [var.s3_bucket_path]

  # Optional: restrict further with storage_blocked_locations = []
}