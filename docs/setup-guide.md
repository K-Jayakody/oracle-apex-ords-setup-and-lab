# Setup Guide: Installing Oracle APEX and ORDS

## Table of Contents

- [1. Project Overview](#1-project-overview)
- [2. Environment](#2-environment)
- [3. Important Version Note](#3-important-version-note)
- [4. Security and Placeholder Conventions](#4-security-and-placeholder-conventions)
- [5. Prerequisites](#5-prerequisites)
- [6. Download and Extract Oracle APEX](#6-download-and-extract-oracle-apex)
- [7. Install Oracle APEX in the Target PDB](#7-install-oracle-apex-in-the-target-pdb)
- [8. Configure the APEX Administrator and REST Accounts](#8-configure-the-apex-administrator-and-rest-accounts)
- [9. Download and Extract ORDS](#9-download-and-extract-ords)
- [10. Install and Configure ORDS](#10-install-and-configure-ords)
- [11. Configure APEX Static Resources](#11-configure-apex-static-resources)
- [12. Start ORDS and Access APEX](#12-start-ords-and-access-apex)
- [13. Create the Sample Application Schema](#13-create-the-sample-application-schema)
- [14. Configure Oracle Net Service Names](#14-configure-oracle-net-service-names)
- [15. Create an APEX Workspace](#15-create-an-apex-workspace)
- [16. Create the Database Inventory Table](#16-create-the-database-inventory-table)
- [17. Insert Sample Data](#17-insert-sample-data)
- [18. Create the APEX Application](#18-create-the-apex-application)
- [19. Configure the Generated Form](#19-configure-the-generated-form)
- [20. Add a Pie Chart](#20-add-a-pie-chart)
- [21. Add Dashboard Cards](#21-add-dashboard-cards)
- [22. Test the Application](#22-test-the-application)
- [23. Export the Application](#23-export-the-application)

---

## 1. Project Overview

This guide documents the installation and configuration of Oracle APEX and Oracle REST Data Services. It also demonstrates the creation of a simple Oracle Database Inventory application using Oracle APEX App Builder.

The project is divided into two parts:

1. Install and configure Oracle APEX and ORDS.
2. Create, test, and export a small APEX application.

The sample application demonstrates:

- Creating an application schema
- Creating an APEX workspace
- Creating a database table
- Generating an interactive report and form
- Configuring select lists
- Adding declarative validation
- Creating a chart
- Adding dashboard cards
- Testing and exporting an application

---

## 2. Environment

| Component | Version or Configuration |
|---|---|
| Operating system | Oracle Linux 9.8 |
| Oracle Database | 23.26.1.0.0 |
| Oracle APEX | 26.1 |
| Oracle REST Data Services | 26.2.1 |
| Java | Oracle JDK 25 |
| ORDS deployment mode | Standalone |
| Target pluggable database | `KBPDB` |
| ORDS configuration directory | `/u01/app/oracle/ords/config` |
| ORDS HTTP port | `8080` |
| Sample application schema | `DB_INV_APP` |
| Sample workspace | `DB_INV_WS` |

---

## 3. Important Version Note

This guide records the sequence followed during the original lab:

```text
Install APEX
→ Configure APEX accounts
→ Install ORDS
→ Build the sample application
```

---

## 4. Security and Placeholder Conventions

Values enclosed in angle brackets are placeholders:

```text
<APEX_ZIP_FILE>
<ORDS_ZIP_FILE>
<APEX_HOST_OR_IP>
<APEX_ADMIN_PASSWORD>
<APEX_ADMIN_EMAIL>
<APEX_PUBLIC_USER_PASSWORD>
<APEX_REST_PASSWORD>
<DB_INV_APP_PASSWORD>
<WORKSPACE_ADMIN_USERNAME>
<WORKSPACE_ADMIN_PASSWORD>
<WORKSPACE_ADMIN_EMAIL>
```

Do not publish:

- Actual passwords
- Internal IP addresses
- Private hostnames
- Wallet files
- ORDS secrets
- Private keys
- TLS certificates
- Personal email addresses
- Database connection strings containing credentials

The HTTP configuration in this guide is intended for a lab. Use HTTPS for a production deployment.

---

## 5. Prerequisites

Confirm the following before starting:

- Oracle Database is installed and running.
- The target PDB is open in `READ WRITE` mode.
- A supported Java version is installed where ORDS will run (ORDS 26.2.1 supports Oracle Java 17, 21, and 25)
- SQL*Plus is available.
- The `unzip` utility is installed.
- The installer has the required operating-system and database privileges.
- Sufficient disk space is available.
- A database backup or restore point has been created where appropriate.

---

## 6. Download and Extract Oracle APEX

Download Oracle APEX 26.1 from:

- [Oracle APEX Downloads](https://www.oracle.com/tools/downloads/apex-downloads.html)

Copy the downloaded file to the server. This guide uses `/u01/soft` as the staging directory.

```bash
cd /u01/soft
unzip <APEX_ZIP_FILE>.zip
cd /u01/soft/apex
```

Confirm that the required files exist:

```bash
ls -l apexins.sql
ls -l apxchpwd.sql
ls -l apex_rest_config.sql
ls -ld images
```

---

## 7. Install Oracle APEX in the Target PDB

Run SQL*Plus from the extracted APEX directory so that the installer log is written to a known location.

```bash
cd /u01/soft/apex
sqlplus / as sysdba
```

Switch to the target PDB:

```sql
ALTER SESSION SET CONTAINER = KBPDB;
```

Verify the current container:

```sql
SHOW CON_NAME;
```

Expected result:

```text
CON_NAME
------------------------------
KBPDB
```

Run the APEX installation script:

```sql
@apexins.sql SYSAUX SYSAUX TEMP /i/
```

The four parameters are:

| Position | Value | Purpose |
|---|---|---|
| 1 | `SYSAUX` | APEX metadata tablespace |
| 2 | `SYSAUX` | APEX files tablespace |
| 3 | `TEMP` | Temporary tablespace |
| 4 | `/i/` | APEX static resource virtual path |

Review the installation output and generated log for errors.

### 7.1 Verify the APEX Component

```sql
SELECT comp_id,
       comp_name,
       version,
       status
FROM dba_registry
WHERE comp_id = 'APEX';
```

Expected status:

```text
VALID
```

Check the installed APEX version:

```sql
SELECT version_no
FROM apex_release;
```

---

## 8. Configure the APEX Administrator and REST Accounts

### 8.1 Create or Update the Instance Administrator

Run:

```sql
@apxchpwd.sql
```

Provide the requested values:

- Instance Administrator username
- Administrator password
- Administrator email address

### 8.2 Configure `APEX_PUBLIC_USER`

> This step is applicable when the ORDS gateway configuration connects using `APEX_PUBLIC_USER`. Review the selected ORDS configuration before treating it as universally required.

Unlock the account:

```sql
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
```

Set a strong password:

```sql
ALTER USER APEX_PUBLIC_USER
IDENTIFIED BY "<APEX_PUBLIC_USER_PASSWORD>";
```

Verify the account status:

```sql
SELECT username,
       account_status
FROM dba_users
WHERE username = 'APEX_PUBLIC_USER';
```

### 8.3 Configure APEX REST Support

Run:

```sql
@apex_rest_config.sql
```

Enter strong passwords when prompted for the APEX REST-related accounts.

Exit SQL*Plus:

```sql
EXIT;
```

---

## 9. Download and Extract ORDS

Download ORDS 26.2.1 from:

- [Oracle REST Data Services Downloads](https://www.oracle.com/database/sqldeveloper/technologies/db-actions/download/)

Create the ORDS product directory:

```bash
mkdir -p /u01/app/oracle/ords
```

Extract ORDS:

```bash
cd /u01/app/oracle/ords
unzip /u01/soft/<ORDS_ZIP_FILE>.zip
```

Verify the version:

```bash
cd /u01/app/oracle/ords/bin
./ords --version
```

---

## 10. Install and Configure ORDS

Create a configuration directory separate from the ORDS product files:

```bash
mkdir -p /u01/app/oracle/ords/config
```

Navigate to the ORDS executable directory:

```bash
cd /u01/app/oracle/ords/bin
```

Run the interactive installer:

```bash
./ords --config /u01/app/oracle/ords/config install
```

Provide the required database connection values during installation.

Typical values for this lab are:

| Prompt | Example |
|---|---|
| Database host | `localhost` |
| Listener port | `1521` |
| Database service | `KBPDB` |
| Administrator user | `SYS` |
| Administrator role | `SYSDBA` |

---

## 11. Configure APEX Static Resources

Configure ORDS to serve the APEX static files:

```bash
./ords --config /u01/app/oracle/ords/config config set standalone.static.path /u01/soft/apex/images
```

> For a longer-lived deployment, copy the image directory to a stable runtime location instead of depending on a temporary software-staging directory.

---

## 12. Start ORDS and Access APEX

Start ORDS in standalone mode:

```bash
./ords --config /u01/app/oracle/ords/config serve
```

The default standalone HTTP port is `8080` unless another port was selected.

Open one of the following URLs:

```text
http://<APEX_HOST_OR_IP>:8080/ords/
```

```text
http://<APEX_HOST_OR_IP>:8080/ords/_/landing
```

Sign in with:

```text
Workspace: INTERNAL
Username: ADMIN
Password: <APEX_ADMIN_PASSWORD>
```

Confirm that:

- The login page is accessible.
- CSS, icons, and JavaScript load correctly.
- No ORDS database-pool error is displayed.
- The Instance Administrator can sign in.

---

## 13. Create the Sample Application Schema

Connect as a privileged database user:

```bash
sqlplus / as sysdba
```

Switch to the target PDB:

```sql
ALTER SESSION SET CONTAINER = KBPDB;
```

Create the application user:

```sql
CREATE USER db_inv_app
IDENTIFIED BY "<DB_INV_APP_PASSWORD>"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;
```

Grant the privileges used in this lab:

```sql
GRANT CREATE SESSION TO db_inv_app;
GRANT CREATE TABLE TO db_inv_app;
GRANT CREATE VIEW TO db_inv_app;
GRANT CREATE PROCEDURE TO db_inv_app;
GRANT CREATE SEQUENCE TO db_inv_app;
GRANT CREATE TRIGGER TO db_inv_app;
GRANT CREATE JOB TO db_inv_app;
```

Verify the user:

```sql
SELECT username,
       account_status,
       default_tablespace
FROM dba_users
WHERE username = 'DB_INV_APP';
```

Exit SQL*Plus:

```sql
EXIT;
```

---

## 14. Configure Oracle Net Service Names

Open `tnsnames.ora`:

```bash
cd /u01/app/oracle/product/23.0.0/dbhome_1/network/admin
vi tnsnames.ora
```

Add the service aliases:

```text
ORCL =
  (DESCRIPTION =
    (ADDRESS =
      (PROTOCOL = TCP)
      (HOST = localhost)
      (PORT = 1521)
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCL)
    )
  )

KBPDB =
  (DESCRIPTION =
    (ADDRESS =
      (PROTOCOL = TCP)
      (HOST = localhost)
      (PORT = 1521)
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = KBPDB)
    )
  )
```

Test name resolution:

```bash
tnsping KBPDB
```

Connect:

```bash
sqlplus db_inv_app@KBPDB
```

Enter the password when prompted.

Verify the current container:

```sql
SHOW CON_NAME;
```

Expected result:

```text
KBPDB
```

Exit SQL*Plus:

```sql
EXIT;
```

---

## 15. Create an APEX Workspace

Open APEX Administration Services:

```text
http://<APEX_HOST_OR_IP>:8080/ords/apex
```

Sign in using the Instance Administrator account.

Navigate to:

```text
Manage Workspaces
→ Create Workspace
```

Configure the workspace:

| Field | Value |
|---|---|
| Workspace name | `DB_INV_WS` |
| Reuse existing schema | `Yes` |
| Database schema | `DB_INV_APP` |
| Workspace administrator | `<WORKSPACE_ADMIN_USERNAME>` |
| Administrator email | `<WORKSPACE_ADMIN_EMAIL>` |
| Administrator password | `<WORKSPACE_ADMIN_PASSWORD>` |

Create the workspace.

Sign out of Administration Services and sign in to the new workspace:

```text
Workspace: DB_INV_WS
Username: <WORKSPACE_ADMIN_USERNAME>
Password: <WORKSPACE_ADMIN_PASSWORD>
```

---

## 16. Create the Database Inventory Table

Connect to the application schema:

```bash
sqlplus db_inv_app@KBPDB
```

Enter the password when prompted.

Create the table:

```sql
CREATE TABLE database_inventory (
    database_id       NUMBER
                      GENERATED BY DEFAULT AS IDENTITY
                      CONSTRAINT database_inventory_pk PRIMARY KEY,
    database_name     VARCHAR2(30) NOT NULL,
    environment       VARCHAR2(20) NOT NULL,
    database_version  VARCHAR2(30),
    host_name         VARCHAR2(100),
    ip_address        VARCHAR2(45),
    platform          VARCHAR2(50),
    status            VARCHAR2(20)
                      DEFAULT 'AVAILABLE'
                      NOT NULL,
    created_date      DATE
                      DEFAULT SYSDATE
                      NOT NULL,
    notes             VARCHAR2(500),
    CONSTRAINT database_inventory_env_ck
        CHECK (
            environment IN (
                'DEVELOPMENT',
                'TEST',
                'UAT',
                'PRODUCTION'
            )
        ),
    CONSTRAINT database_inventory_status_ck
        CHECK (
            status IN (
                'AVAILABLE',
                'UNAVAILABLE',
                'MAINTENANCE'
            )
        )
);
```

Verify the table:

```sql
DESC database_inventory;
```

---

## 17. Insert Sample Data

Insert the development database:

```sql
INSERT INTO database_inventory (
    database_name,
    environment,
    database_version,
    host_name,
    ip_address,
    platform,
    status,
    notes
)
VALUES (
    'DEVDB',
    'DEVELOPMENT',
    '19c',
    'dev-db-server',
    '192.0.2.10',
    'Oracle Linux',
    'AVAILABLE',
    'Development database'
);
```

Insert the UAT database:

```sql
INSERT INTO database_inventory (
    database_name,
    environment,
    database_version,
    host_name,
    ip_address,
    platform,
    status,
    notes
)
VALUES (
    'UATDB',
    'UAT',
    '19c',
    'uat-db-server',
    '192.0.2.20',
    'Oracle Linux',
    'MAINTENANCE',
    'UAT database undergoing maintenance'
);
```

Insert the production database:

```sql
INSERT INTO database_inventory (
    database_name,
    environment,
    database_version,
    host_name,
    ip_address,
    platform,
    status,
    notes
)
VALUES (
    'PRODDB',
    'PRODUCTION',
    '19c',
    'prod-db-server',
    '192.0.2.30',
    'Oracle Linux',
    'AVAILABLE',
    'Production database'
);
```

Commit the changes:

```sql
COMMIT;
```

Verify the data:

```sql
SELECT database_id,
       database_name,
       environment,
       database_version,
       host_name,
       status
FROM database_inventory
ORDER BY database_id;
```

Exit SQL*Plus:

```sql
EXIT;
```

The `192.0.2.0/24` range is used for documentation and does not represent actual infrastructure.

---

## 18. Create the APEX Application

Sign in to the `DB_INV_WS` workspace.

Navigate to:

```text
App Builder
→ Create
→ Use Create App Wizard
```

Set the application name:

```text
Oracle Database Inventory
```

Add an interactive report page:

1. Select **Add Page**.
2. Select **Interactive Report**.
3. Set the page name to **Database Inventory**.
4. Select **Table or View** as the data source.
5. Select `DATABASE_INVENTORY`.
6. Enable **Include Form**.
7. Add the page.
8. Select **Create Application**.

APEX generates:

- An interactive report page
- A create and edit form
- Insert, update, and delete processing
- Navigation entries for the generated pages

---

## 19. Configure the Generated Form

Open the generated form page in Page Designer.

The page item names can vary according to the generated page number. In this lab, the database name item was `P3_DATABASE_NAME`.

### 19.1 Configure the Environment Select List

Select the Environment page item.

Set the item type to **Select List** and configure the static List of Values:

```text
STATIC:
Development;DEVELOPMENT,
Test;TEST,
UAT;UAT,
Production;PRODUCTION
```

### 19.2 Configure the Status Select List

Select the Status page item.

Set the item type to **Select List** and configure:

```text
STATIC:
Available;AVAILABLE,
Unavailable;UNAVAILABLE,
Maintenance;MAINTENANCE
```

### 19.3 Configure Database Name Validation

Select the database name item, for example:

```text
P3_DATABASE_NAME
```

Configure:

```text
Validation
→ Value Required
→ Yes
```

Optional custom error message:

```text
Database name must be entered.
```

Save the page.

---

## 20. Add a Pie Chart

Navigate to:

```text
Create Page
→ Chart
```

Configure:

| Property | Value |
|---|---|
| Chart type | Pie |
| Page name | `Databases by Environment` |
| Data source | Local Database |
| Source type | SQL Query |

Use:

```sql
SELECT environment AS label,
       COUNT(*) AS value
FROM database_inventory
GROUP BY environment
ORDER BY environment;
```

Map the chart columns:

| Chart attribute | Query column |
|---|---|
| Label | `LABEL` |
| Value | `VALUE` |

Complete the wizard and save the page.

---

## 21. Add Dashboard Cards

Open the application home page in Page Designer.

Add a region with:

| Property | Value |
|---|---|
| Region type | Cards |
| Location | Local Database |
| Source type | SQL Query |

Use:

```sql
SELECT 'Total Databases' AS card_title,
       COUNT(*) AS card_value
FROM database_inventory

UNION ALL

SELECT 'Available' AS card_title,
       COUNT(*) AS card_value
FROM database_inventory
WHERE status = 'AVAILABLE'

UNION ALL

SELECT 'Under Maintenance' AS card_title,
       COUNT(*) AS card_value
FROM database_inventory
WHERE status = 'MAINTENANCE';
```

Map the card attributes:

| Card attribute | Query column |
|---|---|
| Title | `CARD_TITLE` |
| Body or subtitle | `CARD_VALUE` |

Save the page.

---

## 22. Test the Application

Run the application:

```text
App Builder
→ Oracle Database Inventory
→ Run Application
```

Perform the following tests:

| Test | Expected result |
|---|---|
| Open Database Inventory | The three sample records are displayed |
| Search for `PRODDB` | The production database record is returned |
| Filter by `PRODUCTION` | Only production records are displayed |
| Create a record | The record appears in the report |
| Edit a record | The changes are saved |
| Delete a test record | The record is removed |
| Submit without a database name | A validation message is displayed |
| Open the chart | Database counts are grouped by environment |
| Open the home page | The summary cards show the correct totals |

---

## 23. Export the Application

Navigate to:

```text
App Builder
→ Oracle Database Inventory
→ Export / Import
→ Export
```

Review the export settings and export the application.

Oracle APEX application exports can be imported into another compatible APEX environment.
