resource "snowflake_table" "customers_table" {
  database = var.database_name
  schema   = var.schema_name
  name     = "CUSTOMERS_TF"
  comment  = "Managed by Terraform (${var.env})"

  column {
    name     = "CUSTOMER_ID"
    type     = "NUMBER(38,0)"
    nullable = false
  }

  column {
    name     = "CUSTOMER_NAME"
    type     = "VARCHAR(200)"
    nullable = false
  }

  column {
    name     = "CUSTOMER_CATEGORY"
    type     = "VARCHAR(200)"
    nullable = true
  }

  column {
    name     = "PHONE_NO"
    type     = "VARCHAR(255)"
    nullable = true
  }

  column {
    name     = "SIGNUP_DATE"
    type     = "DATE"
    nullable = false
  }

  column {
    name     = "IS_ACTIVE"
    type     = "BOOLEAN"
    nullable = true

    default {
      constant = "TRUE"
    }
  }

  column {
    name     = "CREATED_AT"
    type     = "TIMESTAMP_NTZ"
    nullable = true

    default {
      expression = "CURRENT_TIMESTAMP()"
    }
  }
}