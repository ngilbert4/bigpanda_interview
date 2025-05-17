--Interview question: Calculate Monthly Recurring Revenue per Customer

{{
    config(
        materialized = 'table'
    )
}}

--Assuming there are multiple products offered since there is a product_id field. Summing num_months_sub gives the total number of months across all products.
SELECT
    customer_id,
    SUM(DATEDIFF(month, start_date, end_date)) AS num_months_sub,
    SUM((arr * quantity) / num_months_sub) AS monthly_arr
FROM {{ ref('stg_subscriptions') }}
GROUP BY 1