
-- switch corrent database 
USE DATABASE SEMI_STRUCTURED_DB ;


-- Insert Unique Customer Records
INSERT INTO mart.customers(
    first_name,
    last_name
)
SELECT DISTINCT
    data:customer:profile:personal:name:first::STRING as first_name,
    data:customer:profile:personal:name:last::STRING  as last_name
FROM staging.nested_data
;

-- Insert Customer Email Records
INSERT INTO mart.customer_email(
    customer_id,
    type,
    email,
    verified
)
SELECT 
    c.customer_id,
    e.value:type::STRING as email_type,
    a.value:email::STRING as email,
    a.value:verified::BOOLEAN as verified
FROM staging.nested_data as nd

INNER JOIN mart.customers as c 
ON c.first_name = 
        nd.data:customer:profile:personal:name:first::STRING
AND 
    c.last_name = 
        nd.data:customer:profile:personal:name:last::STRING

CROSS JOIN LATERAL FLATTEN(
        INPUT => nd.data:customer:profile:personal:contact:emails
    ) AS e

CROSS JOIN LATERAL FLATTEN(
        INPUT => e.value:addresses
    )  as a
;

-- Insert Customer Order Records
INSERT INTO mart.orders(
    order_id,
    customer_id
)
SELECT 
    o.value:order_id::STRING as order_id,
    c.customer_id
FROM staging.nested_data as nd
INNER JOIN mart.customers as c 
ON 
    c.first_name =
        nd.data:customer:profile:personal:name:first::STRING
AND 
    c.last_name =
        nd.data:customer:profile:personal:name:last::STRING

CROSS JOIN LATERAL FLATTEN(
        INPUT => nd.data:customer:orders
    ) as o
;



-- Insert Unique Product Records
INSERT INTO mart.products(
    product_id,
    product_name
)
SELECT 
    i.value:product:product_id::STRING as product_id,
    i.value:product:name::STRING AS product_name
FROM staging.nested_data as nd
CROSS JOIN LATERAL FLATTEN(
        INPUT => nd.data:customer:orders
    ) as o

CROSS JOIN LATERAL FLATTEN(
        INPUT => o.value:items
    ) as i
;


-- Insert Order Item Records
INSERT INTO mart.order_items(
    order_id,
    product_id,
    quantity
)
SELECT 
    oi.order_id,
    p.product_id,
    i.value:quantity::NUMBER as quantity
FROM staging.nested_data as nd

CROSS JOIN LATERAL FLATTEN(
    INPUT => nd.data:customer:orders
    ) as o

INNER JOIN mart.orders as oi
ON oi.order_id =
    o.value:order_id::STRING

CROSS JOIN LATERAL FLATTEN(
    INPUT => o.value:items
    ) as i

INNER JOIN mart.products as p 
ON p.product_id =
    i.value:product:product_id::STRING
;

-- Insert Product Review Records
INSERT INTO mart.reviews(
    review_id,
    product_id,
    rating
)
SELECT 
    r.value:review_id::STRING as review_id,
    p.product_id,
    r.value:rating::NUMBER as rating
FROM staging.nested_data as nd

CROSS JOIN LATERAL FLATTEN(
        INPUT => nd.data:customer:orders
    ) as o

CROSS JOIN LATERAL FLATTEN(
        INPUT => o.value:items
    ) as i

INNER JOIN mart.products as p 
    ON p.product_id =
    i.value:product:product_id::STRING

CROSS JOIN LATERAL FLATTEN(
        INPUT => i.value:reviews
    ) as r
;


-- Insert Review Comment Records
INSERT INTO mart.review_comments(
    review_id,
    comment_type,
    comment
)
SELECT 
    rr.review_id,
    c.value:type::STRING as comment_type,
    c.value:text::STRING as comments
FROM staging.nested_data as nd

CROSS JOIN LATERAL FLATTEN(
        INPUT => nd.data:customer:orders
    ) as o

CROSS JOIN LATERAL FLATTEN(
        INPUT => o.value:items
    ) as i

CROSS JOIN LATERAL FLATTEN(
        INPUT => i.value:reviews
    ) as r

INNER JOIN mart.reviews as rr 
    ON rr.review_id = 
    r.value:review_id::STRING

CROSS JOIN LATERAL FLATTEN(
        INPUT => r.value:comments
    ) as c
;

