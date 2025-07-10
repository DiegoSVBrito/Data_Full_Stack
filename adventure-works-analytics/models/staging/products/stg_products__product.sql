{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('adventure_works_dw', 'raw_db_production_product') }}
),

cleaned AS (
    SELECT 
        -- Primary Keys
        ProductID,
        
        -- Foreign Keys
        ProductSubcategoryID,
        ProductModelID,
        
        -- Product Information
        Name AS product_name,
        ProductNumber,
        Color,
        Size,
        SizeUnitMeasureCode,
        Weight,
        WeightUnitMeasureCode,
        
        -- Financial Information
        StandardCost,
        ListPrice,
        
        -- Product Flags
        MakeFlag,
        FinishedGoodsFlag,
        
        -- Dates
        CAST(SellStartDate AS DATE) AS sell_start_date,
        CAST(SellEndDate AS DATE) AS sell_end_date,
        CAST(DiscontinuedDate AS DATE) AS discontinued_date,
        CAST(ModifiedDate AS TIMESTAMP) AS modified_date,
        
        -- === DERIVED FIELDS ===
        
        -- Product Status
        CASE 
            WHEN SellEndDate IS NULL AND DiscontinuedDate IS NULL THEN 'Active'
            WHEN SellEndDate IS NOT NULL THEN 'Discontinued - End of Sales'
            WHEN DiscontinuedDate IS NOT NULL THEN 'Discontinued'
            ELSE 'Unknown'
        END AS product_status,
        
        -- Price Analysis
        CASE 
            WHEN ListPrice = 0 THEN 'No List Price'
            WHEN ListPrice >= 1000 THEN 'Premium (1000+)'
            WHEN ListPrice >= 100 THEN 'Mid-Range (100-1000)'
            WHEN ListPrice >= 10 THEN 'Budget (10-100)'
            ELSE 'Low Cost (<10)'
        END AS price_category,
        
        -- Margin Analysis
        CASE 
            WHEN StandardCost > 0 AND ListPrice > 0 
            THEN ROUND(((ListPrice - StandardCost) / ListPrice) * 100, 2)
            ELSE NULL
        END AS gross_margin_percentage,
        
        CASE 
            WHEN StandardCost > 0 AND ListPrice > 0 
            THEN ListPrice - StandardCost
            ELSE NULL
        END AS gross_margin_amount,
        
        -- Product Type
        CASE 
            WHEN MakeFlag = true THEN 'Manufactured'
            ELSE 'Purchased'
        END AS product_type,
        
        CASE 
            WHEN FinishedGoodsFlag = true THEN 'Finished Goods'
            ELSE 'Component/Raw Material'
        END AS product_category_type,
        
        -- Physical Attributes
        CASE 
            WHEN Color IS NOT NULL THEN 'Colored'
            ELSE 'No Color'
        END AS color_status,
        
        CASE 
            WHEN Size IS NOT NULL THEN 'Sized'
            ELSE 'No Size'
        END AS size_status,
        
        CASE 
            WHEN Weight IS NOT NULL THEN 'Weighted'
            ELSE 'No Weight'
        END AS weight_status,
        
        -- Data Source
        'DW' AS data_source
        
    FROM source
    WHERE ProductID IS NOT NULL
)

SELECT * FROM cleaned
