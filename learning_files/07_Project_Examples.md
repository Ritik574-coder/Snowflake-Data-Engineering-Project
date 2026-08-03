# Snowflake CLI Mastery Guide

## 07 — Project Examples: End-to-End Terminal Workflows

> Complete, copy-pasteable workflows from zero to production. Each example shows the full terminal session, including expected output and error handling.

---

## Example 1 — New Project: Init → Connect → Deploy → Query

```bash
# 1. Install & verify
snow --version
```
```
Snowflake CLI version: 3.7.0
```

```bash
# 2. Create a connection
snow connection add --connection-name dev --account myorg-devaccount \
  --user jdoe --role SYSADMIN --warehouse WH_DEV --no-interactive
```
```
Connection "dev" successfully added to /home/jdoe/.snowflake/config.toml
```

```bash
# 3. Test it
snow connection test --connection dev
```
```
+-----------------+--------------------+
| key             | value              |
|-----------------|--------------------|
| Connection      | dev                |
| Status          | OK                 |
+-----------------+--------------------+
```

```bash
# 4. Set as default so you can drop --connection going forward
snow connection set-default dev
```

```bash
# 5. Bootstrap a project
snow init retail_analytics --template-name example_snowpark
cd retail_analytics
```
```
Fetching template "example_snowpark"...
Project created in ./retail_analytics
```

```bash
# 6. Provision the database/schema this project targets
snow sql -q "
CREATE DATABASE IF NOT EXISTS RETAIL_ANALYTICS_DEV;
CREATE SCHEMA IF NOT EXISTS RETAIL_ANALYTICS_DEV.CORE;
"
```

```bash
# 7. Deploy the Snowpark artifacts defined in snowflake.yml
snow snowpark build
snow snowpark deploy
```
```
Building deployment artifact...
Artifact built at: .snowpark/app.zip
Uploading artifact...
+------------------------------------------------------+
| object              | type      | status             |
|----------------------|-----------|--------------------|
| CLEAN_ORDERS_UDF     | function  | created            |
+------------------------------------------------------+
```

```bash
# 8. Verify with a query
snow sql -q "SELECT RETAIL_ANALYTICS_DEV.CORE.CLEAN_ORDERS_UDF(PARSE_JSON('{\"id\":1}'));"
```

---

## Example 2 — Uploading Files and Bulk Loading

```bash
snow stage create @retail_analytics_dev.core.raw_landing
snow stage copy ./sample_data/orders_2026_07.csv @retail_analytics_dev.core.raw_landing/
```
```
+-----------------------------------------------------------------------------+
| source                | target                        | status | message   |
|-------------------------|-------------------------------|--------|-----------|
| orders_2026_07.csv      | orders_2026_07.csv.gz         | UPLOADED| ...      |
+-----------------------------------------------------------------------------+
```

```bash
snow sql -q "
CREATE FILE FORMAT IF NOT EXISTS RETAIL_ANALYTICS_DEV.CORE.FF_CSV
  TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '\"';

CREATE TABLE IF NOT EXISTS RETAIL_ANALYTICS_DEV.CORE.RAW_ORDERS (
  order_id INT, customer_id INT, amount NUMBER(10,2), order_date DATE
);

COPY INTO RETAIL_ANALYTICS_DEV.CORE.RAW_ORDERS
FROM @retail_analytics_dev.core.raw_landing/
FILE_FORMAT = (FORMAT_NAME='RETAIL_ANALYTICS_DEV.CORE.FF_CSV')
ON_ERROR = 'ABORT_STATEMENT';
"
```
```
+---------------------------------------------------------------------------+
| file                    | status  | rows_parsed | rows_loaded | errors    |
|--------------------------|---------|-------------|-------------|-----------|
| orders_2026_07.csv.gz    | LOADED  | 5000        | 5000        | 0         |
+---------------------------------------------------------------------------+
```

---

## Example 3 — Managing Users and Warehouses (Admin Task)

```bash
snow connection add --connection-name admin --account myorg-devaccount \
  --user jdoe --role USERADMIN --no-interactive
```

```bash
snow sql --connection admin -q "
CREATE ROLE IF NOT EXISTS FR_ANALYST;
CREATE USER IF NOT EXISTS new_analyst
  LOGIN_NAME='new_analyst' DEFAULT_ROLE='FR_ANALYST'
  DEFAULT_WAREHOUSE='WH_BI' MUST_CHANGE_PASSWORD=TRUE
  PASSWORD='TempPass!2026';
GRANT ROLE FR_ANALYST TO USER new_analyst;
"
```
```
Role FR_ANALYST successfully created.
User NEW_ANALYST successfully created.
Statement executed successfully.
```

```bash
snow sql --connection admin -q "
CREATE WAREHOUSE IF NOT EXISTS WH_BI WAREHOUSE_SIZE='XSMALL' AUTO_SUSPEND=60 AUTO_RESUME=TRUE;
"
```

---

## Example 4 — Deploying a Streamlit App

```bash
mkdir sales_dashboard && cd sales_dashboard
cat > streamlit_app.py << 'EOF'
import streamlit as st
from snowflake.snowpark.context import get_active_session

session = get_active_session()
st.title("Sales Dashboard")
df = session.table("RETAIL_ANALYTICS_DEV.CORE.RAW_ORDERS").to_pandas()
st.dataframe(df)
st.metric("Total Revenue", f"${df['AMOUNT'].sum():,.2f}")
EOF

cat > snowflake.yml << 'EOF'
definition_version: "2"
entities:
  sales_dashboard:
    type: streamlit
    identifier: SALES_DASHBOARD
    main_file: streamlit_app.py
    query_warehouse: WH_BI
    stage: streamlit_stage
    artifacts:
      - streamlit_app.py
EOF

snow streamlit deploy --connection dev
```
```
Uploading artifacts...
Streamlit app "SALES_DASHBOARD" deployed successfully.
```

```bash
snow streamlit get-url sales_dashboard --connection dev
```
```
https://app.snowflake.com/myorg/devaccount/#/streamlit-apps/RETAIL_ANALYTICS_DEV.CORE.SALES_DASHBOARD
```

---

## Example 5 — Native App: Full Dev Loop and Production Publish

```bash
snow init inventory_app --template-name native-apps-basic
cd inventory_app
snow app run --connection dev        # iterate here repeatedly
```
```
Bundling artifacts...
Creating application package INVENTORY_APP_PKG...
Creating application INVENTORY_APP...
Your application object (INVENTORY_APP) is now available.
```

```bash
# Once stable, cut a version for release
snow app version create v1_0_0 --connection prod
```
```
Uploading artifacts to application package stage...
Version V1_0_0 created for application package INVENTORY_APP_PKG.
```

```bash
snow app release-directive set --version v1_0_0 --patch 0 --channel DEFAULT --connection prod
```
```
Release directive updated. Consumers on DEFAULT channel will receive v1_0_0 patch 0.
```

---

## Example 6 — Git-Integrated Deployment (No Separate CI Checkout Needed)

```bash
snow git setup analytics_repo --connection prod
```
```
URL of the repository: https://github.com/my-org/analytics-platform
Repository "ANALYTICS_REPO" successfully created.
```

```bash
snow git fetch @analytics_repo
snow git list-branches analytics_repo
```
```
+------------------------------------------------+
| name              | path                       |
|--------------------|----------------------------|
| main               | branches/main              |
| release-2026-08    | branches/release-2026-08   |
+------------------------------------------------+
```

```bash
snow git execute "@analytics_repo/branches/release-2026-08/sql/deploy/full_release.sql" --connection prod
```

---

## Example 7 — CI/CD Deployment: GitHub Actions

`.github/workflows/deploy-prod.yml`
```yaml
name: Deploy to Snowflake Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Snowflake CLI
        uses: snowflakedb/snowflake-cli-action@v1
        with:
          cli-version: "3.7.0"
          default-config-file-path: "config.toml"

      - name: Write empty config
        run: echo "" > config.toml

      - name: Test connection
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PRIVATE_KEY_FILE: ${{ github.workspace }}/deploy_key.p8
          SNOWFLAKE_ROLE: DEPLOYER
        run: |
          echo "${{ secrets.SNOWFLAKE_PRIVATE_KEY }}" > deploy_key.p8
          chmod 600 deploy_key.p8
          snow connection test --temporary-connection \
            --account "$SNOWFLAKE_ACCOUNT" --user "$SNOWFLAKE_USER" \
            --private-key-file "$SNOWFLAKE_PRIVATE_KEY_FILE" --role "$SNOWFLAKE_ROLE"

      - name: Deploy DDL migrations
        run: |
          snow sql -f migrations/release_$(date +%Y_%m).sql \
            --temporary-connection --account "${{ secrets.SNOWFLAKE_ACCOUNT }}" \
            --user "${{ secrets.SNOWFLAKE_USER }}" \
            --private-key-file deploy_key.p8 --role DEPLOYER \
            --single-transaction --enhanced-exit-codes

      - name: Run dbt models
        run: |
          snow dbt execute run analytics_dbt --temporary-connection \
            --account "${{ secrets.SNOWFLAKE_ACCOUNT }}" \
            --user "${{ secrets.SNOWFLAKE_USER }}" \
            --private-key-file deploy_key.p8 --role DEPLOYER

      - name: Clean up secrets
        if: always()
        run: rm -f deploy_key.p8
```

> **✅ Best Practice**
> Use `--temporary-connection` (`-x`) in CI to avoid ever committing a populated `config.toml`. Inject all connection parameters via GitHub Secrets → environment variables/flags at run time, and always clean up any decoded private-key file in an `if: always()` step.

---

## Example 8 — CI/CD Deployment: Azure DevOps

`azure-pipelines.yml`
```yaml
trigger:
  branches:
    include: [main]

pool:
  vmImage: 'ubuntu-latest'

steps:
  - script: |
      curl -L -o snowflake-cli.deb https://path-to-latest-linux-installer
      sudo dpkg -i snowflake-cli.deb
      snow --version
    displayName: 'Install Snowflake CLI'

  - script: |
      echo "$(SNOWFLAKE_PRIVATE_KEY)" > $(Agent.TempDirectory)/deploy_key.p8
      chmod 600 $(Agent.TempDirectory)/deploy_key.p8
      snow sql -f migrations/latest.sql \
        --temporary-connection \
        --account "$(SNOWFLAKE_ACCOUNT)" \
        --user "$(SNOWFLAKE_USER)" \
        --private-key-file "$(Agent.TempDirectory)/deploy_key.p8" \
        --role DEPLOYER --single-transaction --enhanced-exit-codes
    displayName: 'Deploy migrations'
    env:
      SNOWFLAKE_PRIVATE_KEY: $(snowflakePrivateKeySecret)
```

---

## Example 9 — Database Migration Workflow (Versioned, Reviewable)

```
migrations/
├── V001__create_core_schema.sql
├── V002__add_orders_table.sql
├── V003__add_customer_index.sql
└── V004__backfill_amount_currency.sql
```

`deploy_migrations.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
CONN="${1:?Usage: deploy_migrations.sh <connection>}"

snow sql --connection "$CONN" -q "
CREATE TABLE IF NOT EXISTS META.SCHEMA_MIGRATIONS (
  version STRING PRIMARY KEY, applied_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);"

for file in migrations/V*.sql; do
  version=$(basename "$file" | cut -d'_' -f1)
  already_applied=$(snow sql --connection "$CONN" --format json \
    -q "SELECT COUNT(*) AS C FROM META.SCHEMA_MIGRATIONS WHERE version='$version';" \
    | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['C'])")

  if [ "$already_applied" = "0" ]; then
    echo ">>> Applying $file"
    snow sql --connection "$CONN" -f "$file" --single-transaction --enhanced-exit-codes
    snow sql --connection "$CONN" -q "INSERT INTO META.SCHEMA_MIGRATIONS (version) VALUES ('$version');"
  else
    echo ">>> Skipping $file (already applied)"
  fi
done
```

```bash
./deploy_migrations.sh prod
```
```
>>> Skipping V001__create_core_schema.sql (already applied)
>>> Skipping V002__add_orders_table.sql (already applied)
>>> Applying V003__add_customer_index.sql
>>> Applying V004__backfill_amount_currency.sql
```

---

## Example 10 — Rollback Workflow

```bash
# 1. Time Travel rollback for accidental data changes
snow sql --connection prod -q "
CREATE OR REPLACE TABLE ANALYTICS_PROD.CORE.ORDERS
  AS SELECT * FROM ANALYTICS_PROD.CORE.ORDERS AT (OFFSET => -3600);
"
```

```bash
# 2. UNDROP for accidental object drops (within retention window)
snow sql --connection prod -q "UNDROP TABLE ANALYTICS_PROD.CORE.CUSTOMERS;"
```

```bash
# 3. Native App rollback — redeploy previous version's release directive
snow app release-directive set --version v0_9_5 --patch 3 --channel DEFAULT --connection prod
```

```bash
# 4. Migration rollback — apply a paired "down" script and remove the ledger entry
snow sql --connection prod -f migrations/V004__backfill_amount_currency.down.sql --single-transaction
snow sql --connection prod -q "DELETE FROM META.SCHEMA_MIGRATIONS WHERE version='V004';"
```

---

## Example 11 — Secrets Management Pattern (No Plaintext Credentials Anywhere)

```bash
# Store an OAuth client secret / API key as a Snowflake Secret object (not in the CLI itself,
# but managed the same way — via snow sql)
snow sql --connection admin -q "
CREATE SECRET IF NOT EXISTS ANALYTICS_PROD.CORE.SEC_EXTERNAL_API_KEY
  TYPE = GENERIC_STRING
  SECRET_STRING = '$EXTERNAL_API_KEY';
GRANT USAGE ON SECRET ANALYTICS_PROD.CORE.SEC_EXTERNAL_API_KEY TO ROLE FR_DATA_ENGINEER;
"
```

Reference the secret inside a Snowpark external-access-enabled function (never printed, never logged):

```sql
CREATE OR REPLACE FUNCTION CALL_EXTERNAL_API(payload VARIANT)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
HANDLER = 'run'
EXTERNAL_ACCESS_INTEGRATIONS = (EAI_EXTERNAL_API)
SECRETS = ('api_key' = ANALYTICS_PROD.CORE.SEC_EXTERNAL_API_KEY)
AS
$$
import _snowflake, requests
def run(payload):
    key = _snowflake.get_generic_secret_string('api_key')
    return requests.post("https://api.example.com", json=payload, headers={"Authorization": f"Bearer {key}"}).json()
$$;
```

---

## Example 12 — Python Automation Deploying Multiple Environments in a Loop

```python
import subprocess

ENVIRONMENTS = ["dev", "staging", "prod"]

def deploy(env: str):
    print(f"=== Deploying to {env} ===")
    subprocess.run(
        ["snow", "sql", "-f", f"migrations/release_2026_07.sql",
         "--connection", env, "--single-transaction", "--enhanced-exit-codes"],
        check=True,
    )
    subprocess.run(
        ["snow", "dbt", "execute", "run", "analytics_dbt", "--connection", env],
        check=True,
    )

for env in ENVIRONMENTS:
    deploy(env)
    input(f"Deployed to {env}. Press Enter to continue to next environment...")  # manual gate for prod
```

---

Continue to **`08_Best_Practices.md`** for enterprise folder structure, naming, security, and CI/CD conventions.