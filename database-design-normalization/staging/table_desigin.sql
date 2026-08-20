-- ============================================================
-- 2. STAGINT TABLE 
-- ============================================================

USE SCHEMA STAGING;

CREATE OR REPLACE TABLE customers (
    customer_id   VARCHAR,
    customer_name VARCHAR,
    email         VARCHAR,
    phone         VARCHAR,
    city          VARCHAR,
    state         VARCHAR,
    country       VARCHAR,
    signup_date   DATE
);

CREATE OR REPLACE TABLE employees (
    employee_id     VARCHAR,
    employee_name   VARCHAR,
    department_id   VARCHAR,
    department_name VARCHAR,
    store_id        VARCHAR,
    store_name      VARCHAR,
    hire_date       DATE,
    salary          NUMBER(12,2)
);

CREATE OR REPLACE TABLE stores (
    store_id     VARCHAR,
    store_name   VARCHAR,
    city          VARCHAR,
    state        VARCHAR,
    country      VARCHAR,
    manager_id   VARCHAR,
    manager_name VARCHAR
);

CREATE OR REPLACE TABLE suppliers (
    supplier_id   VARCHAR,
    supplier_name VARCHAR,
    contact_email VARCHAR,
    city          VARCHAR,
    state         VARCHAR,
    country       VARCHAR
);

CREATE OR REPLACE TABLE products (
    product_id    VARCHAR,
    product_name  VARCHAR,
    category_id   VARCHAR,
    category_name VARCHAR,
    supplier_id   VARCHAR,
    supplier_name VARCHAR,
    unit_price    NUMBER(12,2)
);

CREATE OR REPLACE TABLE orders (
    order_id        VARCHAR,
    customer_id     VARCHAR,
    customer_name   VARCHAR,
    city            VARCHAR,
    state           VARCHAR,
    country         VARCHAR,
    order_date      DATE,
    store_id        VARCHAR,
    store_name      VARCHAR,
    employee_id     VARCHAR,
    employee_name   VARCHAR,
    department_id   VARCHAR,
    department_name VARCHAR,
    product_ids     VARCHAR,
    product_names   VARCHAR,
    quantities      VARCHAR,
    unit_prices     VARCHAR,
    payment_method  VARCHAR,
    payment_amount  NUMBER(12,2)
);

CREATE OR REPLACE TABLE order_items (
    order_id      VARCHAR,
    product_id    VARCHAR,
    product_name  VARCHAR,
    category_id   VARCHAR,
    category_name VARCHAR,
    quantity      NUMBER,
    unit_price    NUMBER(12,2),
    line_total    NUMBER(12,2)
);

CREATE OR REPLACE TABLE BCNF_PRACTICE (
    STORE_ID    VARCHAR,
    PRODUCT_ID  VARCHAR,
    SUPPLIER_ID VARCHAR
);

CREATE OR REPLACE TABLE DKNF_PRACTICE (
    PRODUCT_ID      VARCHAR,
    PRODUCT_NAME    VARCHAR,
    UNIT_PRICE      NUMBER(10,2),
    TAX_RATE        NUMBER(6,4),
    PRICE_WITH_TAX  NUMBER(10,2)
);

CREATE OR REPLACE TABLE EKNF_PRACTICE (
    STUDENT_NAME VARCHAR,
    SUBJECT      VARCHAR,
    TEACHER      VARCHAR
);

CREATE OR REPLACE TABLE ETNF_PRACTICE (
    EMPLOYEE_ID   VARCHAR,
    EMPLOYEE_NAME VARCHAR,
    PROJECT_NAME  VARCHAR,
    ROLE          VARCHAR
);

CREATE OR REPLACE TABLE JOIN_DEPENDENCY (
    SUPPLIER_ID VARCHAR,
    PRODUCT_ID  VARCHAR,
    STORE_ID    VARCHAR
);

CREATE OR REPLACE TABLE MULTIVALUED_DEPENDENCY (
    EMPLOYEE_ID   VARCHAR,
    EMPLOYEE_NAME VARCHAR,
    SKILL         VARCHAR,
    CERTIFICATION VARCHAR
);

CREATE OR REPLACE TABLE TEMPORAL_DEPARTMENT (
    EMPLOYEE_ID      VARCHAR,
    DEPARTMENT_ID    VARCHAR,
    DEPARTMENT_NAME  VARCHAR,
    VALID_FROM       DATE,
    VALID_TO         DATE
);

CREATE OR REPLACE TABLE TEMPORAL_SALARY (
    EMPLOYEE_ID VARCHAR,
    SALARY      NUMBER(12,2),
    VALID_FROM  DATE,
    VALID_TO    DATE
);
