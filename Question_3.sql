WITH price_data AS (
    select
        year(date_from) AS price_year,
        name AS category_name,
        AVG(price) AS avg_price
    FROM
        t_barbora_kalincova_project_sql_primary_final
    WHERE
        name IS NOT null
    GROUP BY
        price_year, category_name
),
yoy_changes AS (
    SELECT
        price_year,
        category_name,
        avg_price,
        LAG(avg_price) OVER (PARTITION BY category_name ORDER BY price_year) AS prev_year_price,
        (avg_price - LAG(avg_price) OVER (PARTITION BY category_name ORDER BY price_year)) / LAG(avg_price) OVER (PARTITION BY category_name ORDER BY price_year) * 100 AS yoy_percent_change
    FROM
        price_data
),
avg_yoy_changes AS (
    SELECT
        category_name,
        AVG(yoy_percent_change) AS avg_yoy_percent_change
    FROM
        yoy_changes
    WHERE
        prev_year_price IS NOT NULL
    GROUP BY
        category_name
)
SELECT
    category_name,
    MIN(avg_yoy_percent_change) AS slowest_increase
FROM
    avg_yoy_changes;
