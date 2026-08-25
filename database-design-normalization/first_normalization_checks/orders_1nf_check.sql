-- ===========================================================================================
-- ===================== FIRST NORMALIZATION CHECK IN ORDERS DATASET =========================
-- ===========================================================================================
-- switch to corrent databse 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ; 

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name ORDER_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            ORDER_ID, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CUSTOMER_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CUSTOMER_ID, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CUSTOMER_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CUSTOMER_NAME, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CITY
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CITY, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name STATE
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STATE, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name COUNTRY
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            COUNTRY, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name ORDER_DATE
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            ORDER_DATE, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name STORE_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STORE_ID, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name STORE_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STORE_NAME, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name EMPLOYEE_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            EMPLOYEE_ID, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name EMPLOYEE_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            EMPLOYEE_NAME, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name DEPARTMENT_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            DEPARTMENT_ID, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name DEPARTMENT_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            DEPARTMENT_NAME, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name PRODUCT_IDS
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PRODUCT_IDS, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name PRODUCT_NAMES
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PRODUCT_NAMES, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name QUANTITIES
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            QUANTITIES, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name UNIT_PRICES
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            UNIT_PRICES, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name PAYMENT_METHOD
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PAYMENT_METHOD, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name PAYMENT_AMOUNT
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PAYMENT_AMOUNT, '.*[!,;:|_].*'
        ) 
    ) AS suspicious_count
FROM orders ;
