-- =============================================================================
-- File: 00_environment_checks.sql
-- Purpose: Verify the database version, target PDB, and existing APEX status.
-- Run as: SYS or another user with access to the referenced data dictionary views.
-- Example:
--   sqlplus / as sysdba
--   @sql/00_environment_checks.sql
-- =============================================================================

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 220
SET PAGESIZE 100
SET SERVEROUTPUT ON
SET VERIFY OFF

DEFINE TARGET_PDB = KBPDB

PROMPT
PROMPT =========================================================================
PROMPT Database Version
PROMPT =========================================================================

SELECT banner_full
FROM v$version;

PROMPT
PROMPT =========================================================================
PROMPT Pluggable Database Status
PROMPT =========================================================================

COLUMN name FORMAT A20
COLUMN open_mode FORMAT A15

SELECT name,
       open_mode
FROM v$pdbs
WHERE name = UPPER('&&TARGET_PDB');

PROMPT
PROMPT =========================================================================
PROMPT Switching to the Target PDB
PROMPT =========================================================================

ALTER SESSION SET CONTAINER = &&TARGET_PDB;

SHOW CON_NAME;

PROMPT
PROMPT =========================================================================
PROMPT Current Container and Database Character Set
PROMPT =========================================================================

SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS current_container
FROM dual;

COLUMN parameter FORMAT A30
COLUMN value FORMAT A40

SELECT parameter,
       value
FROM nls_database_parameters
WHERE parameter = 'NLS_CHARACTERSET';

PROMPT
PROMPT =========================================================================
PROMPT Existing APEX Component Status
PROMPT A row is returned only when APEX is already installed in the target PDB.
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

UNDEFINE TARGET_PDB

PROMPT
PROMPT Environment checks completed.
