-- switch databse to semi_stracture_db
USE DATABASE SEMI_STRUCTURED_DB;

-- switch to correct schema staging
USE SCHEMA STAGING ;

-- creating table customers
CREATE OR REPLACE TABLE customers (
    customer_id INTEGER,
    customer_name STRING,
    customer_data VARIANT
);
