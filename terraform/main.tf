terraform {
  required_version = ">= 1.5.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 1.0.0"
    }
  }
}

provider "snowflake" {
  host = "${var.account_name}.snowflakecomputing.com"
  user = var.user
  password = var.password
  role = var.role
  warehouse = var.warehouse
}

resource "snowflake_database" "app_database" {
  name                        = var.database_name
  comment                     = "Application database managed by Terraform"
  data_retention_time_in_days = 7
}

resource "snowflake_warehouse" "app_warehouse" {
  name                = var.warehouse_name
  warehouse_size      = var.warehouse_size
  auto_suspend        = 300
  auto_resume         = true
  initially_suspended = true
  comment             = "Application warehouse managed by Terraform"
}

resource "snowflake_account_role" "app_role" {
  name    = var.app_role_name
  comment = "Application role managed by Terraform"
}

resource "snowflake_account_role" "read_only_role" {
  name    = var.read_only_role_name
  comment = "Read-only role managed by Terraform"
}

resource "snowflake_schema" "app_schema" {
  database                    = snowflake_database.app_database.name
  name                        = "APP_SCHEMA"
  comment                     = "Application schema managed by Terraform"
  data_retention_time_in_days = 7
}

resource "snowflake_grant_privileges_to_account_role" "app_role_db_usage" {
  account_role_name = snowflake_account_role.app_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.app_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "read_only_role_db_usage" {
  account_role_name = snowflake_account_role.read_only_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.app_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "app_role_wh_usage" {
  account_role_name = snowflake_account_role.app_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.app_warehouse.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "read_only_role_wh_usage" {
  account_role_name = snowflake_account_role.read_only_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.app_warehouse.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "app_role_schema_grant" {
  account_role_name = snowflake_account_role.app_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = snowflake_schema.app_schema.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "read_only_role_schema_grant" {
  account_role_name = snowflake_account_role.read_only_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = snowflake_schema.app_schema.fully_qualified_name
  }
}
