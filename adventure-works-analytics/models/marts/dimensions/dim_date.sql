{{ config(materialized='table') }}

WITH
  date_spine AS (
    SELECT 
        date_day,
        YEAR(date_day) AS year,
        MONTH(date_day) AS month,
        DAY(date_day) AS day,
        QUARTER(date_day) AS quarter,
        DAYOFWEEK(date_day) AS day_of_week,
        DAYOFYEAR(date_day) AS day_of_year,
        WEEKOFYEAR(date_day) AS week_of_year
    FROM (
        SELECT 
            DATE_ADD(DATE('2000-01-01'), sequence.seq) AS date_day
        FROM (
            SELECT 
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS seq
            FROM {{ ref('stg_sales__order_header_dw') }}
            CROSS JOIN {{ ref('stg_sales__order_detail_dw') }}
            LIMIT 10000
        ) AS sequence
        WHERE DATE_ADD(DATE('2000-01-01'), sequence.seq) <= DATE('2030-12-31')
    ) AS dates
  ),

  date_dimension AS (
    SELECT 
        -- Chave primária
        date_day,
        
        -- Componentes de data
        year,
        month,
        day,
        quarter,
        day_of_week,
        day_of_year,
        week_of_year,
        
        -- Atributos descritivos
        CONCAT(year, '-', LPAD(month, 2, '0')) AS year_month,
        CONCAT(year, '-Q', quarter) AS year_quarter,
        CASE day_of_week
            WHEN 1 THEN 'Sunday'
            WHEN 2 THEN 'Monday'
            WHEN 3 THEN 'Tuesday'
            WHEN 4 THEN 'Wednesday'
            WHEN 5 THEN 'Thursday'
            WHEN 6 THEN 'Friday'
            WHEN 7 THEN 'Saturday'
        END AS day_name,
        CASE month
            WHEN 1 THEN 'January'
            WHEN 2 THEN 'February'
            WHEN 3 THEN 'March'
            WHEN 4 THEN 'April'
            WHEN 5 THEN 'May'
            WHEN 6 THEN 'June'
            WHEN 7 THEN 'July'
            WHEN 8 THEN 'August'
            WHEN 9 THEN 'September'
            WHEN 10 THEN 'October'
            WHEN 11 THEN 'November'
            WHEN 12 THEN 'December'
        END AS month_name,
        
        -- Flags para análise
        CASE WHEN day_of_week IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
        CASE WHEN day_of_week IN (2, 3, 4, 5, 6) THEN 1 ELSE 0 END AS is_weekday,
        CASE WHEN month IN (12, 1, 2) THEN 1 ELSE 0 END AS is_winter,
        CASE WHEN month IN (3, 4, 5) THEN 1 ELSE 0 END AS is_spring,
        CASE WHEN month IN (6, 7, 8) THEN 1 ELSE 0 END AS is_summer,
        CASE WHEN month IN (9, 10, 11) THEN 1 ELSE 0 END AS is_fall,
        CASE WHEN day <= 15 THEN 1 ELSE 0 END AS is_first_half_month,
        CASE WHEN day > 15 THEN 1 ELSE 0 END AS is_second_half_month
        
    FROM date_spine
  )

SELECT * FROM date_dimension