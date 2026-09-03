-- switch databse to semi_stracture_db
USE DATABASE SEMI_STRUCTURED_DB;

-- switch to correct schema staging
USE SCHEMA STAGING;

-- extracting 3 sample row from customer table to understand the data
SELECT * FROM customers LIMIT 3;

-- extracting 3 sample row from products table to understand the data
SELECT * FROM products LIMIT 3;

-- extracting 3 sample row from orders table to understand the data
SELECT * FROM orders LIMIT 3;


DESCRIBE TABLE customers;

SELECT 

    -- customer_pii info 
    c.customer_id,
    c.customer_name,

    -- customer_profiles_info 
    c.customer_data:profile:first_name::STRING AS first_name,
    c.customer_data:profile:last_name::STRING AS last_name,
    c.customer_data:profile:gender::STRING AS gender,
    c.customer_data:profile:is_active::STRING AS is_active,
    c.customer_data:profile:email::STRING AS email,
    c.customer_data:profile:loyalty_tier::STRING AS loyalty_tier,
    c.customer_data:profile:account_balance::FLOAT AS account_balance,
    c.customer_data:profile:lifetime_value::FLOAT as lifetime_value,
    c.customer_data:profile:birth_date::DATE AS birth_date,
    c.customer_data:profile:join_date::DATE AS join_date,

    -- customer_address info
    c.customer_data:address:country::STRING AS country,
    c.customer_data:address:state::STRING AS STATE,
    c.customer_data:address:city::STRING AS city,
    c.customer_data:address:zip::NUMBER AS zip_code,
    c.customer_data:address:street::STRING AS street_info,
    c.customer_data:address:type::STRING AS custoemr_type,

    -- customer_preferences info 
    p.value::STRING AS marketing_channels,
    c.customer_data:preferences:preferred_currency::STRING AS preferred_currency,
    c.customer_data:preferences:preferred_language::STRING AS preferred_language,
    c.customer_data:preferences:newsletter_opt_in::BOOLEAN AS newsletter_opt_in,
    c.customer_data:preferences:notification_settings:email::BOOLEAN AS email,
    c.customer_data:preferences:notification_settings:push::BOOLEAN AS push,
    c.customer_data:preferences:notification_settings:sms::BOOLEAN AS sms, 

    -- customer device info 
    d.value:device_id::STRING AS device_id,
    d.value:device_type::STRING AS device_type,
    d.value:is_trusted::BOOLEAN AS is_trusted,
    d.value:last_login::TIMESTAMP_TZ AS last_login,
    d.value:os::STRING AS system

FROM customers AS c,
LATERAL FLATTEN(
    INPUT => c.customer_data:preferences:marketing_channels
) AS p,

LATERAL FLATTEN(
    INPUT => c.customer_data:devices
) AS d;

 
