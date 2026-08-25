-- ===========================================================================================
-- ==================== FIRST NORMALIZATION CHECK IN PRODUCTS DATASET ========================
-- ===========================================================================================
-- Switch to correct database
USE DATABASE NORMALIZE_DW ;

-- Switch to correct schema 
USE SCHEMA STAGING ; 

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name PRODUCT_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PRODUCT_ID, '.*[!|,_:;].*')
    ) AS suspicious_count
FROM products ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name PRODUCT_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PRODUCT_NAME, '.*[!|,_:;].*')
    ) AS suspicious_count
FROM products ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CATEGORY_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CATEGORY_ID, '.*[!|,_:;].*')
    ) AS suspicious_count
FROM products ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CATEGORY_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CATEGORY_NAME, '.*[!|,_:;].*')
    ) AS suspicious_count
FROM products ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name SUPPLIER_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            SUPPLIER_ID, '.*[!|,_:;].*')
    ) AS suspicious_count
FROM products ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name SUPPLIER_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            SUPPLIER_NAME, '.*[!|,_:;].*')
    ) AS suspicious_count
FROM products ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name UNIT_PRICE
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            UNIT_PRICE, '.*[!|,_:;].*')
    ) AS suspicious_count
FROM products ;
