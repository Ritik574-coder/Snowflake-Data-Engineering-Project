-- switch databse to semi_stracture_db
USE DATABASE SEMI_STRUCTURED_DB;

-- switch to correct schema staging
USE SCHEMA STAGING ;

-- creating table products 
CREATE OR REPLACE TABLE products (
    product_id STRING,
    product_data VARIANT
);