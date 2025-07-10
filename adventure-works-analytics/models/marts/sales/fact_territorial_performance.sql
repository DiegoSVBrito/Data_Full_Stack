{{ config(materialized='table') }}

WITH
  enriched AS (
    SELECT * FROM {{ ref('int_sales__enriched') }}
  ),

  territorial_metrics AS (
    SELECT
      -- Dimensões de agrupamento
      territory_name,
      region,
      order_year,
      order_quarter,
      sales_channel,

      -- Métricas de volume
      COUNT(DISTINCT SalesOrderID) AS total_orders,
      COUNT(SalesOrderDetailID)    AS total_line_items,
      COUNT(DISTINCT CustomerID)   AS unique_customers,
      COUNT(DISTINCT ProductID)    AS unique_products,

      -- Métricas financeiras
      SUM(line_total)              AS total_revenue,
      AVG(line_total)              AS avg_line_value,
      SUM(order_total_due)         AS total_order_value,
      AVG(order_total_due)         AS avg_order_value,

      -- Métricas de performance
      SUM(CASE WHEN customer_type = 'Individual' THEN line_total ELSE 0 END) AS b2c_revenue,
      SUM(CASE WHEN customer_type IN ('Store/Business', 'Store Contact') THEN line_total ELSE 0 END) AS b2b_revenue,
      SUM(CASE WHEN sales_channel = 'Online' THEN line_total ELSE 0 END) AS online_revenue,
      SUM(CASE WHEN sales_channel = 'Offline' THEN line_total ELSE 0 END) AS offline_revenue

    FROM enriched
    WHERE territory_name IS NOT NULL
    GROUP BY
      territory_name,
      region,
      order_year,
      order_quarter,
      sales_channel
  ),

  with_rankings AS (
    SELECT
      *,
      -- Rankings por região
      RANK() OVER (
        PARTITION BY region, order_year, order_quarter 
        ORDER BY total_revenue DESC
      ) AS revenue_rank_in_region,
      
      -- Percentual de participação
      ROUND(
        total_revenue / SUM(total_revenue) OVER (
          PARTITION BY region, order_year, order_quarter
        ) * 100, 2
      ) AS revenue_share_in_region

    FROM territorial_metrics
  )

SELECT
  -- Dimensões
  territory_name,
  region,
  order_year,
  order_quarter,
  sales_channel,

  -- Métricas de volume
  total_orders,
  total_line_items,
  unique_customers,
  unique_products,

  -- Métricas financeiras
  total_revenue,
  avg_line_value,
  total_order_value,
  avg_order_value,

  -- Métricas de segmentação
  b2c_revenue,
  b2b_revenue,
  online_revenue,
  offline_revenue,

  -- Métricas de performance
  revenue_rank_in_region,
  revenue_share_in_region

FROM with_rankings
ORDER BY region, order_year, order_quarter, total_revenue DESC
;