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
