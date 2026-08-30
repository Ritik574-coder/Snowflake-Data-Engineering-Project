-- =====================================================
-- ============== 1. DATABASE ==========================
-- =====================================================
-- creating databse semi_structured_db if not exists
CREATE 
    DATABASE IF NOT EXISTS
    SEMI_STRUCTURED_DB
;


-- =====================================================
-- ============== 2. SCHEMAS ===========================
-- =====================================================
-- creating staging schema if not exists
CREATE 
    SCHEMA IF NOT EXISTS 
    SEMI_STRUCTURED_DB.STAGING
;

-- creating analytics schema if not exists 
CREATE 
    SCHEMA IF NOT EXISTS 
    SEMI_STRUCTURED_DB.ANALYTICS
;


-- =====================================================
-- ============ 3. USE DATABASE / SCHEMA ===============
-- =====================================================

-- switch databse to semi_stracture_db
USE DATABASE SEMI_STRUCTURED_DB;

-- switch to correct schema staging
USE SCHEMA STAGING ;