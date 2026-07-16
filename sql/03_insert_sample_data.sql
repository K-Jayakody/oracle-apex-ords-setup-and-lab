-- =============================================================================
-- File: 03_insert_sample_data.sql
-- Purpose: Insert the three sample rows used by the Database Inventory app.
-- Run as: DB_INV_APP connected directly to KBPDB.
-- Example:
--   sqlplus db_inv_app@KBPDB
--   @sql/03_insert_sample_data.sql
--
-- Note:
--   Run this script once. Re-running it inserts additional rows because the
--   original lab table does not define DATABASE_NAME as unique.
-- =============================================================================

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 220
SET PAGESIZE 100
SET SERVEROUTPUT ON
SET VERIFY OFF

SELECT USER AS connected_user,
       SYS_CONTEXT('USERENV', 'CON_NAME') AS current_container
FROM dual;

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

COMMIT;

PROMPT
PROMPT =========================================================================
PROMPT Inserted Sample Data
PROMPT =========================================================================

COLUMN database_name FORMAT A20
COLUMN environment FORMAT A15
COLUMN database_version FORMAT A18
COLUMN host_name FORMAT A25
COLUMN status FORMAT A20

SELECT database_id,
       database_name,
       environment,
       database_version,
       host_name,
       status
FROM database_inventory
ORDER BY database_id;

PROMPT
PROMPT Sample data insertion completed.
