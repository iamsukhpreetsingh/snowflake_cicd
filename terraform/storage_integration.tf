# ======================================================
# Storage Integration Resource
# ======================================================
# Enables secure, bucket-level access to AWS S3 without exposing credentials.
# Flow:
#   1. Snowflake generates an IAM user and external ID
#   2. AWS admin creates IAM role trusting Snowflake's IAM user
#   3. IAM role is attached to this integration (storage_aws_role_arn)
#   4. S3 bucket policy restricts access to only this IAM role
# Outputs (outputs.tf) provide the ARN and external ID needed for IAM setup.
# The integration then allows stages to read/write to allowed S3 locations.

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