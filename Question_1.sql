WITH avg_salaries_per_year_industry AS (
    SELECT
        payroll_year,
        industry_branch_name,
        AVG(value) AS avg_salary
    FROM
        t_barbora_kalincova_project_sql_primary_final
    WHERE
        VALUE_TYPE_NAME = 'Průměrná hrubá mzda na zaměstnance'
    GROUP BY
        payroll_year, industry_branch_name
),
yoy_changes AS (
    SELECT
        payroll_year,
        industry_branch_name,
        avg_salary,
        LAG(avg_salary) OVER (PARTITION BY industry_branch_name ORDER BY payroll_year) AS prev_year_salary,
        (avg_salary - LAG(avg_salary) OVER (PARTITION BY industry_branch_name ORDER BY payroll_year)) / LAG(avg_salary) OVER (PARTITION BY industry_branch_name ORDER BY payroll_year) * 100 AS yoy_percent_change
    FROM
        avg_salaries_per_year_industry
),
industry_status AS (
    SELECT
        industry_branch_name,
        MIN(yoy_percent_change) AS min_yoy_change,
        MAX(yoy_percent_change) AS max_yoy_change
    FROM
        yoy_changes
    GROUP BY
        industry_branch_name
)
SELECT
    industry_branch_name,
    CASE 
        WHEN min_yoy_change >= 0 THEN 'Increasing'
        ELSE 'Decreasing at times'
    END AS salary_trend
FROM
    industry_status;