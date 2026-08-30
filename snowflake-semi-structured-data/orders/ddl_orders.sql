-- switch databse to semi_stracture_db
USE DATABASE SEMI_STRUCTURED_DB;

-- switch to correct schema staging
USE SCHEMA STAGING ;

-- creating table orders
CREATE OR REPLACE TABLE orders (
    order_id STRING,
    customer_id INTEGER,
    order_data VARIANT
);
