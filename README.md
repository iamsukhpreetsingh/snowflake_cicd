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
│   ├── cleanup_backup.py       # Cleanup backup DB
│   └── lint_schemachange.py    # Jinja-aware SQL linter
└── schemachange-config.yml     # Schemachange configuration
```

## Prerequisites

Before setting up the pipeline, ensure you have:

1. **AWS S3 Bucket** for Terraform remote state
2. **AWS DynamoDB Table** for state locking
3. **Snowflake Account** with admin access
4. **GitHub Repository** with Actions enabled

### Create AWS Resources for Terraform State

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket your-terraform-state-bucket \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket your-terraform-state-bucket \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

## Setup Instructions

### Step 1: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

#### Snowflake Secrets

| Secret Name          | Example Value          | Description              |
| -------------------- | ---------------------- | ------------------------ |
| `SF_USER`            | `SUKHPREETSNOWFLAKE`   | Snowflake username       |
| `SF_PASSWORD`        | `your_password`        | Snowflake password       |
| `SF_ROLE`            | `ACCOUNTADMIN`         | Snowflake role           |
| `SF_ACCOUNT_NAME`    | `MDPVAJJ-NJB64163`     | Snowflake account name   |
| `SF_DATABASE`        | `DEV_DATABASE`         | Dev database name        |
| `SF_DATABASE_PROD`   | `PROD_DATABASE`        | Production database name |

#### AWS Secrets (for Terraform remote state)

| Secret Name            | Description                    |
| ---------------------- | ------------------------------ |
| `AWS_ACCESS_KEY_ID`    | AWS access key with S3/DDB access |
| `AWS_SECRET_ACCESS_KEY`| AWS secret key                 |

### Step 2: Create GitHub Environments

Go to **Settings** → **Environments** → **New environment**

#### Create: `development`

- No protection rules needed (auto-deploy)

#### Create: `production`

- Click **Required reviewers** → Add yourself/team
- Add environment-specific secrets if needed

### Step 3: Update Terraform Backend Configuration

Edit `terraform/main.tf` and update the S3 backend configuration:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"  # CHANGE THIS
  key            = "snowflake-cicd/{{env}}/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

### Step 4: Initialize Terraform (First Time)

```bash
cd terraform

# Configure AWS credentials
export AWS_ACCESS_KEY_ID="your-aws-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret"

# Initialize with backend
terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="key=snowflake-cicd/dev/terraform.tfstate"
```

### Step 5: Test the Pipeline

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
# Go to Actions → Terraform CI/CD → Run workflow
# Select:
#   - action: plan
#   - environment: development
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
  name                = "ETL_WH_${var.env}"  # Suffix with env
  warehouse_size      = "MEDIUM"
  auto_suspend        = 600
  auto_resume         = true
  initially_suspended = true
  comment             = "ETL warehouse managed by Terraform (${var.env})"
}
```

**Example: Add a new role and grant privileges**

```hcl
# Edit terraform/main.tf
resource "snowflake_account_role" "etl_role" {
  name    = "ETL_ROLE_${var.env}"
  comment = "ETL role managed by Terraform (${var.env})"
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

#### Apply Infrastructure Changes

**Option 1: Via GitHub Actions (Recommended)**

```bash
# Push changes to terraform/ directory
git add terraform/
git commit -m "Add ETL warehouse"
git push origin dev

# Go to Actions → Terraform CI/CD → Run workflow
# Select:
#   - action: apply
#   - environment: development (or production)
```

**Option 2: Local (for testing)**

```bash
cd terraform

# Set environment variables
export TF_VAR_account_name="MDPVAJJ-NJB64163"
export TF_VAR_user="your_username"
export TF_VAR_password="your_password"
export TF_VAR_role="ACCOUNTADMIN"
export TF_VAR_warehouse="COMPUTE_WH"
export TF_VAR_database_name="APP_DATABASE_DEV"
export TF_VAR_warehouse_name="APP_WH_DEV"
export TF_VAR_warehouse_size="XSMALL"
export TF_VAR_app_role_name="APP_ROLE_DEV"
export TF_VAR_read_only_role_name="READ_ONLY_ROLE_DEV"
export TF_VAR_env="dev"

# View planned changes
terraform plan

# Apply changes
terraform apply
```

#### Destroy Infrastructure (Use with caution!)

```bash
# Via GitHub Actions
# Go to Actions → Terraform CI/CD → Run workflow
# Select:
#   - action: destroy
#   - confirm_destroy: DESTROY (type this exactly)
#   - environment: development (or production)
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

Schemachange supports Jinja2 templating. The `db` variable is passed via `--vars`:

```sql
-- Use {{ db }} for dynamic database name
CREATE TABLE {{ db }}.DEMO.MY_TABLE (...);

-- Variables are passed as:
-- --vars '{"db": "DEV_DATABASE"}'
```

#### Apply Schema Changes

**Option 1: Via GitHub Actions (Recommended)**

```bash
# Add your migration file
git add objects/V1.1.0___create_orders_table.sql
git commit -m "Add orders table"
git push origin dev

# CI workflow runs automatically:
# 1. lint_schemachange.py - lints SQL with Jinja preprocessing
# 2. schemachange dry-run - previews changes
# 3. cd_dev.yml - deploys to dev environment
# 4. Merge to main for production deployment
```

**Option 2: Local testing (dry-run)**

```bash
pip install schemachange

export SNOWFLAKE_ACCOUNT="MDPVAJJ-NJB64163"
export SNOWFLAKE_USER="your_user"
export SNOWFLAKE_PASSWORD="your_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
export SNOWFLAKE_DATABASE="DEV_DATABASE"

# Dry-run to check without applying
schemachange deploy -f objects \
  --vars "{\"db\": \"$SNOWFLAKE_DATABASE\"}" \
  --dry-run
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

# Go to Actions → Terraform CI/CD → Run workflow
# Select action: apply, environment: development
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

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `terraform.yml` | Manual dispatch | Plan/Apply/Destroy with env selection |
| `ci.yml` | Push to `dev/main` in `objects/` | Lints SQL + dry-run |
| `cd_dev.yml` | After CI success on `dev` | Deploys to development |
| `cd_prod.yml` | Manual dispatch with "DEPLOY" | Deploys to production |

## Security Features

- **Secrets Management**: All credentials stored in GitHub Secrets
- **Environment Protection**: Production requires manual approval
- **Confirmation Gates**: 
  - Production deploy requires typing "DEPLOY"
  - Terraform destroy requires typing "DESTROY"
- **Safe Rollback**: Rollback only triggers if backup succeeds
- **Terraform State**: Encrypted S3 backend with DynamoDB locking

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
# Check AWS credentials
aws sts get-caller-identity

# Verify S3 bucket exists
aws s3 ls s3://your-terraform-state-bucket

# Clear cache and reinitialize
rm -rf terraform/.terraform terraform/.terraform.lock.hcl
terraform init
```

### Schemachange Fails

- Check the change history table exists
- Verify database permissions
- Run SQL lint locally: `python scripts/lint_schemachange.py`
- Check that `db` variable is passed correctly

### Authentication Errors

- Verify `SF_ACCOUNT_NAME` is correct (e.g., `MDPVAJJ-NJB64163`)
- Check all GitHub secrets are set correctly
- For Terraform, ensure AWS credentials have S3/DDB permissions

### Workflow Not Triggering

- Check paths filter in workflow.yml
- Verify branch names match
- Check GitHub Actions permissions in repo settings

## Local Testing

### Test Terraform Locally

```bash
cd terraform

# Set required env vars
export AWS_ACCESS_KEY_ID="your-aws-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret"
export TF_VAR_account_name="MDPVAJJ-NJB64163"
export TF_VAR_user="your_username"
export TF_VAR_password="your_password"
export TF_VAR_role="ACCOUNTADMIN"
export TF_VAR_warehouse="COMPUTE_WH"
export TF_VAR_database_name="APP_DATABASE_DEV"
export TF_VAR_warehouse_name="APP_WH_DEV"
export TF_VAR_env="dev"

terraform init
terraform plan
terraform apply
```

### Test Schemachange Locally

```bash
pip install schemachange snowflake-connector-python

export SNOWFLAKE_ACCOUNT="MDPVAJJ-NJB64163"
export SNOWFLAKE_USER="your_user"
export SNOWFLAKE_PASSWORD="your_password"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
export SNOWFLAKE_DATABASE="DEV_DATABASE"

# Dry-run
schemachange deploy -f objects \
  --vars "{\"db\": \"$SNOWFLAKE_DATABASE\"}" \
  --dry-run

# Actual deployment
schemachange deploy -f objects \
  --vars "{\"db\": \"$SNOWFLAKE_DATABASE\"}" \
  --create-change-history-table
```

### Test SQL Linting Locally

```bash
pip install sqlfluff

export SNOWFLAKE_DATABASE="DEV_DATABASE"
python scripts/lint_schemachange.py
```
