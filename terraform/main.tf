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
    key            = "snowflake-cicd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "snowflake" {
  preview_features_enabled = ["snowflake_storage_integration_resource"]
  host                     = "${var.account_name}.snowflakecomputing.com"
  user                     = var.user
  password                 = var.password
  role                     = var.role
  warehouse                = var.warehouse
}