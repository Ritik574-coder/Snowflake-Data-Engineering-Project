-- ===========================================================================================
-- =================== FIRST NORMALIZATION CHECK IN CUSTOMERS DATASET ========================
-- ===========================================================================================
-- switch corrent databse and schema 
USE DATABASE NORMALIZE_DW ;
USE SCHEMA STAGING ; 
-- Checking for customer_id values that potentially violate 1NF
-- by identifying rows where a single customer_id field may contain multiple values.

SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CUSTOMER_ID, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM customers;


-- Checking for customer_name values that potentially violate 1NF
-- by identifying rows where a single customer_name field may contain multiple values.
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CUSTOMER_NAME, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM customers;


-- Checking for email values that potentially violate 1NF
-- by identifying rows where a single email field may contain multiple values.
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            EMAIL, '.*[,|*:;].*')
    ) AS suspicious_row
FROM customers;


-- Checking for phone values that potentially violate 1NF
-- by identifying rows where a single phone field may contain multiple values.
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PHONE, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM customers;


-- Checking for city values that potentially violate 1NF
-- by identifying rows where a single city field may contain multiple values.
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CITY, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM customers;


-- Checking for state values that potentially violate 1NF
-- by identifying rows where a single state field may contain multiple values.
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STATE, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM customers;


-- Checking for country values that potentially violate 1NF
-- by identifying rows where a single country field may contain multiple values.
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            COUNTRY, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM customers;


-- Checking for signup_date values that potentially violate 1NF
-- by identifying rows where a single signup_date field may contain multiple values.
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            SIGNUP_DATE, '.*[,|*:;].*')
        ) AS suspicious_row
FROM customers;