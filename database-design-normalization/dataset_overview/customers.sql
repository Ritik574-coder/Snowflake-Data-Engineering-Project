
-- ###########################################################################################
-- ################ STAGING CUSTOMER DATASET PROFILING AND OVERVIEW ##########################
-- ###########################################################################################
USE DATABASE NORMALIZE_DW ;
USE SCHEMA STAGING ;

-- ===========================================================================================
-- ================ CUSTOMER_ID DATA OVERVIEW AND VALIDATING CHECK  ==========================
-- ===========================================================================================

-- custoemr table data overview 
SELECT 
    * 
FROM customers LIMIT 10 ; 

-- duplicate custoemr id check 
SELECT 
    customer_id,
    COUNT(*) as customer_count
FROM customers 
GROUP BY customer_id 
HAVING COUNT(*) > 1
ORDER BY customer_count DESC ; 

-- returning those custoemr where custoemr_id is null or customer_id pattern not like ^C[0-9]+$
SELECT 
    *
FROM customers 
WHERE customer_id IS NULL 
OR NOT REGEXP_LIKE(customer_id, '^C[0-9]+$'); 

-- ===========================================================================================
-- ================ CUSTOMER_NAME DATA OVERVIEW AND VALIDATING CHECK  ========================
-- ===========================================================================================
-- customer_name profiling and validation check 
SELECT 
    customer_name 
FROM customers 
WHERE customer_name != TRIM(customer_name)
   OR customer_name != INITCAP(customer_name)
   OR customer_name IS NULL 
   OR customer_name = ''
   OR NOT REGEXP_LIKE(customer_name, '^[A-Z][a-z]+( [A-Z][a-z]+)*$') ;


