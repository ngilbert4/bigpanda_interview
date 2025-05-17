{{
    config(
        materialized = 'table',
        cluster_by = ['customer_id']
    )
}}

SELECT
    customer_id,
    product_id,
    quantity,
    start_date,
    end_date,
    arr
FROM {{ source('bigpanda', 'subscriptions') }}
