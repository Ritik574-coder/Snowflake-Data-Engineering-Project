-- ===========================================================================================
-- =================== FIRST NORMALIZATION CHECK IN CUSTOMERS DATASET ========================
-- ===========================================================================================
-- switch to corrent databse 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ; 

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name SUPPLIER_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            SUPPLIER_ID, '.*[!,:;|_].*'
            )
    ) as suspicious_count
FROM suppliers ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name SUPPLIER_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            SUPPLIER_NAME, '.*[!,:;|_].*'
            )
    ) as suspicious_count
FROM suppliers ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CONTACT_EMAIL
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CONTACT_EMAIL, '.*[!,:;|_].*'
            )
    ) as suspicious_count
FROM suppliers ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CITY
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CITY, '.*[!,:;|_].*'
            )
    ) as suspicious_count
FROM suppliers ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name STATE
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STATE, '.*[!,:;|_].*'
            )
    ) as suspicious_count
FROM suppliers ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name COUNTRY
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            COUNTRY, '.*[!,:;|_].*'
            )
    ) as suspicious_count
FROM suppliers ;
