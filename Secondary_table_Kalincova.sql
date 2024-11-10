create table t_barbora_kalincova_project_SQL_secondary_final as (
select c.country, e.year, e.gdp, e.population,e.gini, e.taxes, e.fertility, e.mortaliy_under5, c.abbreviation , c.avg_height , c.calling_code , c.capital_city , c.continent, c.currency_name ,c.religion ,
	c.currency_code, c.domain_tld , c.elevation , c.north , c.south , c.west , c.east , c.government_type , c.independence_date ,
	c.iso_numeric , c.landlocked , c.life_expectancy , c.national_symbol , c.national_dish , c.population_density , 
	c.population as "population_in_2018", c.region_in_world , c.surface_area , c.yearly_average_temperature , c.median_age_2018,
	c.iso2 , c.iso3 
from countries c
left join economies e  on c.country = e.country 
UNION
select e.country, e.year, e.gdp, e.population,e.gini, e.taxes, e.fertility, e.mortaliy_under5, c.abbreviation , c.avg_height , c.calling_code , c.capital_city , c.continent, c.currency_name ,c.religion ,
	c.currency_code, c.domain_tld , c.elevation , c.north , c.south , c.west , c.east , c.government_type , c.independence_date ,
	c.iso_numeric , c.landlocked , c.life_expectancy , c.national_symbol , c.national_dish , c.population_density , 
	c.population as "population_in_2018", c.region_in_world , c.surface_area , c.yearly_average_temperature , c.median_age_2018,
	c.iso2 , c.iso3 
from economies e 
left join countries c on e.country = c.country 
)
