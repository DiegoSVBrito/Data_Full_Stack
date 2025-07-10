-- Teste para validar total de vendas conhecido em 2011
-- Baseado nos dados históricos do Adventure Works

select
    sum(line_total) as total_sales_2011
from {{ ref('fact_sales_transactions') }}
where order_year = 2011
having sum(line_total) < 1000000  -- Esperamos mais de 1M em vendas em 2011