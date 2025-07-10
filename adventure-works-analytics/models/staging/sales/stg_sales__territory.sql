{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('adventure_works_dw', 'raw_db_sales_salesterritory') }}
),

cleaned AS (
    SELECT 
        -- Primary Keys
        TerritoryID,
        
        -- Territory Information
        Name AS territory_name,
        CountryRegionCode,
        "Group" AS territory_group,
        
        -- Financial Information
        SalesYTD,
        SalesLastYear,
        CostYTD,
        CostLastYear,
        
        -- Metadata
        CAST(ModifiedDate AS TIMESTAMP) AS modified_date,
        
        -- === DERIVED FIELDS ===
        
        -- Territory Performance
        CASE 
            WHEN SalesYTD > SalesLastYear THEN 'Growing'
            WHEN SalesYTD < SalesLastYear THEN 'Declining'
            WHEN SalesYTD = SalesLastYear THEN 'Stable'
            ELSE 'Unknown'
        END AS performance_trend,
        
        -- Territory Size
        CASE 
            WHEN SalesYTD >= 10000000 THEN 'Large Territory (10M+)'
            WHEN SalesYTD >= 5000000 THEN 'Medium Territory (5M-10M)'
            WHEN SalesYTD >= 1000000 THEN 'Small Territory (1M-5M)'
            ELSE 'Micro Territory (<1M)'
        END AS territory_size,
        
        -- Regional Classification
        CASE 
            WHEN CountryRegionCode IN ('US', 'CA') THEN 'North America'
            WHEN CountryRegionCode IN ('GB', 'FR', 'DE') THEN 'Europe'
            WHEN CountryRegionCode IN ('AU', 'JP') THEN 'Asia Pacific'
            ELSE 'Other'
        END AS region,
        
        -- Growth Calculation
        CASE 
            WHEN SalesLastYear > 0 
            THEN ROUND(((SalesYTD - SalesLastYear) / SalesLastYear) * 100, 2)
            ELSE NULL
        END AS growth_percentage,
        
        -- Profitability
        CASE 
            WHEN CostYTD > 0 AND SalesYTD > 0
            THEN ROUND(((SalesYTD - CostYTD) / SalesYTD) * 100, 2)
            ELSE NULL
        END AS profit_margin_percentage,
        
        -- Data Source
        'DW' AS data_source
        
    FROM source
    WHERE TerritoryID IS NOT NULL
)

SELECT * FROM cleaned
