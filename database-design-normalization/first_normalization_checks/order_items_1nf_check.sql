-- ===========================================================================================
-- ===================== FIRST NORMALIZATION CHECK IN ORDERS DATASET =========================
-- ===========================================================================================
-- switch to corrent databse 
USE DATABASE NORMALIZE_DW ;

-- Switch to corrent schema 
USE SCHEMA STAGING ;  

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name ORDER_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            ORDER_ID, '.*[!:;,|*].*'
        )
    ) AS suspicious_count
FROM order_items ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name PRODUCT_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PRODUCT_ID, '.*[!:;,|*].*'
        )
    ) AS suspicious_count
FROM order_items ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name PRODUCT_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            PRODUCT_NAME, '.*[!:;,|*].*'
        )
    ) AS suspicious_count
FROM order_items ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CATEGORY_ID
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CATEGORY_ID, '.*[!:;,|*].*'
        )
    ) AS suspicious_count
FROM order_items ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name CATEGORY_NAME
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            CATEGORY_NAME, '.*[!:;,|*].*'
        )
    ) AS suspicious_count
FROM order_items ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name QUANTITY
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            QUANTITY, '.*[!:;,|*].*'
        )
    ) AS suspicious_count
FROM order_items ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name UNIT_PRICE
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            UNIT_PRICE, '.*[!:;,|*].*'
        )
    ) AS suspicious_count
FROM order_items ;

-- checking suspicious row and checking the every colimn contain single atomic valiue and these are not represent group in column name LINE_TOTAL
SELECT 
    COUNT(*) AS total_row,
    COUNT_IF(
        REGEXP_LIKE(
            LINE_TOTAL, '.*[!:;,|*].*'
        )
    ) AS suspicious_count
FROM order_items ;

