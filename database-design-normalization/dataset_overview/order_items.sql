
-- ###########################################################################################
-- ################ STAGING ORDER_ITEMS DATASET PROFILING AND OVERVIEW #######################
-- ###########################################################################################

-- Switch to corrent dataset 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ;

-- ===========================================================================================
-- ================= ORDER_ITEMS DATA PROFILING AND VALIDATION ===============================
-- ===========================================================================================

-- Preview customer data for initial dataset profiling
SELECT 
    *
FROM staging.order_items 
LIMIT 100 ; 