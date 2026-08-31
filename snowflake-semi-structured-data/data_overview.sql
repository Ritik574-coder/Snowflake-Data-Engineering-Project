-- switch databse to semi_stracture_db
USE DATABASE SEMI_STRUCTURED_DB;

-- switch to correct schema staging
USE SCHEMA STAGING ;

-- extracting 3 sample row from customer table 
SELECT * FROM customers LIMIT 3;

-- extracting 3 sample row from products table 
SELECT * FROM products LIMIT 3;

-- extractring 3 sample row from orders tanle 
SELECT * FROM orders LIMIT 3;