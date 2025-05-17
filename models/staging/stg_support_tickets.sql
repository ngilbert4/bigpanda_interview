{{
    config(
        materialized = 'table',
        cluster_by = ['customer_id']
    )
}}

SELECT
    ticket_id,
    customer_id,
    user_type,
    login_timestamp
FROM {{ source('bigpanda', 'support_tickets') }}