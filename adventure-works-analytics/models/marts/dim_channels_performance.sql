{{ config(materialized='table') }}

WITH channel_identification AS (
    SELECT 
        f.*,
        CASE 
            WHEN f.sales_channel = 'Online' THEN 'Online'
            WHEN f.sales_channel = 'Offline' THEN 'Reseller'
            ELSE 'Other'
        END AS channel_type
    FROM {{ ref('fact_sales_transactions') }} f
),

channel_metrics AS (
    SELECT 
        channel_type,
        COUNT(DISTINCT SalesOrderID) AS total_orders,
        SUM(line_total) AS total_revenue,
        COUNT(DISTINCT CustomerID) AS unique_customers,
        AVG(line_total) AS avg_order_value,
        SUM(order_quantity) AS total_units_sold,
        
        -- Métricas de eficiência
        SUM(line_total) / COUNT(DISTINCT CustomerID) AS revenue_per_customer,
        COUNT(DISTINCT SalesOrderID) / COUNT(DISTINCT CustomerID) AS orders_per_customer
    FROM channel_identification
    WHERE order_date >= ADD_MONTHS(CURRENT_DATE(), -24)
    GROUP BY channel_type
),

channel_performance AS (
    SELECT 
        *,
        CASE 
            WHEN revenue_per_customer >= 2000 THEN 'High Value'
            WHEN revenue_per_customer >= 1000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_value_segment,
        
        CASE 
            WHEN orders_per_customer >= 3 THEN 'High Frequency'
            WHEN orders_per_customer >= 2 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS purchase_frequency_segment
    FROM channel_metrics
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS channel_key,
    channel_type,
    total_orders,
    total_revenue,
    unique_customers,
    avg_order_value,
    total_units_sold,
    revenue_per_customer,
    orders_per_customer,
    customer_value_segment,
    purchase_frequency_segment,
    CURRENT_DATE() AS updated_at
FROM channel_performance