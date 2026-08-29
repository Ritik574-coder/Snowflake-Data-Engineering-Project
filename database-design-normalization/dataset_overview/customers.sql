
-- ###########################################################################################
-- ################ STAGING CUSTOMER DATASET PROFILING AND OVERVIEW ##########################
-- ###########################################################################################

-- Switch to corrent dataset 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ;

-- ===========================================================================================
-- ================= CUSTOMER_ID DATA PROFILING AND VALIDATION ===============================
-- ===========================================================================================

-- Preview customer data for initial dataset profiling
SELECT 
    *
FROM staging.customers 
LIMIT 10;

-- Check for duplicate customer_id values
SELECT 
    customer_id,
    COUNT(*) AS customer_count
FROM customers 
GROUP BY customer_id 
HAVING COUNT(*) > 1
ORDER BY customer_count DESC;


-- Validate customer_id for NULL values and expected format (e.g., C123)
SELECT 
    *
FROM customers 
WHERE customer_id IS NULL 
   OR NOT REGEXP_LIKE(customer_id, '^C[0-9]+$');

-- ===========================================================================================
-- ================= CUSTOMER_NAME DATA PROFILING AND VALIDATION =============================
-- ===========================================================================================
-- Validate customer_name for NULL, whitespace, capitalization, and expected format
SELECT 
    customer_name 
FROM customers 
WHERE customer_name != TRIM(customer_name)
   OR customer_name != INITCAP(customer_name)
   OR customer_name IS NULL 
   OR customer_name = ''
   OR NOT REGEXP_LIKE(customer_name, '^[A-Z][a-z]+( [A-Z][a-z]+)*$');