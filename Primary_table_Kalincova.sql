CREATE TABLE t_barbora_kalincova_project_sql_primary_final AS (
WITH EXTENDED_CZECHIA_PRICE AS (
SELECT *,year(date_from) AS year_from, CASE WHEN MONTH(date_from) BETWEEN 1 AND 3 THEN "1" WHEN MONTH(date_from) BETWEEN 4 AND 6 THEN "2"
	WHEN MONTH(date_from) BETWEEN 7 AND 9 THEN "3" WHEN MONTH(date_from) BETWEEN 10 AND 12 THEN "4" END AS "Quarter"
FROM czechia_price
WHERE region_code IS NULL
)
SELECT cp.value, cp.value_type_code, cpvt.name AS "VALUE_TYPE_NAME",cp.unit_code, cpu.name AS "Unit_code_name", cp.calculation_code, cpc.name AS "Calculation_name", 
cp.industry_branch_code , cpib.name AS "industry_branch_name", cp.payroll_year, cp.payroll_quarter, cpr.value AS "price", cpr.category_code, cpcat.name, cpcat.price_value AS "unit_amount", cpcat.price_unit 
AS "unit", cpr.date_from, cpr.date_to
FROM czechia_payroll cp 
JOIN czechia_payroll_calculation cpc ON cp.calculation_code  = cpc.code 
JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code 
JOIN czechia_payroll_unit cpu ON cp.unit_code = cpu.code 
JOIN czechia_payroll_value_type cpvt ON cp.value_type_code = cpvt.code
LEFT JOIN EXTENDED_CZECHIA_PRICE cpr ON cp.payroll_year = cpr.year_from AND cp.payroll_quarter = cpr.Quarter
JOIN czechia_price_category cpcat ON cpr.category_code = cpcat.code
) 