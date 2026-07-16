-- =============================================================================
-- File: 07_validate_installation_and_application.sql
-- Purpose: Validate the APEX installation and sample application database objects.
-- Run as: SYSDBA
-- Example:
--   sqlplus / as sysdba
--   @sql/07_validate_installation_and_application.sql
-- =============================================================================

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 240
SET PAGESIZE 200
SET SERVEROUTPUT ON
SET VERIFY OFF

DEFINE TARGET_PDB = KBPDB

ALTER SESSION SET CONTAINER = &&TARGET_PDB;

SHOW CON_NAME;

PROMPT
PROMPT =========================================================================
PROMPT APEX Component Status
PROMPT =========================================================================

COLUMN comp_id FORMAT A10
COLUMN comp_name FORMAT A35
COLUMN version FORMAT A15
COLUMN status FORMAT A12

SELECT comp_id,
       comp_name,
       version,
       status
FROM dba_registry
WHERE comp_id = 'APEX';

SELECT version_no
FROM apex_release;

PROMPT
PROMPT =========================================================================
PROMPT Invalid APEX Objects
PROMPT No rows is the preferred result.
PROMPT =========================================================================

COLUMN owner FORMAT A20
COLUMN object_type FORMAT A25
COLUMN object_name FORMAT A45

SELECT owner,
       object_type,
       object_name
FROM dba_objects
WHERE owner LIKE 'APEX\_%' ESCAPE '\'
  AND status = 'INVALID'
ORDER BY owner,
         object_type,
         object_name;

PROMPT
PROMPT =========================================================================
PROMPT Application Schema Status
PROMPT =========================================================================

COLUMN username FORMAT A20
COLUMN account_status FORMAT A25
COLUMN default_tablespace FORMAT A20

SELECT username,
       account_status,
       default_tablespace
FROM dba_users
WHERE username = 'DB_INV_APP';

PROMPT
PROMPT =========================================================================
PROMPT DATABASE_INVENTORY Object Status
PROMPT =========================================================================

COLUMN owner FORMAT A20
COLUMN object_name FORMAT A35
COLUMN object_type FORMAT A20
COLUMN status FORMAT A12

SELECT owner,
       object_name,
       object_type,
       status
FROM dba_objects
WHERE owner = 'DB_INV_APP'
  AND object_name = 'DATABASE_INVENTORY';

PROMPT
PROMPT =========================================================================
PROMPT DATABASE_INVENTORY Constraints
PROMPT =========================================================================

COLUMN constraint_name FORMAT A40
COLUMN constraint_type FORMAT A15
COLUMN status FORMAT A12
COLUMN validated FORMAT A12

SELECT constraint_name,
       constraint_type,
       status,
       validated
FROM dba_constraints
WHERE owner = 'DB_INV_APP'
  AND table_name = 'DATABASE_INVENTORY'
ORDER BY constraint_type,
         constraint_name;

PROMPT
PROMPT =========================================================================
PROMPT Sample Data
PROMPT =========================================================================

COLUMN database_name FORMAT A20
COLUMN environment FORMAT A15
COLUMN database_version FORMAT A18
COLUMN host_name FORMAT A25
COLUMN ip_address FORMAT A18
COLUMN platform FORMAT A20
COLUMN status FORMAT A20

SELECT database_id,
       database_name,
       environment,
       database_version,
       host_name,
       ip_address,
       platform,
       status,
       created_date
FROM db_inv_app.database_inventory
ORDER BY database_id;

SELECT COUNT(*) AS inventory_row_count
FROM db_inv_app.database_inventory;

UNDEFINE TARGET_PDB

PROMPT
PROMPT Validation completed.
