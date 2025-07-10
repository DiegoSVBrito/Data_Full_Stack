{{ config(materialized='table') }}

WITH customer_metrics AS (
    SELECT 
        CustomerID AS customer_key,
        MIN(order_date) AS first_purchase_date,
        MAX(order_date) AS last_purchase_date,
        COUNT(DISTINCT SalesOrderID) AS total_orders,
        SUM(line_total) AS lifetime_revenue,
        AVG(line_total) AS avg_order_value,
        DATEDIFF(MAX(order_date), MIN(order_date)) AS customer_lifespan_days
    FROM {{ ref('fact_sales_transactions') }}
    GROUP BY CustomerID
),

customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN lifetime_revenue >= 10000 THEN 'VIP'
            WHEN lifetime_revenue >= 5000 THEN 'Premium' 
            WHEN lifetime_revenue >= 1000 THEN 'Regular'
            ELSE 'Basic'
        END AS customer_segment,
        
        CASE 
            WHEN customer_lifespan_days > 0 
            THEN lifetime_revenue / (customer_lifespan_days / 30.0)
            ELSE lifetime_revenue 
        END AS monthly_value,
        
        NTILE(10) OVER (ORDER BY lifetime_revenue DESC) AS clv_decile
    FROM customer_metrics
)

SELECT 
    cs.customer_key,
    dc.CustomerID,
    dc.AccountNumber,
    dc.customer_type,
    dc.business_segment,
    dc.account_status,
    dc.territory_status,
    cs.first_purchase_date,
    cs.last_purchase_date,
    cs.total_orders,
    cs.lifetime_revenue,
    cs.avg_order_value,
    cs.customer_lifespan_days,
    cs.monthly_value,
    cs.customer_segment,
    cs.clv_decile,
    CURRENT_DATE() AS updated_at
FROM customer_segments cs
LEFT JOIN {{ ref('dim_customer') }} dc ON cs.customer_key = dc.CustomerID