--########################################################################################
--###################### CHECKING THE FUNCTIONAL DEPENDENCY ##############################
--########################################################################################
--- Switch to corrent database 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ; 

-- employees data overview 
SELECT * FROM staging.employees LIMIT 20 ; 

-- Checking functional dependency: department_id → department_name. Each department_id should have only one department_name.
SELECT 
    department_id,
    COUNT(DISTINCT department_name) AS department_count
FROM staging.employees
GROUP BY department_id
HAVING COUNT(DISTINCT department_name) > 1;

-- Checking reverse functional dependency: department_name → department_id. Each department_name should have only one department_id.
SELECT 
    department_name,
    COUNT(DISTINCT department_id) AS department_count
FROM staging.employees
GROUP BY department_name
HAVING COUNT(DISTINCT department_id) > 1;

-- Checking functional dependency: store_id → store_name. Each store_id should have only one store_name.
SELECT 
    store_id,
    COUNT(DISTINCT store_name) AS store_name_count
FROM staging.employees
GROUP BY store_id 
HAVING COUNT(DISTINCT store_name) > 1;

-- Checking reverse functional dependency: store_name → store_id. Each store_name should have only one store_id.
SELECT 
    store_name,
    COUNT(DISTINCT store_id) AS store_id_count
FROM staging.employees
GROUP BY store_name
HAVING COUNT(DISTINCT store_id) > 1;