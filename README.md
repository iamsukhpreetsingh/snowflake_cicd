# Snowflake CI/CD Pipeline

Complete CI/CD pipeline for Snowflake using **Terraform** (infrastructure) and **Schemachange** (schema objects).

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Workflows                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  terraform.yml          ci.yml            cd_dev.yml             │
│  (Infrastructure)       (SQL Lint)        (Dev Deploy)           │
│        │                    │                  │                 │
│        ▼                    ▼                  ▼                 │
│  ┌──────────────┐    ┌──────────────┐   ┌──────────────┐        │
│  │ TF Plan/Apply│    │ SQL Lint/Dry │   │ Deploy+Backup│        │
│  └──────────────┘    └──────────────┘   └──────────────┘        │
│                                                │                 │
│                                                ▼                 │
│                                         cd_prod.yml              │
│                                       (Prod Deploy)              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      Snowflake Environment                       │
├─────────────────────────────────────────────────────────────────┤
│  Terraform manages:        Schemachange manages:                │
│  - Database                - Tables                             │
│  - Warehouse               - Views                              │
│  - Roles                   - Stored Procedures                  │
│  - Schemas                 - Streams                            │
│                            - Tasks                              │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
snowflake_cicd/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Lint SQL + dry-run
│       ├── cd_dev.yml          # Deploy to dev with rollback
│       ├── cd_prod.yml         # Deploy to prod (with approval)
│       └── terraform.yml       # Terraform CI/CD for infra
├── terraform/
│   ├── main.tf                 # Snowflake resources
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   └── terraform.tfvars        # Variable values
├── objects/
│   └── V*.sql                  # Schemachange migration files
├── scripts/
│   ├── backup_snapshot.py      # Pre-deploy backup
│   ├── rollback.py             # Rollback on failure
│   ├── validate_deployment.py  # Post-deploy validation
│   └── cleanup_backup.py       # Cleanup backup DB
└── schemachange-config.yml     # Schemachange configuration
```

## Setup Instructions

### Step 1: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret Name          | Example Value          | Description              |
| -------------------- | ---------------------- | ------------------------ |
| `SF_USER`          | `SUKHPREETSNOWFLAKE` | Snowflake username       |
| `SF_PASSWORD`      | `your_password`      | Snowflake password       |
| `SF_ROLE`          | `ACCOUNTADMIN`       | Snowflake role           |
| `SF_ACCOUNT_NAME`  | `MDPVAJJ-NJB64163`   | Snowflake account name   |
| `SF_DATABASE`      | `DEV_DATABASE`       | Dev database name        |
| `SF_DATABASE_PROD` | `PROD_DATABASE`      | Production database name |
| `SF_READ_ROLE`     | `READ_ONLY_ROLE`     | Read-only role name      |

### Step 2: Create GitHub Environments

Go to **Settings** → **Environments** → **New environment**

#### Create: `development`

- No protection rules needed (auto-deploy)
- Add any secrets specific to dev

#### Create: `production`

- Click **Required reviewers** → Add yourself/team
- Click **Add existing secrets** → Add production secrets
- Add environment-specific secrets:
  - `SF_DATABASE` → production database name

### Step 3: Initialize Terraform (First Time)

```bash
cd terraform
terraform init
```

### Step 4: Test the Pipeline

#### Test CI Workflow (SQL Lint)

```bash
# Add a new SQL migration file
echo "CREATE TABLE IF NOT EXISTS {{ db }}.DEMO.TEST_TABLE (
    id NUMBER(38,0),
    name VARCHAR(100)
);" > objects/V1.0.5___create_test_table.sql

git add objects/
git commit -m "Add test table"
git push origin dev
```

#### Test Terraform Workflow

```bash
# Push changes to terraform/
git add terraform/
git commit -m "Update infrastructure"
git push origin dev

# Or manually trigger via GitHub Actions UI
```

#### Test Production Deployment

1. Merge PR from `dev` to `main`
2. Go to **Actions** → **CD - Production**
3. Click **Run workflow**
4. Type `DEPLOY` in confirmation box

---

## How to Make Changes

### 1. Infrastructure Changes (Terraform)

Terraform is used for architecture-level changes: databases, warehouses, roles, schemas, and grants.

#### Add New Infrastructure

**Example: Add a new warehouse**

```hcl
# Edit terraform/main.tf
resource "snowflake_warehouse" "etl_warehouse" {
  name                = "ETL_WH"
  warehouse_size      = "MEDIUM"
  auto_suspend        = 600
  auto_resume         = true
  initially_suspended = true
  comment             = "ETL warehouse managed by Terraform"
}
```

**Example: Add a new role and grant privileges**

```hcl
# Edit terraform/main.tf
resource "snowflake_account_role" "etl_role" {
  name    = "ETL_ROLE"
  comment = "ETL role managed by Terraform"
}

resource "snowflake_grant_privileges_to_account_role" "etl_role_wh_usage" {
  account_role_name = snowflake_account_role.etl_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.etl_warehouse.name
  }
}
```

#### Modify Existing Infrastructure

**Change warehouse size:**

```hcl
# Edit terraform/terraform.tfvars
warehouse_size = "MEDIUM"  # Changed from XSMALL
```

**Change database name:**

```hcl
# Edit terraform/terraform.tfvars
database_name = "MY_NEW_DATABASE"
```

#### Apply Infrastructure Changes

**Option 1: Local (Recommended for testing)**

```bash
cd terraform

# View planned changes
terraform plan

# Apply changes
terraform apply
```

**Option 2: Via GitHub Actions**

```bash
# Push changes to terraform/ directory
git add terraform/
git commit -m "Add ETL warehouse"
git push origin dev   # Triggers terraform plan

# Merge to main to apply
git checkout main
git merge dev
git push origin main  # Triggers terraform apply
```

#### Destroy Infrastructure (Use with caution!)

```bash
# Local
cd terraform
terraform destroy

# Or via GitHub Actions
# Go to Actions → Terraform CI/CD → Run workflow
# Select "destroy" from the action dropdown
```

---

### 2. Database/Schema Changes (Schemachange)

Schemachange is used for schema objects: tables, views, stored procedures, streams, tasks.

#### Add New Schema Objects

**Example: Add a new table**

```bash
# Create file: objects/V1.1.0___create_orders_table.sql
CREATE TABLE IF NOT EXISTS {{ db }}.DEMO.ORDERS (
    id NUMBER(38,0) PRIMARY KEY,
    customer_id NUMBER(38,0),
    order_date TIMESTAMP_NTZ,
    total_amount NUMBER(10,2)
);

GRANT SELECT ON {{ db }}.DEMO.ORDERS TO ROLE {{ read_role }};
```

**Example: Add a new view**

```bash
# Create file: objects/V1.1.1___create_customer_orders_view.sql
CREATE OR REPLACE VIEW {{ db }}.DEMO.CUSTOMER_ORDERS AS
SELECT 
    c.id AS customer_id,
    c.name AS customer_name,
    o.id AS order_id,
    o.total_amount
FROM {{ db }}.DEMO.CUSTOMERS c
JOIN {{ db }}.DEMO.ORDERS o ON c.id = o.customer_id;
```

#### Modify Existing Objects

**Example: Add a column to existing table**

```bash
# Create file: objects/V1.0.5___add_email_to_customers.sql
ALTER TABLE {{ db }}.DEMO.CUSTOMERS 
ADD COLUMN email VARCHAR(255);
```

**Example: Update a stored procedure**

```bash
# Create file: objects/V1.2.0___update_get_customer_proc.sql
CREATE OR REPLACE PROCEDURE {{ db }}.DEMO.GET_CUSTOMER_BY_ID(id NUMBER)
RETURNS TABLE (id NUMBER, name VARCHAR, email VARCHAR)
LANGUAGE SQL
AS
$$
    SELECT id, name, email 
    FROM {{ db }}.DEMO.CUSTOMERS 
    WHERE id = id;
$$;
```

#### Migration Naming Convention

```
objects/V{version}___{description}.sql

Version format: MAJOR.MINOR.PATCH
- MAJOR: Breaking changes, major new features
- MINOR: New tables/views/procedures
- PATCH: Column additions, small modifications

Examples:
├── V1.0.0___create_schema.sql
├── V1.0.1___create_customer_table.sql
├── V1.0.2___create_orders_table.sql
├── V1.0.3___create_stage.sql
├── V1.0.4___add_email_to_customers.sql     # Column added
├── V1.1.0___create_products_table.sql      # Minor: new table
├── V1.1.1___create_products_view.sql       # Patch: new view
└── V2.0.0___restructure_schema.sql         # Major: breaking change
```

#### Using Jinja2 Templates

Schemachange supports Jinja2 templating. Available variables are defined in `schemachange-config.yml`:

```sql
-- Use {{ db }} for dynamic database name
CREATE TABLE {{ db }}.DEMO.MY_TABLE (...);

-- Use {{ read_role }} for role grants
GRANT SELECT ON {{ db }}.DEMO.MY_TABLE TO ROLE {{ read_role }};

-- Use custom variables passed via --vars
-- In workflow: --vars '{"SCHEMA_PREFIX": "DEV_"}'
CREATE SCHEMA {{ db }}.{{ SCHEMA_PREFIX }}MY_SCHEMA;
```

#### Apply Schema Changes

**Option 1: Local testing (dry-run)**

```bash
pip install schemachange

export SNOWFLAKE_ACCOUNT="MDPVAJJ-NJB64163"
export SNOWFLAKE_USER="your_user"
export SNOWFLAKE_PASSWORD="your_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
export SNOWFLAKE_DATABASE="your_database"
export SF_READ_ROLE="READ_ONLY_ROLE"

# Dry-run to check without applying
schemachange deploy -f objects --dry-run
```

**Option 2: Via GitHub Actions (Recommended)**

```bash
# Add your migration file
git add objects/V1.1.0___create_orders_table.sql
git commit -m "Add orders table"
git push origin dev

# CI workflow runs automatically:
# 1. sqlfluff lint - validates SQL syntax
# 2. schemachange dry-run - previews changes
# 3. cd_dev.yml - deploys to dev environment
# 4. Merge to main for production deployment
```

---

### 3. Combined Workflow Example

**Scenario: Add a new ETL pipeline with dedicated warehouse and tables**

#### Step 1: Add Infrastructure (Terraform)

```bash
# Edit terraform/main.tf - add ETL warehouse
git add terraform/main.tf
git commit -m "Add ETL warehouse"
git push origin dev
# Wait for terraform plan to succeed
# Merge to main to apply
```

#### Step 2: Add Schema Objects (Schemachange)

```bash
# Create objects/V1.1.0___create_etl_tables.sql
CREATE TABLE {{ db }}.DEMO.ETL_JOBS (
    job_id NUMBER PRIMARY KEY,
    job_name VARCHAR(100),
    status VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE {{ db }}.DEMO.ETL_LOGS (
    log_id NUMBER PRIMARY KEY,
    job_id NUMBER,
    message VARCHAR(1000),
    logged_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

git add objects/V1.1.0___create_etl_tables.sql
git commit -m "Add ETL tracking tables"
git push origin dev
# CI runs lint, then deploys to dev
# Merge to main for production
```

---

## Workflow Triggers

| Workflow          | Trigger                                | Description                       |
| ----------------- | -------------------------------------- | --------------------------------- |
| `terraform.yml` | Push to`terraform/`                  | Plans on push, applies on`main` |
| `ci.yml`        | Push to`dev/main` in `objects/`    | Lints SQL + dry-run               |
| `cd_dev.yml`    | After CI success on`dev`             | Deploys to development            |
| `cd_prod.yml`   | Manual dispatch or after CI on`main` | Deploys to production             |

## Features

### CI Pipeline

- SQL linting with sqlfluff
- Schema migration dry-run

### CD Pipeline

- Automated deployment to dev
- Manual approval for production
- Pre-deployment backup (clone database)
- Post-deployment validation
- Automatic rollback on failure
- Backup cleanup on success

### Terraform Pipeline

- Infrastructure as Code for Snowflake
- Separate CI/CD for infrastructure changes
- Plan on PR, Apply on merge to main
- Destroy capability (requires manual dispatch)

### Security

- Secrets stored in GitHub Secrets
- Environment-specific secrets
- Required reviewers for production
- Sensitive variables marked appropriately

## Rollback Procedure

If a deployment fails, the pipeline automatically:

1. Clones the backup database
2. Renames it to the original database name
3. Validates the rollback

For manual rollback:

```bash
python scripts/rollback.py "BACKUP_DATABASE_NAME"
```

## Troubleshooting

### Terraform Init Fails

```bash
rm -rf terraform/.terraform terraform/.terraform.lock.hcl
terraform init
```

### Schemachange Fails

- Check the change history table exists
- Verify database permissions
- Check SQL syntax with `sqlfluff lint objects/`

### Workflow Not Triggering

- Check paths filter in workflow.yml
- Verify branch names match
- Check GitHub Actions permissions in repo settings

### Authentication Errors

- Verify `SF_ACCOUNT_NAME` is correct (e.g., `MDPVAJJ-NJB64163`)
- Check secrets are set in GitHub
- For legacy accounts, ensure host format is correct

## Local Testing

### Test Terraform Locally

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Test Schemachange Locally

```bash
pip install schemachange
export SNOWFLAKE_ACCOUNT="MDPVAJJ-NJB64163"
export SNOWFLAKE_USER="your_user"
export SNOWFLAKE_PASSWORD="your_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
export SNOWFLAKE_DATABASE="your_database"
export SF_READ_ROLE="READ_ONLY_ROLE"

schemachange deploy -f objects --dry-run
```
