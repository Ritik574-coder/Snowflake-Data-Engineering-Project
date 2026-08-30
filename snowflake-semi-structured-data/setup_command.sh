#!/bin/bash

set -e

echo "================================================================="
echo "=============== CHECKING THE CONNECTION LIST ===================="
echo "================================================================="

snow connection list

echo ""
echo "================================================================="
echo "================ RUNNING DATABASE INITIALIZATION ================"
echo "================================================================="

snow sql \
    -c modern_data_engineering_snowflake \
    -f /home/ritik/Snowflake-Data-Engineering-Project/snowflake-semi-structured-data/init_databse.sql

echo ""
echo "================================================================="
echo "===================== CREATING TABLE  ==========================="
echo "================================================================="

snow sql \
    -c modern_data_engineering_snowflake \
    -f /home/ritik/Snowflake-Data-Engineering-Project/snowflake-semi-structured-data/customers/ddl_customer.sql

snow sql \
    -c modern_data_engineering_snowflake \
    -f /home/ritik/Snowflake-Data-Engineering-Project/snowflake-semi-structured-data/products/ddl_products.sql

snow sql \
    -c modern_data_engineering_snowflake \
    -f /home/ritik/Snowflake-Data-Engineering-Project/snowflake-semi-structured-data/orders/ddl_orders.sql


echo ""
echo "================================================================="
echo "===================== INSERTING DATA  ==========================="
echo "================================================================="


snow sql \
    -c modern_data_engineering_snowflake \
    -f /home/ritik/Snowflake-Data-Engineering-Project/snowflake-semi-structured-data/customers/insert_customers.sql

snow sql \
    -c modern_data_engineering_snowflake \
    -f /home/ritik/Snowflake-Data-Engineering-Project/snowflake-semi-structured-data/products/insert_products.sql

snow sql \
    -c modern_data_engineering_snowflake \
    -f /home/ritik/Snowflake-Data-Engineering-Project/snowflake-semi-structured-data/orders/insert_orders.sql

echo ""
echo "================================================================="
echo "===================== SETUP COMPLETED ==========================="
echo "================================================================="