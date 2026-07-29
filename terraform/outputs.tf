# ======================================================
# Output Values
# ======================================================
# Exposes resource identifiers for use in:
# - Other Terraform configurations (via terraform_remote_state)
# - CI/CD pipelines
# - Manual AWS IAM setup for S3 integration

output "database_name" {
  value = snowflake_database.app_database.name
}

output "schema_name" {
  value = snowflake_schema.external_staging.name
}

output "storage_integration_name" {
  value = snowflake_storage_integration.s3_integration.name
}

# IAM Role Configuration Outputs
# These values are required to configure AWS IAM trust policy and S3 bucket policy
# for secure S3 access. See storage_integration.tf comments for setup details.
output "storage_aws_iam_user_arn" {
  value = snowflake_storage_integration.s3_integration.storage_aws_iam_user_arn
}

output "storage_aws_external_id" {
  value = snowflake_storage_integration.s3_integration.storage_aws_external_id
}

output "stage_name" {
  value = snowflake_stage.s3_external_stage.name
}

output "file_format_name" {
  value = snowflake_file_format.csv_format.name
}