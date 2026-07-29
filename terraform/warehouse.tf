# ======================================================
# Warehouse Resource
# ======================================================
# Compute warehouse providing processing resources for queries and data loading.
# - auto_suspend: Shuts down warehouse after 5 minutes of inactivity to save costs
# - auto_resume: Automatically starts warehouse when queries are executed
# - initially_suspended: Starts in suspended state (no compute cost until activated)
# - warehouse_size: Determines CPU/memory allocation (default SMALL)

resource "snowflake_warehouse" "app_warehouse" {
  name                = var.warehouse_name
  warehouse_size      = var.warehouse_size
  auto_suspend        = 300
  auto_resume         = true
  initially_suspended = true
  comment             = "Application warehouse managed by Terraform (${var.env})"
}
