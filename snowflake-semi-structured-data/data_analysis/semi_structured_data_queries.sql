/*#################################################################################################################
### Nested JSON Data Extraction — Direct Path Navigation

    This SQL demonstrates extracting deeply nested semi-structured JSON data
    in Snowflake using direct JSON path navigation and array indexing.
    The approach intentionally uses explicit array indexes such as `[0]`,
    `[1]`, etc. to practice understanding and navigating nested JSON structures.

### Approach Used

This method is suitable when:
====================================================================================================
    * The required array positions are known in advance.
    * Only specific elements from a nested JSON structure are required.
    * The goal is to learn and validate JSON path navigation.
    * The JSON structure is relatively predictable and the extraction requirements are fixed.
====================================================================================================
 
#################################################################################################################*/

-- SWITCH DATABSE TO SEMI_STRUCTURED_DB
USE DATABASE SEMI_STRUCTURED_DB; 

-- SWITCH SCHEMA TO STAGING 
USE SCHEMA STAGING ; 

-- EXTRACTING 3 SAMPLE ROW FROM CUSTOMERS TABLE TO UNDERSTAND THE DATA 
SELECT 
    *
FROM nested_data LIMIT 3;

-- EXTRACTING KEYS 
SELECT 
    OBJECT_KEYS(data:customer:profile:personal:contact:emails) as profile
FROM nested_data 
LIMIT 100; 

-- Nested JSON Data Extraction — Direct Path Navigation
SELECT 
    data:customer:profile:personal:name:first::STRING                               as first_name,
    data:customer:profile:personal:name:last::STRING                                as last_name,
    data:customer:profile:personal:contact:emails[0]:addresses[0]:email::STRING     as first_email,
    data:customer:profile:personal:contact:emails[0]:addresses[0]:verified::BOOLEAN as first_verified_email,
    data:customer:profile:personal:contact:emails[0]:addresses[1]:email::STRING     as second_email,
    data:customer:profile:personal:contact:emails[0]:addresses[1]:verified::BOOLEAN as second_verified_email,
    data:customer:profile:personal:contact:emails[0]:type::STRING                   as first_email_type,
    data:customer:profile:personal:contact:emails[1]:addresses[0]:email::STRING     as third_email,
    data:customer:profile:personal:contact:emails[1]:addresses[0]:verified::BOOLEAN as third_verified_email,
    data:customer:profile:personal:contact:emails[1]:type::STRING                   as second_email_type,

    data:customer:orders[0]:order_id::STRING                                        as order_id,

    data:customer:orders[0]:items[0]:product:product_id::STRING                     as first_product_id,
    data:customer:orders[0]:items[0]:product:name::STRING                           as first_product_name,
    data:customer:orders[0]:items[1]:product:product_id::STRING                     as second_product_id,
    data:customer:orders[0]:items[1]:product:name::STRING                           as second_product_name,

    data:customer:orders[0]:items[0]:quantity::NUMBER                               as first_product_quantity,
    data:customer:orders[0]:items[1]:quantity::NUMBER                               as second_product_quantity,

    data:customer:orders[0]:items[0]:reviews[0]:review_id::STRING                   as forst_review_id,
    data:customer:orders[0]:items[0]:reviews[0]:rating::NUMBER                      as fist_rating,
    data:customer:orders[0]:items[1]:reviews[0]:review_id::STRING                   as second_review_id,
    data:customer:orders[0]:items[1]:reviews[0]:rating::NUMBER                      as second_rating,

    data:customer:orders[0]:items[0]:reviews[0]:comments[0]:text::STRING            as forst_review_text,
    data:customer:orders[0]:items[0]:reviews[0]:comments[0]:type::STRING            as forst_review_type,
    data:customer:orders[0]:items[0]:reviews[0]:comments[1]:text::STRING            as second_review_text,
    data:customer:orders[0]:items[0]:reviews[0]:comments[1]:type::STRING            as second_review_type,
    data:customer:orders[0]:items[1]:reviews[0]:comments[0]:text::STRING            as third_review_text,
    data:customer:orders[0]:items[1]:reviews[0]:comments[0]:type::STRING            as third_review_type,
    data:customer:orders[0]:items[1]:reviews[0]:comments[1]:text::STRING            as forth_review_text,
    data:customer:orders[0]:items[1]:reviews[0]:comments[1]:type::STRING            as forth_review_type
FROM nested_data LIMIT 100; 
