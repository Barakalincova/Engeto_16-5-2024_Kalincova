WITH price_data AS (
    SELECT
        EXTRACT(YEAR FROM date_from) AS price_year,
        AVG(price) AS avg_price
    FROM
        t_barbora_kalincova_project_sql_primary_final
    WHERE
        price IS NOT NULL
    GROUP BY
        price_year
),
yoy_price_changes AS (
    SELECT
        price_year,
        overall_avg_price,
        prev_year_avg_price,
        CASE 
            WHEN prev_year_avg_price IS NULL THEN NULL
            ELSE (overall_avg_price - prev_year_avg_price) / prev_year_avg_price * 100
        END AS yoy_price_percent_change
    FROM (
        SELECT
            price_year,
            AVG(avg_price) AS overall_avg_price,
            LAG(AVG(avg_price)) OVER (ORDER BY price_year) AS prev_year_avg_price
        FROM
            price_data
        GROUP BY
            price_year
    ) as sub
    WHERE
        prev_year_avg_price IS NOT NULL
),
salary_data AS (
    SELECT
        payroll_year,
        AVG(value) AS avg_salary
    FROM
        t_barbora_kalincova_project_sql_primary_final
    WHERE
        VALUE_TYPE_NAME = 'Průměrná hrubá mzda na zaměstnance'
    GROUP BY
        payroll_year
),
yoy_salary_changes AS (
    SELECT
        payroll_year,
        avg_salary,
        prev_year_avg_salary,
        CASE 
            WHEN prev_year_avg_salary IS NULL THEN NULL
            ELSE (avg_salary - prev_year_avg_salary) / prev_year_avg_salary * 100
        END AS yoy_salary_percent_change
    FROM (
        SELECT
            payroll_year,
            avg_salary,
            LAG(avg_salary) OVER (ORDER BY payroll_year) AS prev_year_avg_salary
        FROM
            salary_data
    ) as sub
    WHERE
        prev_year_avg_salary IS NOT NULL
)
SELECT
    p.price_year,
    p.yoy_price_percent_change,
    s.yoy_salary_percent_change,
    p.yoy_price_percent_change - s.yoy_salary_percent_change AS difference,
    CASE 
        WHEN (p.yoy_price_percent_change - s.yoy_salary_percent_change) > 10 THEN 'Significant Increase'
        ELSE 'Normal'
    END AS status
FROM
    yoy_price_changes p
JOIN
    yoy_salary_changes s
ON
    p.price_year = s.payroll_year
ORDER BY
    p.price_year;