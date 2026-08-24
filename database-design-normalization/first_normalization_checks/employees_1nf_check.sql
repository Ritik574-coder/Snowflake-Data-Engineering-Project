-- ===========================================================================================
-- =================== FIRST NORMALIZATION CHECK IN EMPLOYEES DATASET ========================
-- ===========================================================================================
-- Switch to the correct database
USE DATABASE NORMALIZE_DW;

-- Switch to the correct schema
USE SCHEMA STAGING; 

-- Check EMPLOYEE_ID for suspicious/special characters
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            EMPLOYEE_ID, '.*[|,.:_!].*')
    ) AS suspicious_row
FROM employees; 

-- Check EMPLOYEE_NAME for suspicious/special characters
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            EMPLOYEE_NAME, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM employees; 

-- Check DEPARTMENT_ID for suspicious/special characters
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            DEPARTMENT_ID, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM employees;

-- Check DEPARTMENT_NAME for suspicious/special characters
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            DEPARTMENT_NAME, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM employees;

-- Check STORE_ID for suspicious/special characters
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STORE_ID, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM employees;

-- Check STORE_NAME for suspicious/special characters
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            STORE_NAME, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM employees;

-- Check HIRE_DATE for suspicious/special characters
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            HIRE_DATE, '.*[,.|*:;].*')
    ) AS suspicious_row
FROM employees;

-- Check SALARY for suspicious/special characters
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            SALARY, '.*[,|*:;].*')
    ) AS suspicious_row
FROM employees;