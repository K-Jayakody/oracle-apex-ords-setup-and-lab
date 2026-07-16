-- =============================================================================
-- File: 02_configure_apex_accounts.sql
-- Purpose:
--   1. Create or update the APEX Instance Administrator.
--   2. Unlock and set the APEX_PUBLIC_USER password used in this lab.
--   3. Configure APEX REST-related accounts and static-file support.
-- Run as: SYSDBA
-- Example:
--   sqlplus / as sysdba
--   @sql/02_configure_apex_accounts.sql
--
-- Important:
--   Configuring APEX_PUBLIC_USER is deployment-specific. Current ORDS
--   configurations commonly use ORDS_PUBLIC_USER proxying. Keep the
--   APEX_PUBLIC_USER section only when it matches your selected configuration.
-- =============================================================================

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 220
SET PAGESIZE 100
SET SERVEROUTPUT ON
SET VERIFY OFF

DEFINE TARGET_PDB = KBPDB
DEFINE APEX_HOME  = /u01/soft/apex

ALTER SESSION SET CONTAINER = &&TARGET_PDB;

SHOW CON_NAME;

PROMPT
PROMPT =========================================================================
PROMPT Create or Update the APEX Instance Administrator
PROMPT Follow the prompts displayed by apxchpwd.sql.
PROMPT =========================================================================

@&&APEX_HOME/apxchpwd.sql

PROMPT
PROMPT =========================================================================
PROMPT Configure APEX_PUBLIC_USER
PROMPT The password is requested securely and is not echoed.
PROMPT Do not use a double quotation mark in the entered password.
PROMPT =========================================================================

ACCEPT APEX_PUBLIC_USER_PASSWORD CHAR PROMPT 'Enter a strong APEX_PUBLIC_USER password: ' HIDE

ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;

ALTER USER APEX_PUBLIC_USER
IDENTIFIED BY "&&APEX_PUBLIC_USER_PASSWORD";

COLUMN username FORMAT A25
COLUMN account_status FORMAT A25

SELECT username,
       account_status
FROM dba_users
WHERE username = 'APEX_PUBLIC_USER';

UNDEFINE APEX_PUBLIC_USER_PASSWORD

PROMPT
PROMPT =========================================================================
PROMPT Configure APEX REST Support
PROMPT Follow the password prompts displayed by apex_rest_config.sql.
PROMPT =========================================================================

@&&APEX_HOME/apex_rest_config.sql

UNDEFINE TARGET_PDB
UNDEFINE APEX_HOME

PROMPT
PROMPT APEX account and REST configuration completed.
