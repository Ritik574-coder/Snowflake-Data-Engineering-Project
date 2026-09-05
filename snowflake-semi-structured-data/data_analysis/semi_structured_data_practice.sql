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

-- extracting customer pii info 
SELECT
    nd.data:customer:profile:personal:name:first::STRING as first_name,
    nd.data:customer:profile:personal:name:last::STRING  as last_name,
    a.value:email::STRING as email,
    a.value:verified::BOOLEAN as verified,
    e.value:type::STRING as email_type
FROM nested_data as nd,
LATERAL FLATTEN(
    INPUT => nd.data:customer:profile:personal:contact:emails
) AS e,
LATERAL FLATTEN(
    INPUT => e.value:addresses
)  as a;


-- extraction product info 
SELECT 
    o.value:order_id::STRING as order_id,
    i.value:product:product_id::STRING as product_id,
    i.value:product:name::STRING AS product_name,
    i.value:quantity::NUMBER AS quantity
FROM nested_data as nd,

    LATERAL FLATTEN(
        INPUT => nd.data:customer:orders
    ) as o,

    LATERAL FLATTEN(
        INPUT => o.value:items
    ) as i
;

-- extracting review info 
SELECT 
    r.value:review_id::STRING as review_id,
    r.value:rating::NUMBER as rating,
    c.value:text::STRING as comments,
    c.value:type::STRING as comment_type
FROM nested_data as nd,

    LATERAL FLATTEN(
        INPUT => nd.data:customer:orders
    ) as o,

    LATERAL FLATTEN(
        INPUT => o.value:items
    ) as i,

    LATERAL FLATTEN(
        INPUT => i.value:reviews
    ) as r,

    LATERAL FLATTEN(
        r.value:comments
    ) as c
;

-- EXTRACTING KEYS 
SELECT 
    OBJECT_KEYS(c.value) AS KEYS 
FROM nested_data as nd,
    LATERAL FLATTEN(
        INPUT => nd.data:customer:orders
    ) as o,
    LATERAL FLATTEN(
        INPUT => o.value:items
    ) as i, 
    LATERAL FLATTEN(
        INPUT => i.value:reviews
    ) as r,
    LATERAL FLATTEN(
        r.value:comments
    ) as c 
;


-- customers order info 
SELECT
    nd.data:customer:profile:personal:name:first::STRING as first_name,
    nd.data:customer:profile:personal:name:last::STRING  as last_name,
    a.value:email::STRING as email,
    a.value:verified::BOOLEAN as verified,
    e.value:type::STRING as email_type,
    o.value:order_id::STRING as order_id,
    i.value:product:product_id::STRING as product_id,
    i.value:product:name::STRING AS product_name,
    i.value:quantity::NUMBER AS quantity,
    r.value:review_id::STRING as review_id,
    r.value:rating::NUMBER as rating,
    c.value:text::STRING as comments,
    c.value:type::STRING as comment_type
FROM nested_data as nd,
    LATERAL FLATTEN(
        INPUT => nd.data:customer:profile:personal:contact:emails
    ) AS e,
    LATERAL FLATTEN(
        INPUT => e.value:addresses
    )  as a,
    LATERAL FLATTEN(
        INPUT => nd.data:customer:orders
    ) as o,

    LATERAL FLATTEN(
        INPUT => o.value:items
    ) as i,
    LATERAL FLATTEN(
        INPUT => i.value:reviews
    ) as r,

    LATERAL FLATTEN(
        INPUT => r.value:comments
    ) as c
;
