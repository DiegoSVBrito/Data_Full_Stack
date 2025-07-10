{{ config(materialized='table') }}

WITH
  enriched AS (
    SELECT * FROM {{ ref('int_sales__enriched') }}
  )

SELECT
  -- IDs principais
  SalesOrderID,
  SalesOrderDetailID,
  CustomerID,
  ProductID,
  SalesPersonID,
  TerritoryID,

  -- Datas
  order_date,
  order_year,
  order_month,
  order_quarter,

  -- Categorias e flags
  sales_channel,
  order_revenue_category,
  line_revenue_category,
  quantity_category,

  -- Valores
  order_quantity,
  line_total,
  order_total_due,

  -- Atributos de cliente e território
  customer_type,
  territory_name,
  region,

  -- Atributos de produto
  product_name,
  ProductSubcategoryID

FROM enriched
;