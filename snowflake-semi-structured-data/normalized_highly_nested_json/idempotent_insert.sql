MERGE INTO mart.customer_email AS target
USING (
    SELECT DISTINCT
        c.customer_id,
        e.value:type::STRING AS email_type,
        a.value:email::STRING AS email,
        a.value:verified::BOOLEAN AS verified
    FROM staging_stream AS s

    INNER JOIN mart.customers AS c
        ON c.first_name =
           s.data:customer:profile:personal:name:first::STRING
       AND c.last_name =
           s.data:customer:profile:personal:name:last::STRING

    CROSS JOIN LATERAL FLATTEN(
        INPUT => s.data:customer:profile:personal:contact:emails
    ) AS e

    CROSS JOIN LATERAL FLATTEN(
        INPUT => e.value:addresses
    ) AS a
) AS source

ON target.customer_id = source.customer_id
AND target.email = source.email

WHEN MATCHED THEN
    UPDATE SET
        target.email_type = source.email_type,
        target.verified   = source.verified

WHEN NOT MATCHED THEN
    INSERT (
        customer_id,
        email_type,
        email,
        verified
    )
    VALUES (
        source.customer_id,
        source.email_type,
        source.email,
        source.verified
    );