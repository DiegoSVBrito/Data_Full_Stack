{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('adventure_works_dw', 'raw_db_production_productcategory') }}
),

cleaned AS (
    SELECT 
        -- Primary Keys
        ProductCategoryID,
        
        -- Category Information
        Name AS category_name,
        
        -- Metadata
        CAST(ModifiedDate AS TIMESTAMP) AS modified_date,
        
        -- === DERIVED FIELDS ===
        
        -- Category Classification
        CASE 
            WHEN UPPER(Name) LIKE '%BIKE%' THEN 'Bikes'
            WHEN UPPER(Name) LIKE '%COMPONENT%' THEN 'Components'
            WHEN UPPER(Name) LIKE '%CLOTHING%' THEN 'Clothing'
            WHEN UPPER(Name) LIKE '%ACCESSORY%' OR UPPER(Name) LIKE '%ACCESSORIES%' THEN 'Accessories'
            ELSE 'Other'
        END AS category_type,
        
        -- Business Priority
        CASE 
            WHEN UPPER(Name) LIKE '%BIKE%' THEN 'High Priority'
            WHEN UPPER(Name) LIKE '%COMPONENT%' THEN 'Medium Priority'
            ELSE 'Standard Priority'
        END AS business_priority,
        
        -- Data Source
        'DW' AS data_source
        
    FROM source
    WHERE ProductCategoryID IS NOT NULL
      AND Name IS NOT NULL
)

SELECT * FROM cleaned
