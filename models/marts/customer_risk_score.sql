/*
Interview question: Define how you would calculate a "Customer Risk Score" using the available data

Overview: Total possible score of 5 points (highest risk customer), 4 different weighted categories

Assumptions made:
1. The subscriptions are of varying timeframes (e.g. annual not only option) and there is no free tier.
2. Anyone listed in the customer table has purchased 1 or more paid subscriptions to be considered a customer.
3. The asks from the SQL questions section are actual KPIs used at this SaaS company.
4. For simplicity and to give something to base the login score off, I decided the average login for the product is 2x per week.

Other data sets to improve the score:
1. Having more granular events data would help us understand how customers are using the site. If they're only logging in once a week, but spending an hour in
the product, it might warrant giving them a higher score vs a customer who is in there for a few minutes 3 times a week.
2. A dataset with results of an AI/ML analysis where customer sentiment is analyzed using the description of the support tickets. This helps understand if
customers are filing tickets out of frustration vs passion for the product. Sentiment in a bug support ticket could vary drastically from a feature request
ticket.
3. Any type of Qualtrics or other product survey dataset to understand what users think of the product overall and how useful they find it.
*/

{{
    config(
        materialized = 'table'
    )
}}

--create a score to give users points based on login activity
WITH login_activity AS (
    SELECT
        customer_id,
        CASE
            WHEN DATEDIFF(month, c.acquisition_date, CURRENT_DATE) < 6
                AND last_three_months / DATEDIFF(week, c.acquisition_date, CURRENT_DATE) < 2
                THEN 3
            WHEN last_three_months / prior_three_months <= 0.33
                THEN 5
            WHEN last_three_months / prior_three_months <= 0.66
                THEN 4
            WHEN last_three_months / prior_three_months <= 0.85
                THEN 3
            WHEN last_three_months / prior_three_months < 1
                THEN 1
        END AS login_score
    FROM {{ ref('declining_trend') }}
),

--create a score to give users points based on number of purchase history
orders AS (
    SELECT
        customer_id,
        CASE
            WHEN number_of_orders = 1
                THEN 5
            WHEN number_of_orders > 1 AND number_of_orders <= 3
                THEN 3
            WHEN number_of_orders > 3
                THEN 0
        END AS order_score
    FROM {{ ref('sub_history') }}
),

--create a score to give users points based on support tickets
support AS (
    SELECT
        customer_id,
        CASE
            WHEN open_tickets > 7
                THEN 5
            WHEN open_tickets > 5
                THEN 4
            ELSE 3
        END AS support_score
    FROM {{ ref('unresolved_support_tickets') }}
)

SELECT
    c.customer_id,
    DATEDIFF(month, c.acquisition_date, CURRENT_DATE) * 0.1 AS tenure_score_wtd
    IFNULL(l.login_score, 0) * 0.5 AS login_score_wtd,
    o.order_score * 0.1 AS order_score_wtd,
    IFNULL(s.support_score, 0) * 0.3 AS support_score_wtd,
    tenure_score_wtd + login_score_wtd + order_score_wtd + support_score_wtd AS customer_risk_score
FROM {{ ref('stg_customers') }} AS c
LEFT JOIN login_activity AS l
    ON c.customer_id = l.customer_id
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN support AS s
    ON c.customer_id = s.customer_id