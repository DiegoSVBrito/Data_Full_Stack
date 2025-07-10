{{ config(materialized='table') }}

WITH
  enriched AS (
    SELECT * FROM {{ ref('int_sales__enriched') }}
  ),

  sales_metrics AS (
    SELECT
      -- Chaves de análise
      order_year,
      order_month,
      order_quarter,
      territory_name,
      region,
      sales_channel,
      customer_type,
      
      -- Métricas de vendas básicas
      COUNT(DISTINCT SalesOrderID) AS total_orders,
      COUNT(SalesOrderDetailID) AS total_line_items,
      COUNT(DISTINCT CustomerID) AS unique_customers,
      COUNT(DISTINCT ProductID) AS unique_products,
      SUM(order_quantity) AS total_quantity,
      
      -- Métricas financeiras
      SUM(line_total) AS total_revenue,
      AVG(line_total) AS avg_line_revenue,
      SUM(order_total_due) AS total_order_value,
      AVG(order_total_due) AS avg_order_value,
      
      -- Métricas de categorização
      COUNT(DISTINCT CASE WHEN order_revenue_category = 'High Value (10K+)' THEN SalesOrderID END) AS high_value_orders,
      COUNT(DISTINCT CASE WHEN order_revenue_category = 'Medium Value (1K-10K)' THEN SalesOrderID END) AS medium_value_orders,
      COUNT(DISTINCT CASE WHEN order_revenue_category = 'Low Value (100-1K)' THEN SalesOrderID END) AS low_value_orders,
      COUNT(DISTINCT CASE WHEN order_revenue_category = 'Micro Value (<100)' THEN SalesOrderID END) AS micro_value_orders

    FROM enriched
    GROUP BY
      order_year,
      order_month,
      order_quarter,
      territory_name,
      region,
      sales_channel,
      customer_type
  ),

  performance_calculations AS (
    SELECT
      *,
      -- Cálculos de performance
      ROUND(total_revenue / NULLIF(total_orders, 0), 2) AS revenue_per_order,
      ROUND(total_revenue / NULLIF(unique_customers, 0), 2) AS revenue_per_customer,
      ROUND(total_quantity / NULLIF(total_orders, 0), 2) AS avg_items_per_order,
      ROUND(total_orders / NULLIF(unique_customers, 0), 2) AS orders_per_customer,
      
      -- Distribuição percentual de pedidos
      ROUND(high_value_orders * 100.0 / NULLIF(total_orders, 0), 2) AS high_value_orders_pct,
      ROUND(medium_value_orders * 100.0 / NULLIF(total_orders, 0), 2) AS medium_value_orders_pct,
      ROUND(low_value_orders * 100.0 / NULLIF(total_orders, 0), 2) AS low_value_orders_pct,
      ROUND(micro_value_orders * 100.0 / NULLIF(total_orders, 0), 2) AS micro_value_orders_pct

    FROM sales_metrics
  ),

  temporal_analysis AS (
    SELECT
      *,
      -- Análise temporal (comparação com mês anterior)
      LAG(total_revenue, 1) OVER (
        PARTITION BY territory_name, region, sales_channel, customer_type 
        ORDER BY order_year, order_month
      ) AS prev_month_revenue,
      
      LAG(total_orders, 1) OVER (
        PARTITION BY territory_name, region, sales_channel, customer_type 
        ORDER BY order_year, order_month
      ) AS prev_month_orders,
      
      LAG(unique_customers, 1) OVER (
        PARTITION BY territory_name, region, sales_channel, customer_type 
        ORDER BY order_year, order_month
      ) AS prev_month_customers,
      
      -- Média móvel de 3 meses
      AVG(total_revenue) OVER (
        PARTITION BY territory_name, region, sales_channel, customer_type 
        ORDER BY order_year, order_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
      ) AS revenue_3m_avg,
      
      AVG(total_orders) OVER (
        PARTITION BY territory_name, region, sales_channel, customer_type 
        ORDER BY order_year, order_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
      ) AS orders_3m_avg

    FROM performance_calculations
  ),

  growth_analysis AS (
    SELECT
      *,
      -- Crescimento mês a mês
      CASE 
        WHEN prev_month_revenue IS NOT NULL AND prev_month_revenue > 0 
        THEN ROUND((total_revenue - prev_month_revenue) / prev_month_revenue * 100, 2)
        ELSE NULL
      END AS revenue_growth_pct,
      
      CASE 
        WHEN prev_month_orders IS NOT NULL AND prev_month_orders > 0 
        THEN ROUND((total_orders - prev_month_orders) / prev_month_orders * 100, 2)
        ELSE NULL
      END AS orders_growth_pct,
      
      CASE 
        WHEN prev_month_customers IS NOT NULL AND prev_month_customers > 0 
        THEN ROUND((unique_customers - prev_month_customers) / prev_month_customers * 100, 2)
        ELSE NULL
      END AS customers_growth_pct,
      
      -- Variação em relação à média móvel
      CASE 
        WHEN revenue_3m_avg IS NOT NULL AND revenue_3m_avg > 0 
        THEN ROUND((total_revenue - revenue_3m_avg) / revenue_3m_avg * 100, 2)
        ELSE NULL
      END AS revenue_vs_3m_avg_pct

    FROM temporal_analysis
  ),

  rankings AS (
    SELECT
      *,
      -- Rankings por período
      RANK() OVER (
        PARTITION BY order_year, order_month 
        ORDER BY total_revenue DESC
      ) AS revenue_rank_in_month,
      
      RANK() OVER (
        PARTITION BY order_year, order_quarter 
        ORDER BY total_revenue DESC
      ) AS revenue_rank_in_quarter,
      
      -- Percentis
      PERCENT_RANK() OVER (
        PARTITION BY order_year, order_month 
        ORDER BY total_revenue
      ) AS revenue_percentile_in_month,
      
      -- Participação no total
      ROUND(total_revenue / SUM(total_revenue) OVER (
        PARTITION BY order_year, order_month
      ) * 100, 2) AS revenue_share_in_month

    FROM growth_analysis
  ),

  final_classification AS (
    SELECT
      *,
      -- Classificação de performance
      CASE
        WHEN revenue_percentile_in_month >= 0.8 THEN 'Top Performer'
        WHEN revenue_percentile_in_month >= 0.6 THEN 'High Performer'
        WHEN revenue_percentile_in_month >= 0.4 THEN 'Average Performer'
        WHEN revenue_percentile_in_month >= 0.2 THEN 'Below Average'
        ELSE 'Poor Performer'
      END AS performance_category,
      
      -- Tendência de crescimento
      CASE
        WHEN revenue_growth_pct IS NULL THEN 'No Data'
        WHEN revenue_growth_pct > 10 THEN 'High Growth'
        WHEN revenue_growth_pct > 0 THEN 'Positive Growth'
        WHEN revenue_growth_pct > -10 THEN 'Slight Decline'
        ELSE 'Significant Decline'
      END AS growth_trend,
      
      -- Score de performance (0-100)
      ROUND(
        (revenue_percentile_in_month * 0.4) +
        (COALESCE(revenue_growth_pct, 0) / 100 * 0.3) +
        (PERCENT_RANK() OVER (ORDER BY orders_per_customer) * 0.2) +
        (PERCENT_RANK() OVER (ORDER BY revenue_per_customer) * 0.1)
      * 100, 2) AS performance_score

    FROM rankings
  )

SELECT
  -- Dimensões
  order_year,
  order_month,
  order_quarter,
  territory_name,
  region,
  sales_channel,
  customer_type,
  
  -- Métricas básicas
  total_orders,
  total_line_items,
  unique_customers,
  unique_products,
  total_quantity,
  
  -- Métricas financeiras
  total_revenue,
  avg_line_revenue,
  total_order_value,
  avg_order_value,
  
  -- Métricas de eficiência
  revenue_per_order,
  revenue_per_customer,
  avg_items_per_order,
  orders_per_customer,
  
  -- Distribuição de pedidos
  high_value_orders,
  medium_value_orders,
  low_value_orders,
  micro_value_orders,
  high_value_orders_pct,
  medium_value_orders_pct,
  low_value_orders_pct,
  micro_value_orders_pct,
  
  -- Análise de crescimento
  revenue_growth_pct,
  orders_growth_pct,
  customers_growth_pct,
  revenue_vs_3m_avg_pct,
  
  -- Rankings e participações
  revenue_rank_in_month,
  revenue_rank_in_quarter,
  revenue_percentile_in_month,
  revenue_share_in_month,
  
  -- Classificações
  performance_category,
  growth_trend,
  performance_score

FROM final_classification
ORDER BY order_year, order_month, total_revenue DESC
;