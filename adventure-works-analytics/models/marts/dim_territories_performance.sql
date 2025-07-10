{{ config(materialized='table') }}

WITH territory_metrics AS (
    SELECT 
        f.TerritoryID AS territory_key,
        f.territory_name,
        f.region AS country_region,
        COUNT(DISTINCT f.SalesOrderID) AS total_orders,
        SUM(f.line_total) AS total_revenue,
        COUNT(DISTINCT f.CustomerID) AS unique_customers,
        AVG(f.line_total) AS avg_order_value,
        
        -- Métricas por vendedor (se aplicável)
        COUNT(DISTINCT f.SalesPersonID) AS active_salespeople,
        SUM(f.line_total) / NULLIF(COUNT(DISTINCT f.SalesPersonID), 0) AS revenue_per_salesperson
    FROM {{ ref('fact_sales_transactions') }} f
    WHERE f.order_date >= ADD_MONTHS(CURRENT_DATE(), -24)
      AND f.TerritoryID IS NOT NULL
    GROUP BY f.TerritoryID, f.territory_name, f.region
),

territory_rankings AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        RANK() OVER (ORDER BY revenue_per_salesperson DESC) AS efficiency_rank,
        RANK() OVER (ORDER BY avg_order_value DESC) AS aov_rank,
        
        CASE 
            WHEN revenue_per_salesperson >= 500000 THEN 'High ROI'
            WHEN revenue_per_salesperson >= 250000 THEN 'Medium ROI'
            WHEN revenue_per_salesperson >= 100000 THEN 'Low ROI'
            ELSE 'Very Low ROI'
        END AS roi_category,
        
        NTILE(4) OVER (ORDER BY total_revenue DESC) AS performance_quartile
    FROM territory_metrics
)

SELECT 
    territory_key,
    territory_name,
    country_region,
    total_orders,
    total_revenue,
    unique_customers,
    avg_order_value,
    active_salespeople,
    revenue_per_salesperson,
    revenue_rank,
    efficiency_rank,
    aov_rank,
    roi_category,
    performance_quartile,
    CURRENT_DATE() AS updated_at
FROM territory_rankings