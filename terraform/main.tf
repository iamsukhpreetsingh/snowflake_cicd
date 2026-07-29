# Terraform Configuration for Snowflake Infrastructure
# ======================================================
# - Database, schemas, and warehouses for compute/storage
# - Storage integration for S3 connectivity
# - External stages for loading data from S3

# ======================================================
# Terraform Setup & Backend Configuration
# =====================================================
# Defines Terraform version requirements and provider configuration.
# Backend stores state in S3 with DynamoDB for state locking to support

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.9.0"
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
  preview_features_enabled = [
    "snowflake_account_authentication_policy_attachment_resource",
    "snowflake_account_password_policy_attachment_resource",
    "snowflake_alert_resource",
    "snowflake_alerts_datasource",
    "snowflake_api_integration_resource",
    "snowflake_authentication_policy_resource",
    "snowflake_compute_pool_resource",
    "snowflake_compute_pools_datasource",
    "snowflake_cortex_search_service_resource",
    "snowflake_cortex_search_services_datasource",
    "snowflake_current_account_resource",
    "snowflake_current_account_datasource",
    "snowflake_current_organization_account_resource",
    "snowflake_database_datasource",
    "snowflake_database_role_datasource",
    "snowflake_dynamic_table_resource",
    "snowflake_dynamic_tables_datasource",
    "snowflake_external_function_resource",
    "snowflake_external_functions_datasource",
    "snowflake_external_table_resource",
    "snowflake_external_tables_datasource",
    "snowflake_external_volume_resource",
    "snowflake_failover_group_resource",
    "snowflake_failover_groups_datasource",
    "snowflake_file_format_resource",
    "snowflake_file_formats_datasource",
    "snowflake_function_java_resource",
    "snowflake_function_javascript_resource",
    "snowflake_function_python_resource",
    "snowflake_function_scala_resource",
    "snowflake_function_sql_resource",
    "snowflake_functions_datasource",
    "snowflake_git_repository_resource",
    "snowflake_git_repositories_datasource",
    "snowflake_image_repository_resource",
    "snowflake_image_repositories_datasource",
    "snowflake_job_service_resource",
    "snowflake_listing_resource",
    "snowflake_managed_account_resource",
    "snowflake_materialized_view_resource",
    "snowflake_materialized_views_datasource",
    "snowflake_network_policy_attachment_resource",
    "snowflake_network_rule_resource",
    "snowflake_email_notification_integration_resource",
    "snowflake_notification_integration_resource",
    "snowflake_object_parameter_resource",
    "snowflake_password_policy_resource",
    "snowflake_pipe_resource",
    "snowflake_pipes_datasource",
    "snowflake_current_role_datasource",
    "snowflake_service_resource",
    "snowflake_services_datasource",
    "snowflake_sequence_resource",
    "snowflake_sequences_datasource",
    "snowflake_share_resource",
    "snowflake_shares_datasource",
    "snowflake_parameters_datasource",
    "snowflake_procedure_java_resource",
    "snowflake_procedure_javascript_resource",
    "snowflake_procedure_python_resource",
    "snowflake_procedure_scala_resource",
    "snowflake_procedure_sql_resource",
    "snowflake_procedures_datasource",
    "snowflake_stage_resource",
    "snowflake_stages_datasource",
    "snowflake_storage_integration_resource",
    "snowflake_storage_integrations_datasource",
    "snowflake_system_generate_scim_access_token_datasource",
    "snowflake_system_get_aws_sns_iam_policy_datasource",
    "snowflake_system_get_privatelink_config_datasource",
    "snowflake_system_get_snowflake_platform_info_datasource",
    "snowflake_table_column_masking_policy_application_resource",
    "snowflake_table_constraint_resource",
    "snowflake_table_resource",
    "snowflake_tables_datasource",
    "snowflake_user_authentication_policy_attachment_resource",
    "snowflake_user_public_keys_resource",
    "snowflake_user_password_policy_attachment_resource",
    "snowflake_user_programmatic_access_token_resource",
    "snowflake_user_programmatic_access_tokens_datasource"
  ]
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.user
  password          = var.password
  role              = var.role
  warehouse         = var.warehouse
}