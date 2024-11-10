WITH gdp_data AS (
    SELECT
    	year gdp_year,
        gdp,
        LAG(gdp) OVER (ORDER BY year) AS prev_year_gdp,
        CASE 
            WHEN LAG(gdp) OVER (ORDER BY year) IS NULL THEN NULL
            ELSE (gdp - LAG(gdp) OVER (ORDER BY year)) / LAG(gdp) OVER (ORDER BY year) * 100
        END AS yoy_gdp_percent_change
    FROM
        t_barbora_kalincova_project_sql_secondary_final
    WHERE
        lower(country) like 'czech%'        
    GROUP BY
        year
),
price_data AS (
    SELECT
        YEAR(date_from) AS price_year,
        AVG(price) AS avg_price,
        LAG(AVG(price)) OVER (ORDER BY YEAR(date_from)) AS prev_year_avg_price
    FROM
        t_barbora_kalincova_project_sql_primary_final
    WHERE
        price IS NOT null
    GROUP BY
        price_year
),
yoy_price_changes AS (
    SELECT
        price_year,
        avg_price,
        prev_year_avg_price,
        CASE 
            WHEN prev_year_avg_price IS NULL THEN NULL
            ELSE (avg_price - prev_year_avg_price) / prev_year_avg_price * 100
        END AS yoy_price_percent_change
    FROM 
    	price_data
    WHERE
        prev_year_avg_price IS NOT NULL
),
salary_data AS (
 SELECT
        payroll_year,
        AVG(value) AS avg_salary,
        LAG(AVG(VALUE)) OVER (ORDER BY payroll_year) AS prev_year_avg_salary
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
    FROM salary_data
    WHERE
        prev_year_avg_salary IS NOT NULL
)
SELECT
    g.gdp_year,
    g.yoy_gdp_percent_change,
    p.yoy_price_percent_change,
    s.yoy_salary_percent_change,
    g.yoy_gdp_percent_change - p.yoy_price_percent_change AS gdp_vs_price_difference,
    g.yoy_gdp_percent_change - s.yoy_salary_percent_change AS gdp_vs_salary_difference
FROM
    gdp_data g
LEFT JOIN
    yoy_price_changes p ON g.gdp_year = p.price_year
LEFT JOIN
    yoy_salary_changes s ON g.gdp_year = s.payroll_year
where 
	g.yoy_gdp_percent_change is not null and p.yoy_price_percent_change is not null and s.yoy_salary_percent_change is not null 
ORDER BY
    g.gdp_year;