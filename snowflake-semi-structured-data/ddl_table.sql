SELECT * FROM INF

CREATE OR REPLACE TABLE customers (
    customer_id INTEGER,
    customer_name STRING,
    customer_data VARIANT
);

CREATE OR REPLACE TABLE orders (
    order_id STRING,
    customer_id INTEGER,
    order_data VARIANT
);

CREATE OR REPLACE TABLE products (
    product_id STRING,
    product_data VARIANT
);