-- =============================================================================
-- File: 01_create_application_schema.sql
-- Purpose: Create the DB_INV_APP schema and grant the privileges used in the lab.
-- Run as: SYSDBA
-- Example:
--   sqlplus / as sysdba
--   @sql/01_create_application_schema.sql
--
-- Note:
--   This script is intended for an initial setup. It will fail if DB_INV_APP
--   already exists. Review the grants and retain only those required.
-- =============================================================================

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 220
SET PAGESIZE 100
SET SERVEROUTPUT ON
SET VERIFY OFF

DEFINE TARGET_PDB = KBPDB

ALTER SESSION SET CONTAINER = &&TARGET_PDB;

SHOW CON_NAME;

ACCEPT DB_INV_APP_PASSWORD CHAR PROMPT 'Enter a strong password for DB_INV_APP: ' HIDE

CREATE USER db_inv_app
IDENTIFIED BY "&&DB_INV_APP_PASSWORD"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

UNDEFINE DB_INV_APP_PASSWORD

GRANT CREATE SESSION TO db_inv_app;
GRANT CREATE TABLE TO db_inv_app;
GRANT CREATE VIEW TO db_inv_app;
GRANT CREATE PROCEDURE TO db_inv_app;
GRANT CREATE SEQUENCE TO db_inv_app;
GRANT CREATE TRIGGER TO db_inv_app;
GRANT CREATE JOB TO db_inv_app;

PROMPT
PROMPT =========================================================================
PROMPT Verifying the Application Schema
PROMPT =========================================================================

COLUMN username FORMAT A20
COLUMN account_status FORMAT A25
COLUMN default_tablespace FORMAT A20
COLUMN temporary_tablespace FORMAT A20

SELECT username,
       account_status,
       default_tablespace,
       temporary_tablespace
FROM dba_users
WHERE username = 'DB_INV_APP';

UNDEFINE TARGET_PDB

PROMPT
PROMPT DB_INV_APP schema creation completed.
