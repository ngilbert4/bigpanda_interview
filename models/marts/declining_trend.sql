--Interview question: Identify customers with a declining trend in usage (last 3 months vs. prior 3 months).

{{
    config(
        materialized = 'table'
    )
}}

SELECT
    customer_id,
    SUM(
        CASE
            WHEN DATE(login_timestamp) >= DATEADD(month, -3, CURRENT_DATE)
                THEN logins
            ELSE 0
        END 
    ) AS last_three_months,
    SUM(
        CASE
            WHEN DATE(login_timestamp) >= DATEADD(month, -6, CURRENT_DATE)
                AND DATE(login_timestamp) <= DATEADD(month, -3, CURRENT_DATE)
                THEN logins
            ELSE 0
        END 
    ) AS prior_three_months,
    last_three_months - prior_three_months AS login_change
FROM {{ ref('stg_login_events') }}
GROUP BY 1
HAVING login_change < 0