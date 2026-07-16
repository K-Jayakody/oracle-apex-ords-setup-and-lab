# SQL Scripts

These scripts separate the major SQL and SQL*Plus operations used in the setup guide.

## Execution Order

| Order | Script | Run as | Purpose |
|---:|---|---|---|
| 1 | [`00_environment_checks.sql`](00_environment_checks.sql) | `SYSDBA` | Verify the database, PDB, character set, and current APEX status |
| 2 | [`01_install_apex.sql`](01_install_apex.sql) | `SYSDBA` | Run Oracle's `apexins.sql` installer and verify APEX |
| 3 | [`02_configure_apex_accounts.sql`](02_configure_apex_accounts.sql) | `SYSDBA` | Configure the APEX administrator, `APEX_PUBLIC_USER`, and REST accounts |
| 4 | [`03_create_application_schema.sql`](03_create_application_schema.sql) | `SYSDBA` | Create `DB_INV_APP` and grant the lab privileges |
| 5 | [`04_create_database_inventory.sql`](04_create_database_inventory.sql) | `DB_INV_APP@KBPDB` | Create the application table |
| 6 | [`05_insert_sample_data.sql`](05_insert_sample_data.sql) | `DB_INV_APP@KBPDB` | Insert the sample inventory records |
| 7 | [`06_apex_page_queries.sql`](06_apex_page_queries.sql) | `DB_INV_APP@KBPDB` | Store and test the chart and dashboard queries |
| 8 | [`07_validate_installation_and_application.sql`](07_validate_installation_and_application.sql) | `SYSDBA` | Validate APEX and the sample database objects |

## Before Running

Review and update the following values where necessary:

```text
TARGET_PDB = KBPDB
APEX_HOME  = /u01/soft/apex
```

The scripts request passwords interactively and do not store real passwords in the repository.

## Example

From the repository root:

```bash
sqlplus / as sysdba
```

```sql
@sql/00_environment_checks.sql
@sql/01_install_apex.sql
@sql/02_configure_apex_accounts.sql
@sql/03_create_application_schema.sql
```

Connect as the application schema:

```bash
sqlplus db_inv_app@KBPDB
```

```sql
@sql/04_create_database_inventory.sql
@sql/05_insert_sample_data.sql
@sql/06_apex_page_queries.sql
```

Perform the final validation as `SYSDBA`:

```bash
sqlplus / as sysdba
```

```sql
@sql/07_validate_installation_and_application.sql
```

## Notes

- Oracle's `apexins.sql`, `apxchpwd.sql`, and `apex_rest_config.sql` files are referenced from the locally extracted APEX distribution; they are not copied into this repository.
- `02_configure_apex_accounts.sql` includes the `APEX_PUBLIC_USER` configuration performed in the lab. Confirm that this matches the ORDS gateway configuration you selected.
- `05_insert_sample_data.sql` is intended to run once because the original table definition does not make `DATABASE_NAME` unique.
- Use HTTPS and stronger operational controls for a production deployment.
