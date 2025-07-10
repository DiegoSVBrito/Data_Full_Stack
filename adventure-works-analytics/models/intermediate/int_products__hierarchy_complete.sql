{{ config(materialized='view') }}

WITH products AS (
    SELECT * FROM {{ ref('stg_products__product') }}
),

categories AS (
    SELECT * FROM {{ ref('stg_products__category') }}
),

-- Note: We'll add subcategories when we create that staging model
products_with_hierarchy AS (
    SELECT 
        p.*,
        -- For now, we'll join categories directly
        -- Later we can add subcategory hierarchy
        c.category_name,
        c.category_type,
        c.business_priority,
        
        -- Enhanced product metrics
        CASE 
            WHEN p.ListPrice > 0 AND p.StandardCost > 0 
            THEN 'Has Complete Pricing'
            WHEN p.ListPrice > 0 
            THEN 'Has List Price Only'
            WHEN p.StandardCost > 0 
            THEN 'Has Cost Only'
            ELSE 'No Pricing Data'
        END AS pricing_completeness,
        
        -- Product value classification
        CASE 
            WHEN p.gross_margin_percentage >= 50 THEN 'High Margin (50%+)'
            WHEN p.gross_margin_percentage >= 30 THEN 'Medium Margin (30-50%)'
            WHEN p.gross_margin_percentage >= 10 THEN 'Low Margin (10-30%)'
            WHEN p.gross_margin_percentage > 0 THEN 'Minimal Margin (0-10%)'
            ELSE 'No Margin Data'
        END AS margin_category
        
    FROM products p
    LEFT JOIN categories c 
        ON p.ProductSubcategoryID IS NOT NULL -- Placeholder for proper hierarchy
)

SELECT * FROM products_with_hierarchy
