resource "snowflake_warehouse" "app_warehouse" {
  name                = var.warehouse_name
  warehouse_size      = var.warehouse_size
  auto_suspend        = 300
  auto_resume         = true
  initially_suspended = true
  comment             = "Application warehouse managed by Terraform (${var.env})"
}
