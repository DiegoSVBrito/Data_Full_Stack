-- Test to ensure that all line totals are positive
-- Negative line totals would indicate data quality issues

SELECT
    SalesOrderID,
    SalesOrderDetailID,
    line_total
FROM {{ ref('fact_sales_transactions') }}
WHERE line_total < 0