{{ config(materialized='table') }}

WITH
  customer_enhanced AS (
    SELECT * FROM {{ ref('int_sales__customer_enhanced') }}
  ),

  customer_dimension AS (
    SELECT 
        -- Chave primária
        CustomerID,
        
        -- Chaves estrangeiras
        PersonID,
        StoreID,
        TerritoryID,
        
        -- Atributos descritivos
        AccountNumber,
        customer_type,
        business_segment,
        account_status,
        territory_status,
        data_source,
        
        -- Metadata
        modified_date,
        
        -- Flags para análise
        CASE WHEN PersonID IS NOT NULL THEN 1 ELSE 0 END AS is_individual,
        CASE WHEN StoreID IS NOT NULL THEN 1 ELSE 0 END AS is_business,
        CASE WHEN AccountNumber IS NOT NULL THEN 1 ELSE 0 END AS has_account_number,
        CASE WHEN TerritoryID IS NOT NULL THEN 1 ELSE 0 END AS has_territory
        
    FROM customer_enhanced
  )

SELECT * FROM customer_dimension