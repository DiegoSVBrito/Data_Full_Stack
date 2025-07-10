{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('adventure_works_dw', 'raw_db_sales_salesorderheader') }}
),

cleaned AS (
    SELECT 
        -- Primary Keys
        SalesOrderID,
        
        -- Foreign Keys
        CustomerID,
        SalesPersonID,
        TerritoryID,
        
        -- Dates - Conversão de tipos
        CAST(OrderDate AS DATE) AS order_date,
        CAST(DueDate AS DATE) AS due_date,
        CAST(ShipDate AS DATE) AS ship_date,
        
        -- Order Information - Padronização de colunas
        SalesOrderNumber,
        Status,
        OnlineOrderFlag,
        
        -- Financial Information
        SubTotal,
        TaxAmt,
        Freight,
        TotalDue,
        
        -- Metadata
        CAST(ModifiedDate AS TIMESTAMP) AS modified_date
        
    FROM source
    WHERE SalesOrderID IS NOT NULL  -- Remoção de nulos
      AND OrderDate IS NOT NULL     -- Remoção de nulos
)

SELECT * FROM cleaned