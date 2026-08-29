
-- ###########################################################################################
-- ################ STAGING SUPPLIERS DATASET PROFILING AND OVERVIEW #########################
-- ###########################################################################################

-- Switch to corrent dataset 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ;

-- ===========================================================================================
-- ================= SUPPLIER_ID DATA PROFILING AND VALIDATION ===============================
-- ===========================================================================================

-- Preview customer data for initial dataset profiling
SELECT 
    *
FROM staging.suppliers
LIMIT 100 ; 