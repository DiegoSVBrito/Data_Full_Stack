-- Teste para validar consistência entre agregações mensais e transacionais
-- Garante que os totais batem entre fact_sales_transactions e fact_sales_monthly_agg

with
    transaction_totals as (
        select
            order_year
            , order_month
            , sales_channel
            , sum(line_total) as transaction_revenue
        from {{ ref('fact_sales_transactions') }}
        group by order_year, order_month, sales_channel
    ),
    
    monthly_totals as (
        select
            order_year
            , order_month
            , sales_channel
            , total_revenue as monthly_revenue
        from {{ ref('fact_sales_monthly_agg') }}
    ),
    
    comparison as (
        select
            t.order_year
            , t.order_month
            , t.sales_channel
            , t.transaction_revenue
            , m.monthly_revenue
            , abs(t.transaction_revenue - m.monthly_revenue) as difference
        from transaction_totals t
        inner join monthly_totals m
            on t.order_year = m.order_year
            and t.order_month = m.order_month
            and t.sales_channel = m.sales_channel
    )

select *
from comparison
where difference > 0.01  -- Tolerância de 1 centavo para arredondamentos