{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('adventure_works_dw', 'raw_db_sales_salesorderdetail') }}
),

cleaned AS (
    SELECT 
        -- Primary Keys
        SalesOrderDetailID,
        
        -- Foreign Keys
        SalesOrderID,
        ProductID,
        
        -- Quantities and Pricing
        OrderQty,
        UnitPrice,
        UnitPriceDiscount,
        LineTotal,
        
        -- Metadata
        CAST(ModifiedDate AS TIMESTAMP) AS modified_date,
        
        -- === DERIVED FIELDS ===
        
        -- Price Analysis
        ROUND(UnitPrice * (1 - UnitPriceDiscount), 4) AS effective_unit_price,
        ROUND(UnitPrice * UnitPriceDiscount, 4) AS discount_amount,
        ROUND(UnitPriceDiscount * 100, 2) AS discount_percentage,
        
        -- Volume Analysis  
        CASE 
            WHEN OrderQty >= 50 THEN 'High Volume (50+)'
            WHEN OrderQty >= 10 THEN 'Medium Volume (10-50)'
            WHEN OrderQty >= 5 THEN 'Low Volume (5-10)'
            ELSE 'Unit Sales (1-4)'
        END AS quantity_category,
        
        -- Revenue Analysis
        CASE 
            WHEN LineTotal >= 5000 THEN 'High Revenue (5K+)'
            WHEN LineTotal >= 1000 THEN 'Medium Revenue (1K-5K)'
            WHEN LineTotal >= 100 THEN 'Low Revenue (100-1K)'
            ELSE 'Micro Revenue (<100)'
        END AS line_revenue_category,
        
        -- Data Quality Checks
        CASE 
            WHEN ABS(LineTotal - (OrderQty * UnitPrice * (1 - UnitPriceDiscount))) <= 0.01 
            THEN true
            ELSE false
        END AS is_line_total_accurate,
        
        -- Discount Analysis
        CASE 
            WHEN UnitPriceDiscount > 0 THEN 'Discounted'
            ELSE 'Full Price'
        END AS discount_status,
        
        CASE 
            WHEN UnitPriceDiscount >= 0.3 THEN 'High Discount (30%+)'
            WHEN UnitPriceDiscount >= 0.1 THEN 'Medium Discount (10-30%)'
            WHEN UnitPriceDiscount > 0 THEN 'Low Discount (0-10%)'
            ELSE 'No Discount'
        END AS discount_tier,
        
        -- Data Source
        'DW' AS data_source
        
    FROM source
    WHERE SalesOrderDetailID IS NOT NULL
      AND SalesOrderID IS NOT NULL
      AND ProductID IS NOT NULL
      AND OrderQty > 0
      AND UnitPrice > 0
)

SELECT * FROM cleaned
