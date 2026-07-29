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