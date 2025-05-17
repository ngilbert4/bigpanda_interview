SELECT
    customer_id,
    COUNT(product_id) AS num_of_orders,
    SUM(quantity) AS num_of_products 
FROM {{ ref(stg_subscriptions) }} AS s
GROUP BY 1