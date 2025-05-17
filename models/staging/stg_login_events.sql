{{
    config(
        materialized = 'incremental',
        partition_by = {
            "field": "login_timestamp",
            "data_type": "TIMESTAMP",
            "granularity": "day"
        }
    )
}}

SELECT
    user_id,
    customer_id,
    user_type,
    login_timestamp
FROM {{ source('bigpanda', 'login_events') }}

{% if is_incremental() %}
WHERE DATE(login_timestamp) > (SELECT MAX(DATE(login_timestamp) FROM {{ this }}))
{% endif %}