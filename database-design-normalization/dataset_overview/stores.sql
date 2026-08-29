
-- ###########################################################################################
-- ################## STAGING STORES  DATASET PROFILING AND OVERVIEW #########################
-- ###########################################################################################

-- Switch to corrent dataset 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ;

-- ===========================================================================================
-- ==================== STORE_ID DATA PROFILING AND VALIDATION ===============================
-- ===========================================================================================

-- Preview customer data for initial dataset profiling
SELECT 
    *
FROM staging.stores
LIMIT 100 ; 