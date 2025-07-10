{{
    config(
        materialized='table'
    )
}}

with
    enriched as (
        select * from {{ ref('int_sales__enriched') }}
    ),

    product_sales as (
        select
            ProductID
            , product_name
            , ProductSubcategoryID
            
            -- Métricas de vendas
            , sum(line_total) as total_revenue
            , sum(order_quantity) as total_quantity_sold
            , count(distinct SalesOrderID) as total_orders
            , count(SalesOrderDetailID) as total_line_items
            , count(distinct CustomerID) as unique_customers
            , count(distinct territory_name) as territories_sold
            
            -- Métricas financeiras
            , avg(line_total) as avg_line_value
            , min(line_total) as min_line_value
            , max(line_total) as max_line_value
            , avg(order_quantity) as avg_quantity_per_order
            
            -- Métricas temporais
            , min(order_date) as first_sale_date
            , max(order_date) as last_sale_date
            , count(distinct order_year) as years_active
            , count(distinct order_month) as months_active

        from enriched
        group by ProductID, product_name, ProductSubcategoryID
    ),

    revenue_rankings as (
        select
            *
            -- Ranking por receita
            , rank() over (order by total_revenue desc) as revenue_rank
            , percent_rank() over (order by total_revenue desc) as revenue_percentile
            
            -- Cálculo de participação acumulada
            , sum(total_revenue) over (order by total_revenue desc) as cumulative_revenue
            , sum(total_revenue) over () as total_market_revenue
            
            -- Participação percentual
            , round(total_revenue / sum(total_revenue) over () * 100, 2) as revenue_share_pct

        from product_sales
    ),

  abc_classification AS (
    SELECT
      *,
      -- Cálculo da participação acumulada percentual
      ROUND(cumulative_revenue / total_market_revenue * 100, 2) AS cumulative_revenue_pct,
      
      -- Classificação ABC baseada na regra 80-20
      CASE
        WHEN ROUND(cumulative_revenue / total_market_revenue * 100, 2) <= 80 THEN 'A'
        WHEN ROUND(cumulative_revenue / total_market_revenue * 100, 2) <= 95 THEN 'B'
        ELSE 'C'
      END AS abc_category,
      
      -- Classificação por volume
      CASE
        WHEN total_quantity_sold >= PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_quantity_sold) OVER () THEN 'High Volume'
        WHEN total_quantity_sold >= PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_quantity_sold) OVER () THEN 'Medium Volume'
        ELSE 'Low Volume'
      END AS volume_category,
      
      -- Classificação por frequência
      CASE
        WHEN total_orders >= PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_orders) OVER () THEN 'High Frequency'
        WHEN total_orders >= PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_orders) OVER () THEN 'Medium Frequency'
        ELSE 'Low Frequency'
      END AS frequency_category

    FROM revenue_rankings
  ),

  final_analysis AS (
    SELECT
      *,
      -- Análise de performance
      CASE
        WHEN abc_category = 'A' AND volume_category = 'High Volume' THEN 'Star Product'
        WHEN abc_category = 'A' AND volume_category = 'Low Volume' THEN 'Cash Cow'
        WHEN abc_category = 'C' AND volume_category = 'High Volume' THEN 'Problem Child'
        WHEN abc_category = 'C' AND volume_category = 'Low Volume' THEN 'Dog'
        ELSE 'Regular Product'
      END AS product_strategy,
      
      -- Cálculo de dias desde última venda
      DATEDIFF(CURRENT_DATE(), last_sale_date) AS days_since_last_sale,
      
      -- Status do produto
      CASE
        WHEN DATEDIFF(CURRENT_DATE(), last_sale_date) <= 30 THEN 'Active'
        WHEN DATEDIFF(CURRENT_DATE(), last_sale_date) <= 90 THEN 'Slow Moving'
        WHEN DATEDIFF(CURRENT_DATE(), last_sale_date) <= 365 THEN 'Dormant'
        ELSE 'Inactive'
      END AS product_status,
      
      -- Pontuação de importância (0-100)
      ROUND(
        (revenue_percentile * 0.4) +
        (PERCENT_RANK() OVER (ORDER BY total_quantity_sold DESC) * 0.3) +
        (PERCENT_RANK() OVER (ORDER BY total_orders DESC) * 0.2) +
        (PERCENT_RANK() OVER (ORDER BY unique_customers DESC) * 0.1)
      * 100, 2) AS importance_score

    FROM abc_classification
  )

select
    -- Identificação do produto
    ProductID
    , product_name
    , ProductSubcategoryID
    
    -- Métricas de vendas
    , total_revenue
    , total_quantity_sold
    , total_orders
    , total_line_items
    , unique_customers
    , territories_sold
    
    -- Métricas financeiras
    , avg_line_value
    , min_line_value
    , max_line_value
    , avg_quantity_per_order
    
    -- Métricas temporais
    , first_sale_date
    , last_sale_date
    , years_active
    , months_active
    , days_since_last_sale
    
    -- Rankings e participações
    , revenue_rank
    , revenue_percentile
    , revenue_share_pct
    , cumulative_revenue_pct
    
    -- Classificações
    , abc_category
    , volume_category
    , frequency_category
    , product_strategy
    , product_status
    , importance_score

from final_analysis
order by revenue_rank
;