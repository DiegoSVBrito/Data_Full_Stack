{{ config(materialized='view') }}

WITH
  customer_staging AS (
    SELECT * FROM {{ ref('stg_sales__customer') }}
  ),

  customer_enhanced AS (
    SELECT 
        -- Campos originais
        customer_pk as CustomerID,
        person_fk as PersonID,
        store_fk as StoreID,
        territory_fk as TerritoryID,
        AccountNumber,
        modified_date,
        
        -- === CÁLCULOS DERIVADOS E REGRAS DE NEGÓCIO ===
        
        -- Customer Type
        CASE 
            WHEN person_fk IS NOT NULL AND store_fk IS NULL THEN 'Individual'
            WHEN person_fk IS NULL AND store_fk IS NOT NULL THEN 'Store/Business'
            WHEN person_fk IS NOT NULL AND store_fk IS NOT NULL THEN 'Store Contact'
            ELSE 'Unknown'
        END AS customer_type,
        
        -- Customer Classification
        CASE 
            WHEN person_fk IS NOT NULL THEN 'B2C'
            WHEN store_fk IS NOT NULL THEN 'B2B'
            ELSE 'Unknown'
        END AS business_segment,
        
        -- Account Number Analysis
        CASE 
            WHEN AccountNumber IS NOT NULL THEN 'Has Account Number'
            ELSE 'No Account Number'
        END AS account_status,
        
        -- Territory Assignment
        CASE 
            WHEN territory_fk IS NOT NULL THEN 'Assigned Territory'
            ELSE 'No Territory'
        END AS territory_status,
        
        -- Data Source
        'DW' AS data_source
        
    FROM customer_staging
  )

SELECT * FROM customer_enhanced