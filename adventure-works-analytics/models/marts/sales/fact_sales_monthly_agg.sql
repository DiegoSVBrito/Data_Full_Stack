{{ config(materialized='table') }}

WITH
  enriched AS (
    SELECT * FROM {{ ref('int_sales__enriched') }}
  ),

  monthly_agg AS (
    SELECT
      -- Dimensões de agrupamento
      order_year,
      order_month,
      customer_type,
      territory_name,
      region,
      sales_channel,
      order_revenue_category,

      -- Métricas agregadas
      COUNT(DISTINCT SalesOrderID) AS total_orders,
      COUNT(SalesOrderDetailID)    AS total_line_items,
      COUNT(DISTINCT CustomerID)   AS unique_customers,
      COUNT(DISTINCT ProductID)    AS unique_products,

      -- Valores financeiros
      SUM(line_total)              AS total_revenue,
      AVG(line_total)              AS avg_line_value,
      SUM(order_total_due)         AS total_order_value,
      AVG(order_total_due)         AS avg_order_value

    FROM enriched
    GROUP BY
      order_year,
      order_month,
      customer_type,
      territory_name,
      region,
      sales_channel,
      order_revenue_category
  )

SELECT
  -- Dimensões
  order_year,
  order_month,
  customer_type,
  territory_name,
  region,
  sales_channel,
  order_revenue_category,

  -- Métricas
  total_orders,
  total_line_items,
  unique_customers,
  unique_products,
  total_revenue,
  avg_line_value,
  total_order_value,
  avg_order_value

FROM monthly_agg
ORDER BY order_year, order_month, territory_name
;