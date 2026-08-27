# Snowflake CLI Mastery Guide

## 03 — All Snowflake CLI Commands (Exhaustive Reference)

> This is the complete command surface of Snowflake CLI, organized by command group. Every top-level group is documented with: purpose, full subcommand list, syntax, key flags, examples, expected output, common errors, and related commands.
>
> **Global flags** (`--connection`, `--format`, `--verbose`, `--debug`, `--silent`, `--enhanced-exit-codes`, `--help`, and the full authentication flag set) apply to nearly every leaf command shown below and are documented once in `02_Installation_and_Configuration.md` §9 to avoid repetition — they are omitted from each command's flag table unless a command has a materially different default.

---

## 0. The Root `snow` Command

```
snow [OPTIONS] COMMAND [ARGS]...
```

| Flag | Purpose |
|---|---|
| `--version` | Print the installed CLI version and exit |
| `--info` | Print JSON diagnostic info (version, Python, OS, config path) |
| `--help` | Show root-level help / list of command groups |
| `--config-file <path>` | Use a specific `config.toml` instead of the default location |
| `--install-completion` | Install shell autocompletion for the detected shell |
| `--show-completion` | Print the completion script for a given shell |

```bash
snow --help
```
```
Usage: snow [OPTIONS] COMMAND [ARGS]...

 Snowflake CLI tool for developers.

╭─ Commands ──────────────────────────────────────────────────────────╮
│ app         Manage Snowflake Native Apps                             │
│ bootstrap   Instantiate new projects from templates                  │
│ connection  Manage Snowflake connections                             │
│ cortex      Run Snowflake Cortex AI features                         │
│ custom-image  Validate/manage custom container images                │
│ dbt         Manage dbt Projects on Snowflake                         │
│ dcm         Manage DCM (declarative) projects                        │
│ git         Manage Git repository integrations                       │
│ helpers     Misc. helper/migration utilities                         │
│ init        Initialize a new project from a template                 │
│ logs        Retrieve structured logs                                 │
│ notebook    Manage Snowflake Notebooks                               │
│ object      Manage generic Snowflake objects                         │
│ snowpark    Manage Snowpark Python functions/procedures              │
│ spcs        Manage Snowpark Container Services                       │
│ sql         Execute SQL                                              │
│ stage       Manage stages and staged files                           │
│ streamlit   Manage Streamlit-in-Snowflake apps                       │
╰────────────────────────────────────────────────────────────────────╯
```

> **📌 Note**
> `snow init` is a convenience alias that maps to the `bootstrap` command group's `init` subcommand — both `snow init` and `snow bootstrap init` work identically.

---

## 1. `snow connection` — Connection Management

Fully documented in `02_Installation_and_Configuration.md` §5. Quick index:

| Command | Purpose |
|---|---|
| `snow connection add` | Create a new named connection |
| `snow connection list` | List connections |
| `snow connection set-default` | Change default connection |
| `snow connection test` | Test connectivity/auth |
| `snow connection remove` | Delete a connection |
| `snow connection generate-jwt` | Generate a key-pair JWT |
| `snow connection generate-workload-identity-token` | Generate a cloud workload identity token |

---

## 2. `snow sql` — SQL Execution

The single most-used command in the CLI. Executes ad-hoc queries, files, or piped stdin.

### Syntax
```
snow sql
  [--query|-q <query>]
  [--filename|-f <files>]
  [--stdin|-i]
  [--variable|-D <key=value>]
  [--retain-comments]
  [--single-transaction / --no-single-transaction]
  [--enable-templating <LEGACY|STANDARD|JINJA|ALL|NONE>]
  [--local-only]
  [--no-prompt-exit-repl]
  [-p, --project <project_definition>]
  [--env <key=value>]
  [--format <TABLE|JSON|JSON_EXT|CSV>]
  [--decimal-precision <int>]
  [connection & auth flags...]
```

### Key Options

| Flag | Purpose | Default |
|---|---|---|
| `-q, --query` | Inline query string | — |
| `-f, --filename` | One or more `.sql` files, executed sequentially on one connection | `[]` |
| `-i, --stdin` | Read query text from stdin (pipe-friendly) | `False` |
| `-D, --variable` | `key=value` client-side template substitution | — |
| `--retain-comments` | Keep `--` comments in output (stripped by default) | `False` |
| `--single-transaction` | Wrap statements in `BEGIN`/`COMMIT`, all-or-nothing | `False` |
| `--enable-templating` | Which templating syntax to resolve (`<% var %>` Jinja-style vs legacy `&var`) | `LEGACY,STANDARD` |
| `--local-only` | Block `!source`/`!load` from fetching remote `http(s)://` URLs | `False` |
| `--format` | `TABLE` (default), `JSON`, `JSON_EXT` (nested JSON, not stringified), `CSV` | `TABLE` |
| `--enhanced-exit-codes` | `0` success / `2` param error / `5` query error / `1` other | `False` |

### Examples

**Ad-hoc query**
```bash
snow sql -q "SELECT CURRENT_WAREHOUSE(), CURRENT_ROLE();"
```
```
+-----------------------------------------+
| CURRENT_WAREHOUSE() | CURRENT_ROLE()     |
|----------------------|--------------------|
| WH_DBT_DEV           | TRANSFORMER_DEV    |
+-----------------------------------------+
```

**Executing multiple files sequentially (ordered DDL deployment)**
```bash
snow sql -f ddl/01_create_schema.sql -f ddl/02_create_tables.sql -f ddl/03_grants.sql --connection prod
```

**Piping from stdin**
```bash
cat migrations/2026_07_add_column.sql | snow sql -i --connection prod
```

**Templated query with client-side variables**
```bash
snow sql -q "SELECT * FROM <% database %>.<% schema %>.orders LIMIT 10" \
  -D "database=ANALYTICS_DEV" -D "schema=STAGING"
```

**All-or-nothing multi-statement transaction**
```bash
snow sql --single-transaction -f release/2026_07_30_migration.sql --connection prod
```

**Interactive REPL** (no `-q`/`-f`/`-i` given)
```bash
snow sql
```
```
╭───────────────────────────────────────────────────────────────╮
│ Welcome to Snowflake-CLI REPL                                 │
│ Type 'exit' or 'quit' to leave                                │
╰───────────────────────────────────────────────────────────────╯
>
```

### When to Use
- Running migrations, DDL scripts, or ad-hoc diagnostic queries from CI/CD or a terminal.
- As the execution engine underneath home-grown migration frameworks.

### When Not to Use
- For managing the *lifecycle* of complex objects (Streamlit apps, Native Apps, Snowpark functions) — use the dedicated command groups (`snow streamlit`, `snow app`, `snow snowpark`) which handle artifact bundling/upload for you.
- For very large result sets you intend to process programmatically — prefer the Python Connector/Snowpark directly (see `06_Python_SDK_and_API.md`) to avoid TABLE-format parsing overhead.

### Performance Considerations
- `snow sql -f` executes files **sequentially on a single session** — for independent, parallelizable DDL across many files, consider launching multiple `snow sql` processes against different connections/warehouses, or use `snow dcm`/`snow dbt` project deployment which can leverage dependency graphs.
- `--single-transaction` disables autocommit — long transactions hold locks; keep the batch as small as practical for concurrent workloads.

### Common Mistakes
| Mistake | Fix |
|---|---|
| Combining `-q` and `-f` in one invocation | Invalid parameter combination — pick one input source per invocation |
| Assuming `$$` (SQL scripting block delimiter) works inline in bash/zsh | Shells interpret `$$` as PID; escape (`\$\$`) or move script to a `-f` file |
| Forgetting `--single-transaction` for multi-statement migrations | Partial writes on failure — always wrap related DDL/DML in a transaction |

### Related Commands
`snow object`, `snow stage execute`, `snow git execute`, `snow dbt execute`

---

## 3. `snow object` — Generic Object Management

Manages **any** Snowflake object type generically (tables, views, warehouses, roles, tasks, streams, functions, procedures, etc.) using `SHOW`/`DESCRIBE`/`CREATE`/`DROP` semantics under a uniform CLI surface.

| Command | Purpose |
|---|---|
| `snow object list <type>` | List objects of a given type (equivalent to `SHOW <TYPE>S`) |
| `snow object describe <type> <name>` | Describe a specific object |
| `snow object drop <type> <name>` | Drop an object |
| `snow object create <type> [key=value ...]` | Create simple objects generically |

### Syntax
```
snow object list <object_type>
  [--like <pattern>]
  [--in <scope> <name>]
  [--format <TABLE|JSON|CSV>]

snow object describe <object_type> <name>
snow object drop <object_type> <name>
snow object create <object_type> [<key>=<value> ...]
```

### `--like` and `--in` Scoping

```bash
snow object list warehouse --like "WH_DBT%"
```
```
+---------------------------------------------------------------+
| name        | state    | type      | size   | ...             |
|-------------|----------|-----------|--------|-----------------|
| WH_DBT_DEV  | STARTED  | STANDARD  | SMALL  | ...             |
| WH_DBT_PROD | SUSPENDED| STANDARD  | MEDIUM | ...             |
+---------------------------------------------------------------+
```

```bash
snow object list table --in schema ANALYTICS_DEV.STAGING
snow object list service --in compute-pool my_pool
```

### Examples

```bash
snow object list role --like "public%"
```
```
+-------------------------------------------------------------------------------+
| created_on                        | name        | is_default | is_current    |
|------------------------------------|-------------|------------|---------------|
| 2023-02-01 15:25:04.105000-08:00   | PUBLIC      | N          | N             |
| 2024-01-15 12:55:05.840000-08:00   | PUBLIC_TEST | N          | N             |
+-------------------------------------------------------------------------------+
```

```bash
snow object describe warehouse WH_DBT_PROD
snow object drop table ANALYTICS_DEV.STAGING.TMP_LOAD_STAGE
```

### Supported Object Types (non-exhaustive — grows with each Snowflake feature release)
`database`, `schema`, `table`, `view`, `materialized-view`, `dynamic-table`, `stage`, `file-format`, `warehouse`, `role`, `user`, `task`, `stream`, `pipe`, `function`, `procedure`, `sequence`, `network-policy`, `resource-monitor`, `notification-integration`, `storage-integration`, `api-integration`, `security-integration`, `streamlit`, `notebook`, `service`, `compute-pool`, `image-repository`, and more — run `snow object list --help` for the full enumerated type list on your installed version.

### When to Use
- Quick inventory/audit scripts (`snow object list table --in database PROD | ...`).
- Generic drop/cleanup automation (e.g., nightly TMP object reaper jobs).
- Anything that doesn't warrant a full project definition.

### When Not to Use
- Complex `CREATE` statements with many clauses (clustering keys, complex constraints) — use `snow sql -f` with a proper DDL script instead; `snow object create` is best for simple key/value object creation.

### Related Commands
`snow sql`, `snow stage`, `snow git list`

---

## 4. `snow stage` — Stage Management

Manages internal/external stages and the files within them.

| Command | Purpose |
|---|---|
| `snow stage create` | Create a new stage |
| `snow stage list` | List stages (like `SHOW STAGES`) |
| `snow stage describe` | Describe a stage |
| `snow stage drop` | Drop a stage |
| `snow stage list-files` | List files inside a stage (like `LIST @stage`) |
| `snow stage copy` | Upload (PUT) or download (GET) files to/from a stage |
| `snow stage remove` | Remove (delete) a staged file |
| `snow stage execute` | Execute SQL file(s) stored on a stage |

### `snow stage create`
```bash
snow stage create @raw_landing --connection dev
```
```
Stage RAW_LANDING successfully created.
```

### `snow stage copy` (Upload / Download)

**Upload (PUT)** — local → stage:
```bash
snow stage copy ./data/2026-07-30/*.parquet @raw_landing/2026-07-30/ --connection dev
```
```
+--------------------------------------------------------------------------------+
| source                  | target                       | status  | message    |
|--------------------------|------------------------------|---------|------------|
| orders_2026_07_30.parquet| orders_2026_07_30.parquet.gz | UPLOADED| ...        |
+--------------------------------------------------------------------------------+
```

**Download (GET)** — stage → local:
```bash
snow stage copy @raw_landing/2026-07-30/ ./downloaded/ --connection dev
```

> **📌 Note**
> Direction is inferred automatically: if the **first** path is local and the second begins with `@`, it's an upload; if the first begins with `@`, it's a download. This mirrors `PUT`/`GET` SQL semantics.

### `snow stage list-files`
```bash
snow stage list-files @raw_landing/2026-07-30/
```
```
+-----------------------------------------------------------------------------+
| name                                    | size  | md5                | ...  |
|------------------------------------------|-------|--------------------|------|
| raw_landing/2026-07-30/orders.parquet.gz | 88213 | 9f8c1e...          | ...  |
+-----------------------------------------------------------------------------+
```

### `snow stage execute`
Runs one or more SQL scripts that live **on the stage itself** (useful for Native Apps and Git-repo-backed deployments):
```bash
snow stage execute @deploy_scripts/release_2026_07.sql --connection prod
```

### `snow stage remove`
```bash
snow stage remove @raw_landing/2026-07-30/orders_bad.parquet
```

### Internal vs. External Stage Comparison

| DIMENSIONS | Internal Stage | External Stage |
|---|---|---|
| Storage location | Managed by Snowflake | Customer-owned cloud bucket (S3/Azure Blob/GCS) |
| Setup | `CREATE STAGE` — zero extra config | Requires a **Storage Integration** (`CREATE STORAGE INTEGRATION`) with cloud IAM trust |
| Access from outside Snowflake | Only via Snowflake clients (`snow stage copy`, drivers) | Directly accessible via native cloud tools too |
| Typical use | Snowpark code artifacts, Native App packages, ad-hoc file staging | Data lake ingestion, landing zones shared with non-Snowflake systems |
| Cost model | Included in Snowflake storage billing | Billed by cloud provider directly; Snowflake reads/writes via integration |
| CLI commands | `snow stage *` (full support) | `snow stage *` (full support — external stages behave identically to CLI once created) |

### Common Mistakes
| Mistake | Fix |
|---|---|
| Forgetting the `@` prefix on stage paths | `snow stage list-files raw_landing` → error; use `@raw_landing` |
| Uploading without a trailing `/` when targeting a "directory" prefix | Some shells glob differently — always test with `list-files` after upload |
| Not compressing before upload for large CSV loads | Snowflake auto-gzips on PUT by default; verify with `list-files` that `.gz` suffix appears as expected |

### Related Commands
`snow object list stage`, `snow sql` (for `COPY INTO`), `snow git` (Git-repo stages)

---

## 5. `snow git` — Git Repository Integration

Manages Snowflake **Git Repository** integration objects — Git repos registered as first-class Snowflake objects, enabling direct execution of SQL/Python straight from a Git ref without a separate CI checkout step.

| Command | Purpose |
|---|---|
| `snow git setup` | Interactive wizard to register a Git repository with Snowflake (creates API integration + repository object) |
| `snow git list` | List registered Git repositories |
| `snow git list-branches` | List branches in a repository |
| `snow git list-tags` | List tags in a repository |
| `snow git list-files` | List files at a given ref/path |
| `snow git fetch` | Fetch latest changes from the remote into the Snowflake-side repository object |
| `snow git copy` | Copy files from a repo ref to a stage or local path |
| `snow git execute` | Execute a SQL/Python file directly from a repo ref |
| `snow git describe` | Describe a repository object |
| `snow git drop` | Drop a repository integration |

### `snow git setup`
```bash
snow git setup my_repo --connection dev
```
```
URL of the repository: https://github.com/my-org/analytics-platform
API integration to use (existing or new): github_api_integration
Secret for authentication (if private repo): github_pat_secret
Repository "MY_REPO" successfully created.
```

### `snow git fetch` and `snow git execute`
```bash
snow git fetch @my_repo
snow git execute "@my_repo/branches/main/sql/deploy/release.sql" --connection prod
```
```
Fetched repository MY_REPO.
Executing @my_repo/branches/main/sql/deploy/release.sql ...
Statement executed successfully.
```

### `snow git copy`
```bash
snow git copy "@my_repo/branches/release-2026-07/dbt_project/*" ./local_dbt_project/
```

### `snow git list-branches`
```bash
snow git list-branches my_repo
```
```
+--------------------------------------------------------------+
| name                | path                                  |
|----------------------|---------------------------------------|
| main                 | branches/main                        |
| release-2026-07      | branches/release-2026-07             |
+--------------------------------------------------------------+
```

### When to Use
- CI/CD pipelines where you want Snowflake to pull directly from GitHub/GitLab/Azure Repos/Bitbucket without staging files through an external runner first.
- Native App and DCM/dbt project deployments sourced straight from a Git ref (`@my_repo/branches/main/...`), guaranteeing prod always deploys exactly what's committed.

### When Not to Use
- If your org's security policy forbids Snowflake from having outbound Git connectivity — use `snow stage copy` from a CI-side checkout instead.

### Common Mistakes
| Mistake | Fix |
|---|---|
| Forgetting `snow git fetch` before referencing new commits | Repository objects are a **cached** view of the remote — always fetch before deploying |
| Using `main` branch path without the `branches/` prefix | Correct form is `@repo/branches/<branch>/...`, not `@repo/main/...` |

### Related Commands
`snow app`, `snow dbt`, `snow dcm`, `snow stage execute`

---

## 6. `snow snowpark` — Snowpark Python UDFs/UDTFs/Procedures

Builds, packages, and deploys Python functions and stored procedures to Snowflake as Snowpark objects.

| Command | Purpose |
|---|---|
| `snow snowpark build` | Build the local artifact (zip Python source + dependencies) |
| `snow snowpark deploy` | Deploy built artifacts as UDFs/UDTFs/procedures in Snowflake |
| `snow snowpark execute` | Invoke a deployed function/procedure |
| `snow snowpark list` | List deployed Snowpark objects |
| `snow snowpark describe` | Describe a deployed object |
| `snow snowpark drop` | Drop a deployed object |
| `snow snowpark package *` | Manage Python package dependencies (subgroup below) |

### Project Definition (`snowflake.yml`)
```yaml
definition_version: "2"
entities:
  clean_orders_udf:
    type: function
    handler: "functions.clean_orders"
    signature:
      - name: "raw_json"
        type: "variant"
    returns: "variant"
    runtime: "3.11"
    stage: dev_deployment
    artifacts:
      - src: "src/*.py"
        dest: "./"
  load_orders_sp:
    type: procedure
    handler: "procedures.load_orders"
    signature:
      - name: "batch_date"
        type: "string"
    returns: "string"
    runtime: "3.11"
    stage: dev_deployment
    artifacts:
      - src: "src/*.py"
        dest: "./"
```

### Build and Deploy
```bash
snow snowpark build --project ./snowpark_project
```
```
Building deployment artifact...
Artifact built at: .snowpark/app.zip
```

```bash
snow snowpark deploy --project ./snowpark_project --connection dev
```
```
+---------------------------------------------------------------------------+
| object            | type      | status                                   |
|--------------------|-----------|------------------------------------------|
| CLEAN_ORDERS_UDF   | function  | created                                  |
| LOAD_ORDERS_SP     | procedure | created                                  |
+---------------------------------------------------------------------------+
```

Re-running `deploy` after a code change performs a `CREATE OR REPLACE` by default; use `--replace` explicitly where the CLI version requires it, and `--no-validate` to skip local signature validation in constrained CI runners.

### `snow snowpark execute`
```bash
snow snowpark execute function "CLEAN_ORDERS_UDF(PARSE_JSON('{\"id\":1}'))" --connection dev
```

### 6.1 `snow snowpark package` Subgroup

| Command | Purpose |
|---|---|
| `snow snowpark package lookup` | Check whether a PyPI package is available in Snowflake Anaconda channel |
| `snow snowpark package create` | Bundle a non-Anaconda-available pure-Python package into a zip for manual upload |
| `snow snowpark package upload` | Upload a bundled package zip to a stage for use as an `IMPORTS` dependency |

```bash
snow snowpark package lookup pandas
```
```
Package pandas is available on the Anaconda channel.
You can use it in the project definition without further action.
```

```bash
snow snowpark package lookup my-internal-lib
```
```
Package my-internal-lib is NOT available on the Anaconda channel.
Consider using "snow snowpark package create" to create a zip package.
```

```bash
snow snowpark package create my-internal-lib
snow snowpark package upload my-internal-lib.zip @dev_deployment/packages/
```

### When to Use
- Deploying reusable, versioned business logic (UDFs/procedures) as governed, callable Snowflake objects — the backbone of "push compute to the data" ELT patterns.

### When Not to Use
- For one-off ad-hoc Python analysis — use a Notebook (`snow notebook`) or local Snowpark session instead of formally deploying a UDF.
- For long-running containerized workloads — use SPCS (`snow spcs`) rather than a UDF/procedure, which has execution time and resource ceilings.

### Performance Considerations
- Cold-start latency for Python UDFs includes package import time — keep `IMPORTS` minimal and prefer vectorized (batch) UDFs for row-heavy workloads.
- `snow snowpark build` caches unchanged dependency layers where supported — avoid unnecessary `--clean` rebuilds in CI to save pipeline minutes.

### Related Commands
`snow object list function`, `snow stage`, `snow spcs`

---

## 7. `snow app` — Snowflake Native App Framework

Manages the full Native App development lifecycle: bundling, versioning, publishing, and release management.

| Command | Purpose |
|---|---|
| `snow app setup` | Scaffold a new `snowflake.yml` for a Native App project |
| `snow app bundle` | Assemble local artifacts into the app package structure without deploying |
| `snow app deploy` | Deploy the app package (and optionally the application object) to Snowflake |
| `snow app run` | Deploy + create/upgrade the application object in one step (dev loop) |
| `snow app open` | Open the running app in the browser (Streamlit-based Native Apps) |
| `snow app events` | Retrieve app telemetry/log events |
| `snow app validate` | Validate `setup_script.sql`/manifest without deploying |
| `snow app teardown` | Drop the application object and/or application package |
| `snow app publish` | Publish a version/patch to the Snowflake Marketplace or a private listing |
| `snow app version *` | Manage app package versions (subgroup: `create`, `drop`, `list`) |
| `snow app release-channel *` | Manage release channels (subgroup: `add-accounts`, `remove-accounts`, `list`, `set-default`) |
| `snow app release-directive *` | Manage release directives controlling which version/patch consumers receive |

### Typical Dev Loop
```bash
snow app run --connection dev
```
```
Bundling artifacts...
Uploading artifacts to stage APP_PKG_DEV.APP_SRC.APP_STAGE ...
Creating application package MY_NATIVE_APP_PKG ...
Creating application MY_NATIVE_APP ...
Your application object (MY_NATIVE_APP) is now available:
https://app.snowflake.com/myorg/devaccount/#/apps/application/MY_NATIVE_APP
```

```bash
snow app open --connection dev
```

### Versioning & Release for Production
```bash
snow app version create v1_2_0 --connection prod
snow app release-directive set --version v1_2_0 --patch 0 --channel DEFAULT --connection prod
```

### `snow app teardown`
```bash
snow app teardown --connection dev
```
```
Dropping application MY_NATIVE_APP...
Dropping application package MY_NATIVE_APP_PKG...
Teardown complete.
```

> **⚠️ Warning**
> `snow app teardown` is destructive against the **application object and/or package**. Never run against `prod` connections without an explicit `--force`/confirmation step in your pipeline, and never point a teardown command at a connection alias you haven't triple-checked.

### When to Use
- Building installable, listable products for Snowflake Marketplace / Provider Studio / cross-account private listings.
- Encapsulating business logic + UI (via embedded Streamlit) + data schema behind a controlled, versioned setup script.

### When Not to Use
- For internal-only dashboards with a single consumer account — a plain `snow streamlit deploy` is far simpler and avoids Native App packaging overhead.

### Related Commands
`snow streamlit`, `snow stage`, `snow git`

---

## 8. `snow streamlit` — Streamlit-in-Snowflake Apps

| Command | Purpose |
|---|---|
| `snow streamlit deploy` | Upload app files and create/update the Streamlit object |
| `snow streamlit list` | List deployed Streamlit apps |
| `snow streamlit describe` | Describe a Streamlit app |
| `snow streamlit drop` | Drop a Streamlit app |
| `snow streamlit execute` | Run a Streamlit app's Python entrypoint headlessly (validation) |
| `snow streamlit get-url` | Print the app's Snowsight URL |
| `snow streamlit logs` | Retrieve app runtime logs |
| `snow streamlit share` | Grant another role/account access to the app |

### `snowflake.yml` for Streamlit
```yaml
definition_version: "2"
entities:
  sales_dashboard:
    type: streamlit
    identifier: SALES_DASHBOARD
    main_file: streamlit_app.py
    query_warehouse: WH_STREAMLIT
    stage: streamlit_stage
    artifacts:
      - streamlit_app.py
      - environment.yml
      - pages/
```

### Deploy
```bash
snow streamlit deploy --connection dev
```
```
Uploading artifacts...
streamlit_app.py -> @streamlit_stage/sales_dashboard/streamlit_app.py
Streamlit app "SALES_DASHBOARD" deployed successfully.
Use "snow streamlit get-url" to open it.
```

```bash
snow streamlit get-url sales_dashboard --connection dev
```
```
https://app.snowflake.com/myorg/devaccount/#/streamlit-apps/ANALYTICS_DEV.PUBLIC.SALES_DASHBOARD
```

### Sharing
```bash
snow streamlit share sales_dashboard --role BI_ANALYST_ROLE --connection dev
```

### When to Use
- Rapid internal data-app delivery on top of governed Snowflake data with zero separate hosting infrastructure.

### When Not to Use
- Public-facing, high-traffic consumer apps needing custom auth/branding beyond Snowsight embedding — use a standalone Streamlit deployment (outside Snowflake) or a Native App with a more custom frontend.

### Related Commands
`snow app` (Streamlit can be embedded inside a Native App), `snow stage`

---

## 9. `snow notebook` — Snowflake Notebooks

| Command | Purpose |
|---|---|
| `snow notebook create` | Create a new notebook object from a local `.ipynb` |
| `snow notebook deploy` | Upload/update notebook content |
| `snow notebook execute` | Run a notebook end-to-end (headless execution, e.g., in a scheduled Task) |
| `snow notebook get-url` | Print the notebook's Snowsight URL |
| `snow notebook open` | Open the notebook in a browser |

> List existing notebooks with `snow object list notebook` (there is no separate `snow notebook list`).

```bash
snow notebook deploy my_analysis.ipynb --connection dev
```
```
Notebook "MY_ANALYSIS" deployed to ANALYTICS_DEV.PUBLIC.
```

```bash
snow notebook execute MY_ANALYSIS --connection prod
```
```
Executing notebook MY_ANALYSIS ...
All cells executed successfully.
```

### When to Use
- Interactive, cell-by-cell EDA and model prototyping directly against Snowflake data/warehouses.
- Scheduling notebook execution as a lightweight ELT/reporting job (`snow notebook execute` wrapped in a Task or external scheduler).

### When Not to Use
- Production, mission-critical pipelines — prefer Tasks/dynamic tables/dbt models with proper testing, not notebook execution, for anything beyond reporting jobs.

### Related Commands
`snow object list notebook`, `snow stage`

---

## 10. `snow spcs` — Snowpark Container Services

Four subgroups: `image-registry`, `image-repository`, `compute-pool`, `service`.

### 10.1 `snow spcs image-registry`
| Command | Purpose |
|---|---|
| `snow spcs image-registry login` | Authenticate Docker CLI against Snowflake's image registry |
| `snow spcs image-registry token` | Print a registry auth token (for scripted `docker login`) |
| `snow spcs image-registry url` | Print the registry hostname URL |

```bash
snow spcs image-registry login --connection dev
```
```
Login Succeeded
```

### 10.2 `snow spcs image-repository`
| Command | Purpose |
|---|---|
| `snow spcs image-repository create` | Create an image repository |
| `snow spcs image-repository list` | List repositories |
| `snow spcs image-repository list-images` | List images within a repository |
| `snow spcs image-repository list-tags` | List tags for an image |
| `snow spcs image-repository url` | Print the repository's push/pull URL |
| `snow spcs image-repository drop` | Drop a repository |

```bash
snow spcs image-repository create my_repo --connection dev
REPO_URL=$(snow spcs image-repository url my_repo --connection dev)
docker tag my_app:latest "$REPO_URL/my_app:latest"
docker push "$REPO_URL/my_app:latest"
```

### 10.3 `snow spcs compute-pool`
| Command | Purpose |
|---|---|
| `snow spcs compute-pool create` | Create a compute pool |
| `snow spcs compute-pool deploy` | Create/update from a project definition |
| `snow spcs compute-pool describe` | Describe a pool |
| `snow spcs compute-pool status` | Show current status/node counts |
| `snow spcs compute-pool set` / `unset` | Modify pool parameters |
| `snow spcs compute-pool resume` / `suspend` | Start/stop billing for the pool |
| `snow spcs compute-pool stop-all` | Force-stop all services on the pool |
| `snow spcs compute-pool drop` | Drop the pool |

```bash
snow spcs compute-pool create ml_pool \
  --family GPU_NV_S \
  --min-nodes 1 --max-nodes 3 \
  --auto-resume --connection dev
```
```
Compute pool ML_POOL successfully created.
```

### 10.4 `snow spcs service`
| Command | Purpose |
|---|---|
| `snow spcs service create` | Create a service from a service spec YAML |
| `snow spcs service deploy` | Create/update from project definition |
| `snow spcs service status` | Show service/container status |
| `snow spcs service list` | List services |
| `snow spcs service list-containers` / `list-endpoints` / `list-instances` / `list-roles` | Inspect running topology |
| `snow spcs service logs` | Stream/retrieve container logs |
| `snow spcs service events` | Retrieve platform events |
| `snow spcs service metrics` | Retrieve resource utilization metrics |
| `snow spcs service execute-job` | Run a one-shot job service (batch execution) |
| `snow spcs service set` / `unset` | Modify service parameters |
| `snow spcs service resume` / `suspend` | Start/stop a service |
| `snow spcs service upgrade` | Roll out a new spec/image version |
| `snow spcs service drop` | Drop a service |

```bash
snow spcs service create inference_svc \
  --compute-pool ml_pool \
  --spec-path ./service_spec.yaml \
  --min-instances 1 --max-instances 2 \
  --connection dev
```
```
Service INFERENCE_SVC successfully created.
```

```bash
snow spcs service logs inference_svc --container-name inference --connection dev
```
```
2026-07-30T10:14:02Z [INFO] Model loaded, listening on :8080
2026-07-30T10:14:05Z [INFO] Health check OK
```

```bash
snow spcs service execute-job batch_scoring_job \
  --compute-pool ml_pool \
  --spec-path ./job_spec.yaml \
  --connection prod
```

### Comparison: Tasks vs. SPCS Services

| DIMENSIONS | Snowflake Task | SPCS Service |
|---|---|---|
| Execution model | Scheduled SQL/procedure call | Long-running or job-based container |
| Language flexibility | SQL, Snowpark (Python/Java/Scala) | Any language, any Docker image |
| GPU support | ❌ | ✅ (`GPU_NV_*` families) |
| Best for | Scheduled ELT (dynamic table refresh, batch load) | Custom ML inference, third-party apps, non-SQL workloads |
| CLI management | `snow object`, `snow sql` (`CREATE TASK`) | `snow spcs *` |

### When to Use SPCS
- Deploying custom ML inference servers, third-party containerized apps, or GPU workloads directly inside Snowflake's security perimeter (data never leaves).

### When Not to Use
- Simple scheduled SQL transformations — a Task or Dynamic Table is far cheaper and simpler than standing up a compute pool.

### Related Commands
`snow custom-image validate`, `snow object`, `snow logs`

---

## 11. `snow dbt` — dbt Projects on Snowflake

Manages **Snowflake-native dbt Projects** — dbt projects registered and executed as first-class Snowflake objects (distinct from running dbt Core externally against Snowflake, covered in `05_Data_Engineering_Workflow.md`).

| Command | Purpose |
|---|---|
| `snow dbt deploy` | Upload a local dbt project and register/update the dbt Project object |
| `snow dbt list` | List registered dbt Project objects |
| `snow dbt describe` | Describe a dbt Project object |
| `snow dbt drop` | Drop a dbt Project object |
| `snow dbt execute *` | Subgroup for executing dbt commands (`run`, `test`, `build`, `seed`, etc.) against the deployed project |

```bash
snow dbt deploy analytics_dbt --path ./dbt_project --connection dev
```
```
Uploading dbt project files...
dbt Project "ANALYTICS_DBT" deployed successfully.
```

```bash
snow dbt execute run analytics_dbt --connection prod
```
```
Running with dbt=1.9.0
Found 42 models, 118 tests, 6 sources
Completed successfully
Done. PASS=42 WARN=0 ERROR=0 SKIP=0 TOTAL=42
```

```bash
snow dbt execute test analytics_dbt --select "tag:critical" --connection prod
```

### When to Use
- You want dbt execution to happen **inside** Snowflake's compute (no external orchestrator container needed) and want the project itself governed as a Snowflake object with RBAC.

### When Not to Use
- If your org already has a mature external orchestration layer (Airflow/Dagster/dbt Cloud) — external dbt-core execution (see `05_Data_Engineering_Workflow.md` §6) may fit existing operational tooling better.

### Related Commands
`snow dcm`, `snow git`, `snow sql`

---

## 12. `snow dcm` — Declarative Project Management (DCM)

> **Preview feature.** Requires `enable_snowflake_projects = true` under `[cli.features]` in `config.toml`, or `SNOWFLAKE_CLI_FEATURES_ENABLE_SNOWFLAKE_PROJECTS=true`.

DCM (Declarative Configuration Management) Projects let you define a target Snowflake object-state declaratively (via `manifest.yml` + SQL/Jinja source) and have Snowflake compute and apply a plan/diff — conceptually similar to Terraform, but native to Snowflake.

| Command | Purpose |
|---|---|
| `snow dcm create` | Create a new DCM Project object |
| `snow dcm deploy` | Apply the project definition — deploy the declared state |
| `snow dcm plan` | Compute and display a plan (diff) without applying |
| `snow dcm preview` | Preview generated SQL for a deployment |
| `snow dcm test` | Run project-defined tests |
| `snow dcm describe` | Describe a project |
| `snow dcm list` | List DCM Projects |
| `snow dcm list-deployments` | List historical deployments of a project |
| `snow dcm drop-deployment` | Roll back / remove a specific deployment record |
| `snow dcm purge` | Drop all objects managed by a project (without dropping the project object itself) |
| `snow dcm drop` | Drop the DCM Project object |

### Project Identifier Resolution
1. Explicit identifier argument, if given.
2. Else `--target <name>` resolves `project_name` from that target block in `manifest.yml`.
3. Else `default_target` from `manifest.yml`.

```bash
snow dcm plan --target DEV --from ./infra_project
```
```
Plan: 3 to add, 1 to change, 0 to destroy.

  + TABLE ANALYTICS_DEV.CORE.CUSTOMERS
  + TASK  ANALYTICS_DEV.CORE.REFRESH_CUSTOMERS
  ~ WAREHOUSE WH_CORE (size: SMALL -> MEDIUM)
  + DYNAMIC TABLE ANALYTICS_DEV.CORE.CUSTOMER_360
```

```bash
snow dcm deploy --target PROD --from ./infra_project
```
```
Applying plan...
TABLE ANALYTICS_PROD.CORE.CUSTOMERS created.
WAREHOUSE WH_CORE altered.
Deployment DEPLOYMENT_2026_07_30_101502 recorded.
```

```bash
snow dcm list-deployments MY_DB.MY_SCHEMA.MY_PROJECT
snow dcm purge MY_DB.MY_SCHEMA.MY_PROJECT --connection dev
```

### DCM vs. dbt vs. Dynamic Tables — When to Use Which

| Tool | Best for | Not ideal for |
|---|---|---|
| **DCM** | Declarative infra-as-code for Snowflake objects (warehouses, roles, tasks, grants) with plan/diff workflow | Complex row-level SQL transformation logic, testing frameworks |
| **dbt** | SQL transformation logic, data modeling, lineage, tests | Non-table objects — warehouses, roles, network policies |
| **Dynamic Tables** | Declarative, incrementally-refreshed transformation *pipelines* | Full infra provisioning (users, roles, integrations) |

### Related Commands
`snow dbt`, `snow sql`, `snow object`

---

## 13. `snow cortex` — Snowflake Cortex AI Functions from the CLI

| Command | Purpose |
|---|---|
| `snow cortex complete` | Run an LLM text-completion prompt |
| `snow cortex summarize` | Summarize input text |
| `snow cortex translate` | Translate text between languages |
| `snow cortex sentiment` | Score sentiment of input text |
| `snow cortex extract-answer` | Extract an answer to a question from a text passage |

```bash
snow cortex complete "Write a one-sentence summary of dynamic tables in Snowflake" --model llama3.1-70b
```
```
Dynamic tables in Snowflake automatically and incrementally refresh
materialized query results on a defined schedule without manual pipeline code.
```

```bash
snow cortex sentiment "The new pipeline cut our load times in half!"
```
```
0.86
```

```bash
echo "Long support ticket text..." | snow cortex summarize --stdin
```

### When to Use
- Quick terminal-based prototyping of Cortex functions before embedding them in SQL pipelines (`SNOWFLAKE.CORTEX.COMPLETE(...)`).
- Lightweight scripting/automation (e.g., a CI job that summarizes a changelog using Cortex).

### When Not to Use
- High-throughput production inference — call the underlying SQL functions directly from a Task/Stream/Dynamic Table pipeline instead of shelling out to the CLI per row.

### Related Commands
`snow sql`, `snow notebook`

---

## 14. `snow custom-image` — Custom Container Image Validation

| Command | Purpose |
|---|---|
| `snow custom-image validate` | Validate a Dockerfile/image against SPCS compatibility rules |

```bash
snow custom-image validate ./Dockerfile --scan-vulnerabilities --connection dev
```
```
Validating custom image rules: entrypoint OK, env vars OK, package health OK.
Running Grype vulnerability scan...
0 CRITICAL, 2 HIGH, 5 MEDIUM vulnerabilities found.
See full report: ./custom_image_validation_report.json
```

### When to Use
- Pre-flight validation before pushing a custom image to an SPCS image repository, catching entrypoint/env-var misconfigurations and known CVEs early in CI.

### Related Commands
`snow spcs image-repository`, `snow spcs service`

---

## 15. `snow logs` — Structured Log Retrieval

| Command | Purpose |
|---|---|
| `snow logs` | Retrieve structured logs emitted by functions/procedures/services (via `SYSTEM$` log tracing or event tables) |

```bash
snow logs --object-type function --object-name CLEAN_ORDERS_UDF --since "1 hour" --connection prod
```
```
2026-07-30T09:58:11Z [INFO] Processing batch of 4,200 rows
2026-07-30T09:58:12Z [WARN] 3 rows failed schema validation, quarantined
```

### Related Commands
`snow spcs service logs`, `snow streamlit logs`

---

## 16. `snow helpers` — Migration & Diagnostic Utilities

| Command | Purpose |
|---|---|
| `snow helpers import-snowsql-connections` | Import connections from a legacy SnowSQL config |
| `snow helpers check-snowsql-env-vars` | Detect legacy SnowSQL environment variables that may conflict |
| `snow helpers detect-encoding` | Detect file text encoding (useful for non-UTF-8 SQL files) |
| `snow helpers generate-project-schema` | Emit the JSON Schema for `snowflake.yml`, useful for IDE validation |
| `snow helpers v1-to-v2` | Migrate a `definition_version: 1` project file to `2` |

```bash
snow helpers v1-to-v2 --project ./legacy_project
```
```
Migrating snowflake.yml from definition_version 1 to 2...
Backup saved as snowflake.yml.v1.bak
Migration complete.
```

```bash
snow helpers generate-project-schema > snowflake.schema.json
```

### Related Commands
`snow init`, `snow connection`

---

## 17. `snow bootstrap` (`snow init`) — Project Scaffolding

| Command | Purpose |
|---|---|
| `snow init` (alias: `snow bootstrap init`) | Scaffold a new project directory from a built-in or custom template |

```bash
snow init my_project --template-name streamlit-python
```
```
Fetching template "streamlit-python"...
Project created in ./my_project
Next steps:
  cd my_project
  snow streamlit deploy
```

Fully documented with custom-template usage in `02_Installation_and_Configuration.md` §10.

---

## 18. Command Group Quick-Index Table

| Group | Object Domain | File Section |
|---|---|---|
| `connection` | Auth/connectivity | `02` §5 |
| `sql` | Raw SQL execution | `03` §2 |
| `object` | Generic object CRUD | `03` §3 |
| `stage` | Stages & file transfer | `03` §4 |
| `git` | Git repo integration | `03` §5 |
| `snowpark` | Python UDF/UDTF/Procedure | `03` §6 |
| `app` | Native Apps | `03` §7 |
| `streamlit` | Streamlit-in-Snowflake | `03` §8 |
| `notebook` | Notebooks | `03` §9 |
| `spcs` | Containers/GPU workloads | `03` §10 |
| `dbt` | Native dbt Projects | `03` §11 |
| `dcm` | Declarative IaC projects | `03` §12 |
| `cortex` | AI/LLM functions | `03` §13 |
| `custom-image` | Container image validation | `03` §14 |
| `logs` | Log retrieval | `03` §15 |
| `helpers` | Migration utilities | `03` §16 |
| `bootstrap` / `init` | Project scaffolding | `03` §17 |

Continue to **`04_Database_Administration.md`** to apply these commands to core Snowflake administration.