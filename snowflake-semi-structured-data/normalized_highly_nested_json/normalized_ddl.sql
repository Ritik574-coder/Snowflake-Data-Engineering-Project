-- switch to corrent database 
USE DATABASE SEMI_STRUCTURED_DB ;

-- creating mart schema for normailzation 
CREATE SCHEMA IF NOT EXISTS mart ; 

-- swiitch to corrent schema 
USE SCHEMA MART ; 

-- creating customers table if not exists 
CREATE TABLE IF NOT EXISTS customers(
    customer_id NUMBER PRIMARY KEY AUTOINCREMENT,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50)
);

-- creating table customer_email if not exists 
CREATE TABLE IF NOT EXISTS customer_email(
    customer_id NUMBER,
    type        VARCHAR(50),
    email       VARCHAR(251),
    verified    BOOLEAN,

    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
) ;

-- creating orders table if not exists 
CREATE TABLE IF NOT EXISTS orders(
    order_id    VARCHAR(20) PRIMARY KEY,
    customer_id NUMBER ,
 
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE IF NOT EXISTS products(
    product_id   VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100)
) ;

-- creating order_items table is not exists 
CREATE TABLE IF NOT EXISTS order_items(
    order_id     VARCHAR(20),
    product_id   VARCHAR(20),
    quantity     NUMBER(5,0),

    FOREIGN KEY(order_id)   REFERENCES orders(order_id),
    FOREIGN KEY(product_id) REFERENCES products(product_id)

);

-- creating reviews table if not exists 
CREATE TABLE IF NOT EXISTS reviews(
    review_id   VARCHAR(20) PRIMARY KEY,
    product_id  VARCHAR(20),
    rating      NUMBER(3,2),

    FOREIGN KEY(product_id) REFERENCES products(product_id)
);

-- creating table review_comments if not exists 
CREATE TABLE IF NOT EXISTS review_comments(
    review_id VARCHAR(20),
    comment_type VARCHAR(100),
    comment VARCHAR(250),
    
    FOREIGN KEY(review_id) REFERENCES reviews(review_id)
);