terraform {
  required_version = ">= 1.5.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 1.0.0"
    }
  }

  # Local state (default)
  # State file: terraform/terraform.tfstate

  # Remote backend options (uncomment one to enable):
  #
  # Option 1: S3 backend
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "snowflake-cicd/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
  #
  # Option 2: Terraform Cloud (free for small teams)
  # cloud {
  #   organization = "your-org"
  #   workspaces {
  #     name = "snowflake-cicd"
  #   }
  # }
}

provider "snowflake" {
  host      = "${var.account_name}.snowflakecomputing.com"
  user      = var.user
  password  = var.password
  role      = var.role
  warehouse = var.warehouse
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name (dev or prod)"
}
