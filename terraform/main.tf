# Terraform Configuration for Snowflake Infrastructure
# ======================================================
# - Database, schemas, and warehouses for compute/storage
# - Storage integration for S3 connectivity
# - External stages for loading data from S3
# - File formats for parsing data files

# ======================================================
# Terraform Setup & Backend Configuration
# ======================================================
# Defines Terraform version requirements and provider configuration.
# Backend stores state in S3 with DynamoDB for state locking to support

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 1.0.0"
    }
  }

  backend "s3" {
    bucket         = "sukhpreet-terraform-state-bucket"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# ======================================================
# Snowflake Provider Configuration
# ======================================================
# Configures connection to Snowflake account. The provider handles
# authentication and default context for all resources. Preview features
# are enabled for newer resource types (storage integration, file format, stage).

provider "snowflake" {
  preview_features_enabled = ["snowflake_storage_integration_resource", "snowflake_file_format_resource", "snowflake_stage_resource"]
  organization_name         = var.organization_name
  account_name               = var.account_name
  user                         = var.user
  password                      = var.password
  role                            = var.role
  warehouse                        = var.warehouse
}