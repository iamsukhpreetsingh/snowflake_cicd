resource "snowflake_table" "two_table" {
  database = var.database_name
  schema   = var.schema_name
  name     = "two_CUSTOMERS_TF"
  comment  = "Managed by Terraform (${var.env})"

  depends_on = [
    snowflake_database.app_database,
    snowflake_schema.app_schema
  ]

  column {
    name     = "CUSTOMER_ID2"
    type     = "NUMBER(38,0)"
    nullable = false
  }

  column {
    name     = "CUSTOMER_NAME2"
    type     = "VARCHAR(200)"
    nullable = false
  }

  column {
    name     = "CUSTOMERCATEGORY2"
    type     = "VARCHAR(200)"
    nullable = true
  }

  column {
    name     = "PHONENUMBER"
    type     = "VARCHAR(255)"
    nullable = true
  }

  column {
    name     = "SIGNUP_DATE2"
    type     = "DATE"
    nullable = false
  }

  column {
    name     = "IS_ACTIVE2"
    type     = "BOOLEAN"
    nullable = true

    default {
      constant = "TRUE"
    }
  }

  column {
    name     = "CREATED_AT2"
    type     = "TIMESTAMP_NTZ"
    nullable = true

    default {
      expression = "CURRENT_TIMESTAMP()"
    }
  }
}