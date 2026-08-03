# Snowflake CLI Mastery Guide

## 02 — Installation and Configuration

---

## 1. Prerequisites

| Requirement | Detail |
|---|---|
| Python | 3.10+ (only if installing via `pip`/`pipx`/`uv`; not needed for the binary installer) |
| OS | macOS, Linux (glibc-based), Windows 10/11 |
| Network | Outbound HTTPS (443) to your Snowflake account URL |
| Snowflake account | A role with sufficient privileges for the objects you intend to manage |

> **📌 Note**
> The distribution package is published as `snowflake-cli` on PyPI (the older, deprecated experimental package was `snowflake-cli-labs`, now superseded). If you see tutorials referencing `snowflake-cli-labs`, treat them as historical — install `snowflake-cli` instead.

---

## 2. Installation Methods

### 2.1 Standalone Binary Installer (recommended for most users)

Snowflake publishes signed, self-contained installers for macOS, Windows, and Linux — no local Python environment required.

```bash
# macOS / Linux — download & run the platform installer from Snowflake's
# official downloads page, then verify:
snow --version
```

```
Snowflake CLI version: 3.7.0
```

### 2.2 Homebrew (macOS)

```bash
brew tap snowflakedb/snowflake-cli
brew install snowflake-cli
snow --version
```

### 2.3 `uv` (fast, isolated — recommended for engineers already using `uv`)

```bash
uv tool install snowflake-cli
snow --help
```

### 2.4 `pipx` (isolated virtual environment, no dependency conflicts)

```bash
pipx install snowflake-cli
snow --version
```

### 2.5 `pip` (not recommended for daily-driver use — pollutes active environment)

```bash
pip install snowflake-cli --break-system-packages   # if using system Python
snow --version
```

> **⚠️ Warning**
> Installing via plain `pip` into a shared or system Python environment risks dependency collisions with other tooling (e.g., `dbt-core`, `apache-airflow`). Prefer `pipx` or `uv tool install`, which create isolated environments automatically.

### 2.6 Docker / FIPS-Compliant Containers

For regulated environments requiring FIPS-validated cryptography:

```bash
pip install cryptography==44.0.3 --no-binary cryptography
pip install -U snowflake-connector-python[secure-local-storage] --no-binary snowflake-connector-python
pip install -U snowflake-cli --no-binary snowflake-cli
```

`--no-binary` forces a from-source build against your container's FIPS-enabled OpenSSL library rather than using pre-built wheels.

### 2.7 Comparison of Installation Methods

| Method | Isolation | Auto-updatable | Best for |
|---|---|---|---|
| Binary installer | Full (self-contained) | Manual re-download | Non-Python users, workstation installs |
| Homebrew | Full | `brew upgrade` | macOS developers |
| `uv tool install` | Full (venv) | `uv tool upgrade` | Engineers already on `uv` |
| `pipx` | Full (venv) | `pipx upgrade` | Python-centric teams |
| `pip` (global) | ❌ None | `pip install -U` | CI containers with disposable environments only |
| Docker (from source) | Full (image) | Rebuild image | FIPS/regulated environments |

---

## 3. Verifying Installation

```bash
snow --version
snow --info
```

`--info` returns a JSON payload with CLI version, Python version, OS, and **the resolved path to your `config.toml`** — the single most useful diagnostic command when something "works on my machine but not in CI."

```json
[
  {"key": "version", "value": "3.7.0"},
  {"key": "default_config_file_path", "value": "/home/jdoe/.snowflake/config.toml"},
  {"key": "python_version", "value": "3.11.9"},
  {"key": "system_info", "value": "Linux-6.8.0-x86_64"}
]
```

---

## 4. Configuration File: `config.toml`

Snowflake CLI stores connection definitions and CLI-wide settings in a **TOML** file. On first run, if no config file exists, `snow` auto-creates an empty one.

### 4.1 Default Location by OS

| OS | Default Path |
|---|---|
| macOS / Linux | `~/.snowflake/config.toml` (or XDG-based `~/.config/snowflake/config.toml` if `~/.snowflake` doesn't exist) |
| Windows | `%USERPROFILE%\.snowflake\config.toml` |

You can override the directory entirely with the `SNOWFLAKE_HOME` environment variable.

### 4.2 File Permissions Requirement (macOS/Linux)

Snowflake CLI **enforces** that `config.toml` is readable/writable only by its owner:

```bash
chmod 0600 ~/.snowflake/config.toml
```

If permissions are too open, `snow` will refuse to read the file and raise a permissions error.

### 4.3 Anatomy of `config.toml`

```toml
default_connection_name = "dev"

[connections.dev]
account   = "myorg-devaccount"
user      = "svc_dbt_dev"
role      = "TRANSFORMER_DEV"
warehouse = "WH_DBT_DEV"
database  = "ANALYTICS_DEV"
schema    = "PUBLIC"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "/home/jdoe/.ssh/snowflake_dev_rsa_key.p8"

[connections.prod]
account   = "myorg-prodaccount"
user      = "svc_dbt_prod"
role      = "TRANSFORMER_PROD"
warehouse = "WH_DBT_PROD"
database  = "ANALYTICS_PROD"
schema    = "PUBLIC"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "/home/jdoe/.ssh/snowflake_prod_rsa_key.p8"

[cli.logs]
save_logs = true
level     = "info"
path      = "/home/jdoe/.snowflake/logs"

[cli.features]
enable_separate_authentication_policy_id = true
```

> **📌 Note — `connections.toml` vs. `config.toml`**
> If you also use the raw Snowflake Python Connector (`connections.toml`, typically at `~/.snowflake/connections.toml` or `~/.config/snowflake/connections.toml`), Snowflake CLI will read connection definitions from **that file instead of `config.toml`** if both exist — `connections.toml` takes precedence for connection data, while `default_connection_name` is *always* read from `config.toml`. Avoid maintaining both simultaneously; pick one source of truth per machine.

### 4.4 Multiple Named Connections (Dev / Staging / Prod)

Define as many `[connections.<name>]` blocks as you need. Select one at runtime:

```bash
snow sql -q "select current_warehouse()" --connection prod
snow sql -q "select current_warehouse()" -c dev
```

---

## 5. `snow connection` Command Group

| Command | Purpose |
|---|---|
| `snow connection add` | Interactively (or non-interactively) create a new named connection |
| `snow connection list` | List all connections defined in `config.toml` / `connections.toml` |
| `snow connection set-default` | Change the default connection used when `--connection` is omitted |
| `snow connection test` | Validate that a connection can authenticate and reach Snowflake |
| `snow connection remove` | Delete a connection definition |
| `snow connection generate-jwt` | Generate a JWT for key-pair authenticated sessions (useful for external tooling) |
| `snow connection generate-workload-identity-token` | Generate a workload identity token for AWS/GCP/Azure/OIDC federated auth |

### 5.1 `snow connection add`

**Syntax**
```
snow connection add
  [--connection-name <name>]
  [--account <account>]
  [--user <user>]
  [--password <password>]
  [--role <role>]
  [--warehouse <warehouse>]
  [--database <database>]
  [--schema <schema>]
  [--no-interactive]
  [--default]
```

**Interactive example**

```bash
snow connection add
```
```
Name for this connection: dev
Snowflake account: myorg-devaccount
Snowflake username: svc_dbt_dev
Snowflake password [optional]:
Role for the connection [optional]: TRANSFORMER_DEV
Warehouse for the connection [optional]: WH_DBT_DEV
Database for the connection [optional]: ANALYTICS_DEV
Schema for the connection [optional]: PUBLIC
Connection "dev" successfully added to /home/jdoe/.snowflake/config.toml
```

**Non-interactive (CI-safe) example**

```bash
snow connection add \
  --connection-name ci \
  --account myorg-prodaccount \
  --user svc_ci_deploy \
  --role DEPLOYER \
  --warehouse WH_CI \
  --database ANALYTICS_PROD \
  --schema PUBLIC \
  --no-interactive
```

> **✅ Best Practice**
> Never pass `--password` on the command line in CI logs — it will be captured in shell history and CI job logs. Use key-pair authentication (`private_key_file`) or environment-variable overrides instead (see §7).

### 5.2 `snow connection list`

```bash
snow connection list
```
```
+---------------------------------------------------------------------------+
| connection_name | parameters                                | is_default |
|------------------|--------------------------------------------------------|
| dev              | {'account': 'myorg-devaccount', ...}      | True       |
| prod             | {'account': 'myorg-prodaccount', ...}     | False      |
+---------------------------------------------------------------------------+
```

Flags: `--format [table|json|csv]`, `--verbose`, `--debug`.

### 5.3 `snow connection test`

```bash
snow connection test --connection prod
```
```
+-------------------------------------------------------------------+
| key             | value                                          |
|-----------------|------------------------------------------------|
| Connection      | prod                                          |
| Status          | OK                                            |
| Account         | myorg-prodaccount                             |
| User            | svc_dbt_prod                                  |
| Role            | TRANSFORMER_PROD                              |
| Database        | ANALYTICS_PROD                                |
| Warehouse       | WH_DBT_PROD                                   |
+-------------------------------------------------------------------+
```

**Common failure**
```
Invalid connection configuration
000606: 250001: Could not connect to Snowflake backend after 0 attempt(s)
```
**Fix:** verify `account` identifier format (`orgname-accountname`, not the old `<account>.<region>` legacy locator unless your account still requires it), check network/proxy egress, and confirm the role/user exist and aren't locked.

### 5.4 `snow connection set-default`

```bash
snow connection set-default prod
```
```
Default connection set to "prod"
```

### 5.5 `snow connection remove`

```bash
snow connection remove ci
```
```
Connection "ci" removed from config.
```

### 5.6 `snow connection generate-jwt`

```bash
snow connection generate-jwt --connection prod
```
```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNWU9SRy1QUk9EQUNDT1VOVC5TVkNfRE...
```
Useful when a downstream tool (e.g., a REST API client, a custom microservice) needs a valid JWT but shouldn't have direct access to the private key file itself.

### 5.7 `snow connection generate-workload-identity-token`

```bash
snow connection generate-workload-identity-token --workload-identity-provider AWS
```
Generates a workload identity token for keyless authentication from AWS/GCP/Azure compute or a generic OIDC provider — eliminates static credentials for workloads running on cloud compute (e.g., an EC2-hosted Airflow worker).

---

## 6. Authentication Methods Supported

| Method | `authenticator` value | Typical use case |
|---|---|---|
| Username/Password | *(default, none needed)* | Local dev, quick testing (not recommended for prod) |
| Key-Pair (JWT) | `SNOWFLAKE_JWT` | Service accounts, CI/CD, production automation |
| External Browser (SSO) | `EXTERNALBROWSER` | Interactive human sessions with Okta/Azure AD/Ping |
| MFA (Duo passcode) | *(combine with `--mfa-passcode`)* | Human interactive sessions requiring MFA |
| OAuth (Client Credentials / Auth Code) | `OAUTH` + `--oauth-*` flags | Federated identity platforms, custom IdP integration |
| Workload Identity Federation | via `--workload-identity-provider` | Keyless auth from AWS/GCP/Azure/OIDC compute |
| PAT (Programmatic Access Token) | `--token` / `--token-file-path` | Short-lived scoped tokens for automation |

### 6.1 Key-Pair Authentication (recommended for production/CI)

```bash
# 1. Generate an unencrypted key pair (use an encrypted one + PRIVATE_KEY_PASSPHRASE in real prod)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_rsa_key.p8 -nocrypt
openssl rsa -in snowflake_rsa_key.p8 -pubout -out snowflake_rsa_key.pub

# 2. Register the public key against the Snowflake user (run as ACCOUNTADMIN/SECURITYADMIN)
snow sql -q "ALTER USER svc_dbt_prod SET RSA_PUBLIC_KEY='$(grep -v KEY snowflake_rsa_key.pub | tr -d '\n')'" --connection admin_conn
```

```toml
[connections.prod]
account = "myorg-prodaccount"
user = "svc_dbt_prod"
authenticator = "SNOWFLAKE_JWT"
private_key_file = "/secure/path/snowflake_rsa_key.p8"
role = "TRANSFORMER_PROD"
warehouse = "WH_DBT_PROD"
```

### 6.2 External Browser SSO

```bash
snow sql -q "select current_user()" \
  --account myorg-devaccount --user jdoe.human \
  --authenticator EXTERNALBROWSER
```
Opens a browser window for Okta/AzureAD authentication; the CLI blocks until SSO completes.

---

## 7. Overriding Connection Parameters at Runtime

Every connection field can be overridden three ways, evaluated in this precedence order (highest wins):

1. **CLI flags** (e.g., `--warehouse WH_ADHOC`)
2. **Environment variables** — generic form `SNOWFLAKE_CONNECTIONS_<CONNECTION_NAME>_<PARAM>`
3. **`config.toml` / `connections.toml` values**

```bash
export SNOWFLAKE_CONNECTIONS_PROD_PASSWORD="********"
snow sql -q "select 1" --connection prod
```

Generic (connection-agnostic) environment variables are also supported for the active/default connection:

```bash
export SNOWFLAKE_ACCOUNT="myorg-prodaccount"
export SNOWFLAKE_USER="svc_ci"
export SNOWFLAKE_PRIVATE_KEY_FILE="/secrets/key.p8"
export SNOWFLAKE_ROLE="DEPLOYER"
snow sql -q "select current_role()"
```

### 7.1 Temporary (Config-less) Connections

Use `-x` / `--temporary-connection` to bypass `config.toml` entirely — ideal for ephemeral CI runners where you inject credentials purely via environment/secrets:

```bash
snow sql -q "select current_version()" \
  --temporary-connection \
  --account "$SNOWFLAKE_ACCOUNT" \
  --user "$SNOWFLAKE_USER" \
  --private-key-file "$SNOWFLAKE_KEY_PATH" \
  --role "$SNOWFLAKE_ROLE" \
  --warehouse "$SNOWFLAKE_WAREHOUSE"
```

---

## 8. Migrating from SnowSQL

```bash
snow helpers import-snowsql-connections
```
```
Found SnowSQL config at ~/.snowsql/config
Import connection "example"? [y/n]: y
Connection "example" imported successfully.
```

| SnowSQL concept | Snowflake CLI equivalent |
|---|---|
| `~/.snowsql/config` | `~/.snowflake/config.toml` |
| `connections.<name>` INI section | `[connections.<name>]` TOML table |
| `snowsql -c <name>` | `snow sql --connection <name>` / `-c <name>` |
| `snowsql -q "..."` | `snow sql -q "..."` |
| `&variable` templating | `<% variable %>` templating (recommended) — legacy `&var` still supported |
| Interactive REPL | `snow sql` with no arguments launches an equivalent REPL |

---

## 9. Global CLI-Wide Options

These flags work across (almost) every `snow` command:

| Flag | Purpose |
|---|---|
| `--connection, -c, --environment` | Choose named connection |
| `--format [TABLE\|JSON\|JSON_EXT\|CSV]` | Output format |
| `--verbose, -v` | Info-level logs |
| `--debug` | Debug-level logs (very chatty — includes HTTP-level connector logs) |
| `--silent` | Suppress intermediate console output |
| `--enhanced-exit-codes` | Distinct exit codes for parameter errors (2) vs. query errors (5) vs. other errors (1) vs. success (0) |
| `-p, --project` | Path to a Snowflake project directory (`snowflake.yml`) |
| `--env` | Override project template variables |
| `--temporary-connection, -x` | Bypass config file, use CLI-passed credentials only |
| `--help` | Show help for the current command/group |

---

## 10. `snow init` — Bootstrapping a New Project

```bash
snow init my_snowpark_project
```
```
Initiating new project 'my_snowpark_project' ...
Selected template: default
Project created in /home/jdoe/projects/my_snowpark_project
```

`snow init` scaffolds a starter directory (`snowflake.yml`, `src/`, `README.md`) from a template. You can point it at custom templates hosted in a Git repository:

```bash
snow init my_app --template https://github.com/snowflakedb/snowflake-cli-templates --template-name native-app-basic
```

See `04` and `07` for full worked examples using these scaffolds for Snowpark and Native App projects.

---

## 11. Shell Autocompletion

```bash
# bash
snow --show-completion bash >> ~/.bashrc

# zsh
snow --show-completion zsh >> ~/.zshrc

# Install completion directly into the detected shell
snow --install-completion
```

> **💡 Tip**
> After enabling completion, `snow <TAB><TAB>` will list command groups, and `snow object <TAB><TAB>` will list object subtypes — a fast way to discover the command surface without leaving the terminal.

---

Continue to **`03_All_Snowflake_CLI_Commands.md`** for the exhaustive command reference.