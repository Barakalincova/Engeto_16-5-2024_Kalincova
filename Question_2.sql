WITH period_bounds AS (
    SELECT
        GREATEST(MIN(payroll_year), MIN(EXTRACT(YEAR FROM date_from))) AS first_year,
        LEAST(MAX(payroll_year), MAX(EXTRACT(YEAR FROM date_from))) AS last_year
    FROM
        t_barbora_kalincova_project_sql_primary_final
),
avg_salary AS (
    SELECT
        payroll_year,
        AVG(value) AS average_salary
    FROM
        t_barbora_kalincova_project_sql_primary_final
    WHERE
        VALUE_TYPE_NAME = 'Průměrná hrubá mzda na zaměstnance'
    GROUP BY
        payroll_year
    HAVING
        payroll_year IN (SELECT first_year FROM period_bounds UNION SELECT last_year FROM period_bounds)
),
prices AS (
    SELECT
        EXTRACT(YEAR FROM date_from) AS price_year,
        name AS item,
        AVG(price) AS price,
        unit AS unit
    FROM
        t_barbora_kalincova_project_sql_primary_final
    WHERE
        name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový') AND
        EXTRACT(YEAR FROM date_from) IN (SELECT first_year FROM period_bounds UNION SELECT last_year FROM period_bounds)
    GROUP BY
        EXTRACT(YEAR FROM date_from),
        name,
        unit
)
SELECT
        s.payroll_year,
        p.item,
        round(s.average_salary / p.price,1) AS quantity,
        p.unit
    FROM
        avg_salary s
    JOIN
        prices p
    ON
        s.payroll_year = p.price_year
ORDER BY
    payroll_year,
    item;