-- ===========================================================================================
-- ====================== FIRST NORMALIZATION CHECK IN STORES DATASET ========================
-- ===========================================================================================
-- switch to corrent databse 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ; 

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name  STORE_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STORE_ID, '.*[!,|:;_*].*'
        )
    ) AS suspicious_count
FROM stores ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name  STORE_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STORE_NAME, '.*[!,|:;_*].*'
        )
    ) AS suspicious_count
FROM stores ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name  CITY
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CITY, '.*[!,|:;_*].*'
        )
    ) AS suspicious_count
FROM stores ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name  STATE
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STATE, '.*[!,|:;_*].*'
        )
    ) AS suspicious_count
FROM stores ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name  COUNTRY
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            COUNTRY, '.*[!,|:;_*].*'
        )
    ) AS suspicious_count
FROM stores ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name  MANAGER_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            MANAGER_ID, '.*[!,|:;_*].*'
        )
    ) AS suspicious_count
FROM stores ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name  MANAGER_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            MANAGER_NAME, '.*[!,|:;_*].*'
        )
    ) AS suspicious_count
FROM stores ;