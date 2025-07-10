-- Test to ensure that order dates are not in the future
-- Future order dates would indicate data quality issues

SELECT
    SalesOrderID,
    order_date,
    CURRENT_DATE() AS current_date
FROM {{ ref('fact_sales_transactions') }}
WHERE order_date > CURRENT_DATE()