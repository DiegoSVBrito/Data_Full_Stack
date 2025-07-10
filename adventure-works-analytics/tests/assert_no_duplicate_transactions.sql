-- Teste para garantir que não há duplicatas em transações
-- Valida unicidade do SalesOrderDetailID

select
    sales_order_detail_id
    , count(*) as duplicate_count
from {{ ref('fact_sales_transactions') }}
group by sales_order_detail_id
having count(*) > 1