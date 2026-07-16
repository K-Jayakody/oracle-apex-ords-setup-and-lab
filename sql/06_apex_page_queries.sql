-- =============================================================================
-- File: 06_apex_page_queries.sql
-- Purpose: Store the SQL queries used by the APEX chart and dashboard cards.
-- Run as: DB_INV_APP, or paste each query into the relevant APEX page region.
-- =============================================================================

SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 220
SET PAGESIZE 100
SET VERIFY OFF

PROMPT
PROMPT =========================================================================
PROMPT Query 1: Pie Chart - Databases by Environment
PROMPT APEX mapping:
PROMPT   Label column: LABEL
PROMPT   Value column: VALUE
PROMPT =========================================================================

SELECT environment AS label,
       COUNT(*) AS value
FROM database_inventory
GROUP BY environment
ORDER BY environment;

PROMPT
PROMPT =========================================================================
PROMPT Query 2: Home Page Dashboard Cards
PROMPT APEX mapping:
PROMPT   Card title: CARD_TITLE
PROMPT   Card body or subtitle: CARD_VALUE
PROMPT =========================================================================

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

PROMPT
PROMPT APEX page queries completed.
