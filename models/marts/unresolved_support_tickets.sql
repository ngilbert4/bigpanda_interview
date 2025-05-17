--Interview question: Flag customers with >3 support tickets unresolved for over 14 days.
{{
    config(
        materialized = 'table'
    )
}}

WITH open_support_tickets AS (
    SELECT
        customer_id,
        ticket_id,
        DATEDIFF(day, DATE(created_date), CURRENT_DATE) AS days_open
    FROM {{ ref('stg_support_tickets') }} AS s
    --Assuming status = 'on-hold' is still considered a "resolved" ticket but there is a reason it cannot be closed
    WHERE s.status = 'open'
    GROUP BY
        customer_id,
        ticket_id
)

SELECT
    customer_id,
    COUNT(ticket_id) AS open_tickets
FROM open_support_tickets
WHERE days_open > 14
GROUP BY 1
HAVING open_tickets > 3