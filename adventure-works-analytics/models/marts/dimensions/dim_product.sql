{{ config(materialized='table') }}

WITH
  product_staging AS (
    SELECT * FROM {{ ref('stg_products__product') }}
  ),

  category_staging AS (
    SELECT * FROM {{ ref('stg_products__category') }}
  ),

  product_dimension AS (
    SELECT 
        -- Chave primária
        p.ProductID,
        
        -- Chaves estrangeiras
        p.ProductSubcategoryID,
        p.ProductModelID,
        
        -- Atributos descritivos do produto
        p.product_name,
        p.ProductNumber,
        p.Color,
        p.Size,
        p.SizeUnitMeasureCode,
        p.Weight,
        p.WeightUnitMeasureCode,
        
        -- Atributos financeiros
        p.StandardCost,
        p.ListPrice,
        
        -- Flags
        p.MakeFlag,
        p.FinishedGoodsFlag,
        
        -- Datas
        p.sell_start_date,
        p.sell_end_date,
        p.discontinued_date,
        
        -- Atributos derivados
        p.product_status,
        p.price_category,
        p.gross_margin_percentage,
        p.gross_margin_amount,
        p.product_type,
        p.product_category_type,
        
        -- Hierarquia de categorias (se disponível)
        c.category_name,
        
        -- Flags para análise
        CASE WHEN p.MakeFlag = true THEN 1 ELSE 0 END AS is_manufactured,
        CASE WHEN p.FinishedGoodsFlag = true THEN 1 ELSE 0 END AS is_finished_goods,
        CASE WHEN p.sell_end_date IS NULL THEN 1 ELSE 0 END AS is_active,
        CASE WHEN p.StandardCost > 0 THEN 1 ELSE 0 END AS has_standard_cost,
        CASE WHEN p.ListPrice > 0 THEN 1 ELSE 0 END AS has_list_price
        
    FROM product_staging p
    LEFT JOIN category_staging c ON p.ProductSubcategoryID = c.ProductCategoryID
  )

SELECT * FROM product_dimension