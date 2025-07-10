{{ config(materialized='view') }}

WITH
  header AS (
    SELECT * FROM {{ ref('int_sales__order_header_enhanced') }}
  ),

  detail AS (
    SELECT * FROM {{ ref('stg_sales__order_detail_dw') }}
  ),

  cust AS (
    SELECT * FROM {{ ref('int_sales__customer_enhanced') }}
  ),

  territory AS (
    SELECT * FROM {{ ref('stg_sales__territory') }}
  ),

  prod AS (
    SELECT * FROM {{ ref('stg_products__product') }}
  )

SELECT
  -- IDs principais
  h.SalesOrderID,
  d.SalesOrderDetailID,
  h.CustomerID,
  d.ProductID,
  h.SalesPersonID,
  h.TerritoryID,

  -- Datas
  h.order_date,
  h.order_year,
  h.order_month,
  h.order_quarter,

  -- Categorias e flags
  h.sales_channel,
  h.revenue_category   AS order_revenue_category,
  d.line_revenue_category,
  d.quantity_category,

  -- Valores
  d.OrderQty           AS order_quantity,
  d.LineTotal          AS line_total,
  h.TotalDue           AS order_total_due,

  -- Atributos de cliente e território
  c.customer_type,
  t.territory_name,
  t.region,

  -- Atributos de produto
  p.product_name,
  p.ProductSubcategoryID

FROM header AS h
JOIN detail AS d
  ON h.SalesOrderID = d.SalesOrderID
LEFT JOIN cust    AS c ON h.CustomerID      = c.CustomerID
LEFT JOIN territory AS t ON h.TerritoryID    = t.TerritoryID
LEFT JOIN prod   AS p ON d.ProductID       = p.ProductID
;