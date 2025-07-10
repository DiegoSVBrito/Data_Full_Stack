-- Verificar se todos os CLVs são positivos
SELECT *
FROM {{ ref('dim_customers_enhanced') }}
WHERE lifetime_revenue < 0