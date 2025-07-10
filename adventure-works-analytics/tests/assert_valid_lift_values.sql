-- Verificar se valores de lift são válidos (>1.0)
SELECT *
FROM {{ ref('dim_product_associations') }}
WHERE lift <= 1.0