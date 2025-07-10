{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('adventure_works_dw', 'raw_db_sales_customer') }}
),

cleaned AS (
    SELECT 
        -- Primary Keys
        CustomerID as customer_pk,
        
        -- Foreign Keys
        PersonID as person_fk,
        StoreID as store_fk,
        TerritoryID as territory_fk,
        
        -- Customer Information
        AccountNumber,
        
        -- Metadata
        CAST(ModifiedDate AS TIMESTAMP) AS modified_date
        
    FROM source
    WHERE CustomerID IS NOT NULL  -- Remoção de nulos
)

SELECT * FROM cleaned