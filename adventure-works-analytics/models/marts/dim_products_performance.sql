{{ config(materialized='table') }}

WITH product_sales_trends AS (
    SELECT 
        ProductID AS product_key,
        DATE_TRUNC('month', order_date) AS year_month,
        SUM(order_quantity) AS monthly_units,
        SUM(line_total) AS monthly_revenue,
        COUNT(DISTINCT CustomerID) AS unique_customers
    FROM {{ ref('fact_sales_transactions') }}
    GROUP BY ProductID, DATE_TRUNC('month', order_date)
),

product_lifecycle AS (
    SELECT 
        product_key,
        MIN(year_month) AS launch_month,
        MAX(year_month) AS last_sale_month,
        COUNT(DISTINCT year_month) AS active_months,
        SUM(monthly_units) AS total_units_sold,
        SUM(monthly_revenue) AS total_revenue,
        AVG(monthly_units) AS avg_monthly_units,
        
        -- Calcular tendência dos últimos 6 meses
        AVG(CASE WHEN year_month >= ADD_MONTHS(CURRENT_DATE(), -6) 
                 THEN monthly_units END) AS recent_avg_units,
        AVG(CASE WHEN year_month >= ADD_MONTHS(CURRENT_DATE(), -12) 
                 AND year_month < ADD_MONTHS(CURRENT_DATE(), -6)
                 THEN monthly_units END) AS previous_avg_units
    FROM product_sales_trends
    GROUP BY product_key
),

product_classification AS (
    SELECT 
        *,
        CASE 
            WHEN recent_avg_units > previous_avg_units * 1.2 THEN 'Crescimento'
            WHEN recent_avg_units > previous_avg_units * 0.8 THEN 'Maturidade'
            WHEN recent_avg_units > 0 THEN 'Declínio'
            ELSE 'Descontinuado'
        END AS lifecycle_stage,
        
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS revenue_quintile,
        
        CASE 
            WHEN total_revenue >= 100000 THEN 'Top Performer'
            WHEN total_revenue >= 50000 THEN 'Good Performer'
            WHEN total_revenue >= 10000 THEN 'Average Performer'
            ELSE 'Low Performer'
        END AS performance_category
    FROM product_lifecycle
)

SELECT 
    pc.product_key,
    dp.product_name,
    dp.category_name,
    dp.ProductSubcategoryID,
    pc.launch_month,
    pc.last_sale_month,
    pc.active_months,
    pc.total_units_sold,
    pc.total_revenue,
    pc.avg_monthly_units,
    pc.recent_avg_units,
    pc.previous_avg_units,
    pc.lifecycle_stage,
    pc.revenue_quintile,
    pc.performance_category,
    CURRENT_DATE() AS updated_at
FROM product_classification pc
LEFT JOIN {{ ref('dim_product') }} dp ON pc.product_key = dp.ProductID