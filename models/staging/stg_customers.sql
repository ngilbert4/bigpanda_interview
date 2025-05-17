{{
    config(
        materialized = 'table'
    )
}}

SELECT
    customer_id,
    acquisition_date,
    region,
    industry
FROM {{ source('bigpanda', 'customers')}}