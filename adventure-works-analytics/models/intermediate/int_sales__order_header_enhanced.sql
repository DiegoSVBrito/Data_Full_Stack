{{ config(materialized='view') }}

WITH
  order_header_staging AS (
    SELECT * FROM {{ ref('stg_sales__order_header_dw') }}
  ),

  order_header_enhanced AS (
    SELECT 
        -- Campos originais
        SalesOrderID,
        CustomerID,
        SalesPersonID,
        TerritoryID,
        order_date,
        due_date,
        ship_date,
        SalesOrderNumber,
        Status,
        OnlineOrderFlag,
        SubTotal,
        TaxAmt,
        Freight,
        TotalDue,
        modified_date,
        
        -- === CÁLCULOS DERIVADOS E REGRAS DE NEGÓCIO ===
        
        -- Time Dimensions
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        QUARTER(order_date) AS order_quarter,
        DATE_FORMAT(order_date, 'yyyy-MM') AS order_year_month,
        DAYOFWEEK(order_date) AS order_day_of_week,
        
        -- Status Description
        CASE 
            WHEN Status = 1 THEN 'In Process'
            WHEN Status = 2 THEN 'Approved'
            WHEN Status = 3 THEN 'Backordered'
            WHEN Status = 4 THEN 'Rejected'
            WHEN Status = 5 THEN 'Shipped'
            WHEN Status = 6 THEN 'Cancelled'
            ELSE 'Unknown'
        END AS status_description,
        
        -- Sales Channel
        CASE 
            WHEN OnlineOrderFlag = true THEN 'Online'
            ELSE 'Offline'
        END AS sales_channel,
        
        -- Order Completion
        CASE 
            WHEN Status IN (5, 6) THEN true
            ELSE false
        END AS is_order_completed,
        
        -- Business Metrics
        CASE 
            WHEN ship_date IS NOT NULL AND order_date IS NOT NULL 
            THEN DATEDIFF(ship_date, order_date)
            ELSE NULL
        END AS days_to_ship,
        
        CASE 
            WHEN ship_date IS NOT NULL AND due_date IS NOT NULL 
            THEN ship_date <= due_date
            ELSE NULL
        END AS is_on_time_delivery,
        
        -- Revenue Categories
        CASE 
            WHEN TotalDue >= 10000 THEN 'High Value (10K+)'
            WHEN TotalDue >= 1000 THEN 'Medium Value (1K-10K)'
            WHEN TotalDue >= 100 THEN 'Low Value (100-1K)'
            ELSE 'Micro Value (<100)'
        END AS revenue_category,
        
        -- Data Source
        'DW' AS data_source
        
    FROM order_header_staging
  )

SELECT * FROM order_header_enhanced