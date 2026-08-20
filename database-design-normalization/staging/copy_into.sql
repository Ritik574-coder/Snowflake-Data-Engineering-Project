-- ============================================================
-- COPY INTO COMMANDS FOR ALL STAGED FILES
-- ============================================================

USE DATABASE NORMALIZE_DW;
USE SCHEMA STAGING;

-- Create a file format for CSV files
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1;

-- Main tables
COPY INTO customers FROM @STAGING_STAGE/customers.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO employees FROM @STAGING_STAGE/employees.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO stores FROM @STAGING_STAGE/stores.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO suppliers FROM @STAGING_STAGE/suppliers.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO products FROM @STAGING_STAGE/products.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO orders FROM @STAGING_STAGE/orders.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO order_items FROM @STAGING_STAGE/order_items.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');

-- Normalization practice tables
COPY INTO bcnf_practice FROM @STAGING_STAGE/bcnf_practice.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO dknf_practice FROM @STAGING_STAGE/dknf_practice.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO eknf_practice FROM @STAGING_STAGE/eknf_practice.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO etnf_practice FROM @STAGING_STAGE/etnf_practice.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO join_dependency FROM @STAGING_STAGE/join_dependency.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO multivalued_dependency FROM @STAGING_STAGE/multivalued_dependency.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO temporal_department FROM @STAGING_STAGE/temporal_department.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');
COPY INTO temporal_salary FROM @STAGING_STAGE/temporal_salary.csv.gz FILE_FORMAT = (FORMAT_NAME = 'csv_format');