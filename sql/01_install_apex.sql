-- =============================================================================
-- File: 01_install_apex.sql
-- Purpose: Install Oracle APEX in the target PDB and verify the component.
-- Run as: SYSDBA
-- Requirements:
--   - Extract the matching Oracle APEX software before running this script.
--   - Update APEX_HOME and TARGET_PDB when required.
-- Example:
--   sqlplus / as sysdba
--   @sql/01_install_apex.sql
--
-- Note:
--   This wrapper references Oracle's supplied apexins.sql file. It does not
--   reproduce or redistribute the Oracle installer.
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
DEFINE APEX_TABLESPACE = SYSAUX
DEFINE APEX_FILES_TABLESPACE = SYSAUX
DEFINE TEMP_TABLESPACE = TEMP
DEFINE APEX_IMAGE_PREFIX = /i/

PROMPT
PROMPT =========================================================================
PROMPT Switching to target PDB: &&TARGET_PDB
PROMPT =========================================================================

ALTER SESSION SET CONTAINER = &&TARGET_PDB;

SHOW CON_NAME;

PROMPT
PROMPT =========================================================================
PROMPT Installing Oracle APEX
PROMPT Installer: &&APEX_HOME/apexins.sql
PROMPT =========================================================================

@&&APEX_HOME/apexins.sql &&APEX_TABLESPACE &&APEX_FILES_TABLESPACE &&TEMP_TABLESPACE &&APEX_IMAGE_PREFIX

PROMPT
PROMPT =========================================================================
PROMPT Verifying Oracle APEX
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

UNDEFINE TARGET_PDB
UNDEFINE APEX_HOME
UNDEFINE APEX_TABLESPACE
UNDEFINE APEX_FILES_TABLESPACE
UNDEFINE TEMP_TABLESPACE
UNDEFINE APEX_IMAGE_PREFIX

PROMPT
PROMPT Review the timestamped install log in the APEX software directory.
PROMPT A successful installation should report the APEX component as VALID.
