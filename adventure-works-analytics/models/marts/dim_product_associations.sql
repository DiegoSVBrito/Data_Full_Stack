{{ config(materialized='table') }}

WITH order_products AS (
    SELECT 
        SalesOrderID AS sales_order_number,
        ProductID AS product_key,
        order_quantity AS quantity
    FROM {{ ref('fact_sales_transactions') }}
    WHERE order_date >= ADD_MONTHS(CURRENT_DATE(), -12)
),

product_pairs AS (
    SELECT 
        op1.product_key AS product_a_key,
        op2.product_key AS product_b_key,
        COUNT(DISTINCT op1.sales_order_number) AS co_occurrence_count,
        COUNT(DISTINCT op1.sales_order_number) * 1.0 / 
            (SELECT COUNT(DISTINCT sales_order_number) FROM order_products) AS support
    FROM order_products op1
    JOIN order_products op2 
        ON op1.sales_order_number = op2.sales_order_number 
        AND op1.product_key < op2.product_key
    GROUP BY op1.product_key, op2.product_key
    HAVING COUNT(DISTINCT op1.sales_order_number) >= 5
),

association_metrics AS (
    SELECT 
        pp.*,
        pa_count.total_orders_a,
        pb_count.total_orders_b,
        pp.co_occurrence_count * 1.0 / pa_count.total_orders_a AS confidence_a_to_b,
        pp.co_occurrence_count * 1.0 / pb_count.total_orders_b AS confidence_b_to_a,
        
        -- Lift calculation
        (pp.co_occurrence_count * 1.0 / (pa_count.total_orders_a * pb_count.total_orders_b)) * 
        (SELECT COUNT(DISTINCT sales_order_number) FROM order_products) AS lift
    FROM product_pairs pp
    LEFT JOIN (
        SELECT product_key, COUNT(DISTINCT sales_order_number) AS total_orders_a
        FROM order_products GROUP BY product_key
    ) pa_count ON pp.product_a_key = pa_count.product_key
    LEFT JOIN (
        SELECT product_key, COUNT(DISTINCT sales_order_number) AS total_orders_b  
        FROM order_products GROUP BY product_key
    ) pb_count ON pp.product_b_key = pb_count.product_key
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY lift DESC) AS association_key,
    am.product_a_key,
    dp1.product_name AS product_a_name,
    dp1.category_name AS product_a_category,
    am.product_b_key,
    dp2.product_name AS product_b_name,
    dp2.category_name AS product_b_category,
    am.co_occurrence_count,
    am.support,
    am.confidence_a_to_b,
    am.confidence_b_to_a,
    am.lift,
    CASE 
        WHEN am.lift >= 2.0 THEN 'Strong Association'
        WHEN am.lift >= 1.5 THEN 'Moderate Association'
        WHEN am.lift >= 1.1 THEN 'Weak Association'
        ELSE 'No Association'
    END AS association_strength,
    CURRENT_DATE() AS updated_at
FROM association_metrics am
LEFT JOIN {{ ref('dim_product') }} dp1 ON am.product_a_key = dp1.ProductID
LEFT JOIN {{ ref('dim_product') }} dp2 ON am.product_b_key = dp2.ProductID
WHERE am.lift > 1.0
ORDER BY am.lift DESC