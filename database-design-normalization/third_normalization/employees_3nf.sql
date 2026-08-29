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

--##########################################################################################
--###################### CREATING DDL SCRIPT AND INSERTING DATA  ###########################
--##########################################################################################

--- Switch to corrent database 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ; 

--==========================================================================================
--================================ dim_departments =========================================
--==========================================================================================

CREATE TABLE IF NOT EXISTS dimensions.dim_departments(
    department_id   VARCHAR(10) PRIMARY KEY ,
    department_name VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO dimensions.dim_departments(
    department_id,
    department_name
)
SELECT
    department_id,
    department_name
FROM staging.employees 
GROUP BY
    department_id,
    department_name 
ORDER BY department_id ASC;

CREATE OR REPLACE TABLE dimantions.dim_employees
(
    employee_id     NUMBER PRIMARY KEY,
    department_id   NUMBER            ,
    store_id        NUMBER            ,
    employee_name   VARCHAR(100)      ,
    hire_date       DATE              ,
    salary          NUMBER(12, 2)
);

SELECT * FROM  staging.stores ;


select * from dimensions.dim_cities ;
select * from dimensions.dim_states ;
select * from dimensions.dim_countries ;


SELECT * FROM dimensions.dim_departments ;