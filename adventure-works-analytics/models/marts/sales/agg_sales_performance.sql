{{ config(materialized='table') }}

WITH
  enriched AS (
    SELECT * FROM {{ ref('int_sales__enriched') }}
  ),

  sales_aggregation AS (
    SELECT
      -- Dimensões principais
      order_year,
      order_month,
      order_quarter,
      sales_channel,
      customer_type,
      territory_name,
      region,

      -- Agregações de volume
      COUNT(DISTINCT SalesOrderID) AS total_orders,
      COUNT(SalesOrderDetailID) AS total_line_items,
      COUNT(DISTINCT CustomerID) AS unique_customers,
      COUNT(DISTINCT ProductID) AS unique_products,
      SUM(order_quantity) AS total_quantity_sold,

      -- Agregações financeiras
      SUM(line_total) AS total_revenue,
      AVG(line_total) AS avg_line_value,
      MIN(line_total) AS min_line_value,
      MAX(line_total) AS max_line_value,
      SUM(order_total_due) AS total_order_value,
      AVG(order_total_due) AS avg_order_value,

      -- Métricas de performance
      COUNT(DISTINCT CASE WHEN order_revenue_category = 'High Value (10K+)' THEN CustomerID END) AS high_value_customers,
      COUNT(DISTINCT CASE WHEN order_revenue_category = 'Medium Value (1K-10K)' THEN CustomerID END) AS medium_value_customers,
      COUNT(DISTINCT CASE WHEN order_revenue_category = 'Low Value (100-1K)' THEN CustomerID END) AS low_value_customers,

      -- Segmentação por canal
      SUM(CASE WHEN sales_channel = 'Online' THEN line_total ELSE 0 END) AS online_revenue,
      SUM(CASE WHEN sales_channel = 'Offline' THEN line_total ELSE 0 END) AS offline_revenue,

      -- Segmentação por tipo de cliente
      SUM(CASE WHEN customer_type = 'Individual' THEN line_total ELSE 0 END) AS b2c_revenue,
      SUM(CASE WHEN customer_type IN ('Store/Business', 'Store Contact') THEN line_total ELSE 0 END) AS b2b_revenue

    FROM enriched
    GROUP BY
      order_year,
      order_month,
      order_quarter,
      sales_channel,
      customer_type,
      territory_name,
      region
  ),

  with_calculations AS (
    SELECT
      *,
      -- Participação percentual
      ROUND(online_revenue / NULLIF(total_revenue, 0) * 100, 2) AS online_revenue_pct,
      ROUND(offline_revenue / NULLIF(total_revenue, 0) * 100, 2) AS offline_revenue_pct,
      ROUND(b2c_revenue / NULLIF(total_revenue, 0) * 100, 2) AS b2c_revenue_pct,
      ROUND(b2b_revenue / NULLIF(total_revenue, 0) * 100, 2) AS b2b_revenue_pct,
      
      -- Métricas de eficiência
      ROUND(total_revenue / NULLIF(total_orders, 0), 2) AS revenue_per_order,
      ROUND(total_revenue / NULLIF(unique_customers, 0), 2) AS revenue_per_customer,
      ROUND(total_quantity_sold / NULLIF(total_orders, 0), 2) AS avg_items_per_order

    FROM sales_aggregation
  )

SELECT
  -- Dimensões
  order_year,
  order_month,
  order_quarter,
  sales_channel,
  customer_type,
  territory_name,
  region,

  -- Métricas de volume
  total_orders,
  total_line_items,
  unique_customers,
  unique_products,
  total_quantity_sold,

  -- Métricas financeiras
  total_revenue,
  avg_line_value,
  min_line_value,
  max_line_value,
  total_order_value,
  avg_order_value,

  -- Segmentação de clientes
  high_value_customers,
  medium_value_customers,
  low_value_customers,

  -- Receita por canal
  online_revenue,
  offline_revenue,
  online_revenue_pct,
  offline_revenue_pct,

  -- Receita por tipo de cliente
  b2c_revenue,
  b2b_revenue,
  b2c_revenue_pct,
  b2b_revenue_pct,

  -- Métricas de eficiência
  revenue_per_order,
  revenue_per_customer,
  avg_items_per_order

FROM with_calculations
ORDER BY order_year, order_month, territory_name
;