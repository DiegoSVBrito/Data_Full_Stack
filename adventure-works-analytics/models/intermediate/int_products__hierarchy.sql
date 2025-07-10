{{ config(materialized='view') }}

WITH products AS (
    SELECT * FROM {{ ref('stg_products__product') }}
),

categories AS (
    SELECT * FROM {{ ref('stg_products__category') }}
),

products_hierarchy AS (
    SELECT 
        p.ProductID,
        p.product_name,
        p.ProductNumber,
        p.Color,
        p.Size,
        p.StandardCost,
        p.ListPrice,
        p.product_status,
        p.product_type,
        p.price_category,
        p.gross_margin_percentage,
        p.gross_margin_amount,
        
        -- Category (simplified - using category directly)
        c.category_name,
        c.category_type,
        c.business_priority,
        
        -- Enhanced classifications
        CASE 
            WHEN p.gross_margin_percentage >= 50 THEN 'High Margin (50%+)'
            WHEN p.gross_margin_percentage >= 30 THEN 'Medium Margin (30-50%)'
            WHEN p.gross_margin_percentage >= 10 THEN 'Low Margin (10-30%)'
            WHEN p.gross_margin_percentage > 0 THEN 'Minimal Margin (0-10%)'
            ELSE 'No Margin Data'
        END AS margin_tier,
        
        CASE 
            WHEN p.product_status = 'Active' AND p.ListPrice > 0 THEN 'Available'
            WHEN p.product_status = 'Active' AND p.ListPrice = 0 THEN 'Active - No Price'
            ELSE 'Discontinued'
        END AS availability_status
        
    FROM products p
    LEFT JOIN categories c ON p.ProductSubcategoryID IS NOT NULL -- Simplified
)

SELECT * FROM products_hierarchy
