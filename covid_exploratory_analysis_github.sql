use covid
go
--covid-19 data exploration by country - WHO covid data, World Bank population data
select * from deaths
select * from vaccination




--INFECTIONS ANALYSIS BY COUNTRY
select * from deaths

--infection count per country
select country, MAX(cumulative_cases) as total_cases from deaths
group by country
order by total_cases desc

--percentage of population infected
select d.Date_reported,d.country, d.cumulative_cases as cases,v.population,(d.cumulative_cases/v.population)*100 as infection_rate from deaths as d
join vaccination as v
on d.Date_reported = v.date and d.Country = v.country_location
order by d.Country



--DEATHS AND VACCINATION ANALYSIS

-- vaccination first impression
select date,country_location, total_vaccinations,new_vaccinations from vaccination
--where country_location like '%ireland%'
order by country_location,date

-- data cleansing, convert nvarchar to float in order to be able to perform aggregate functions
--remove '.0'
update vaccination
set new_vaccinations = REPLACE(new_vaccinations,'.0','')
update vaccination
set total_vaccinations = REPLACE(total_vaccinations,'.0','')
update vaccination
set population= REPLACE(population,'.0','')

--update data type
alter table vaccination add total_vaccinations1 float
alter table vaccination add new_vaccinations1 float
alter table vaccination add population1 float

update vaccination
set total_vaccinations1 = CONVERT(float,total_vaccinations)
update vaccination
set new_vaccinations1 = CONVERT(float,new_vaccinations)
update vaccination
set population1 = CONVERT(float,population)

select total_vaccinations, total_vaccinations1, new_vaccinations,new_vaccinations1,population,population1 from vaccination

--alter table vaccination drop column total_vaccinations
--alter table vaccination drop column new_vaccinations
--alter table vaccination drop column population

exec sp_rename 'vaccination.total_vaccinations1','total_vaccinations';
exec sp_rename 'vaccination.new_vaccinations1','new_vaccinations';
exec sp_rename 'vaccination.population1','population';




--DATA EXPLORATION on deaths and vaccinations

--vaccinations per date and country
select date,country_location,new_vaccinations,total_vaccinations from vaccination
--where country_location like '%argentina%'
order by country_location, date

--total vaccination per country
select country_location,MAX(total_vaccinations) as vaccinations from vaccination
where continent is not null
--where continent is null
group by country_location
order by vaccinations desc

--vaccinations per inhabitant
select date, country_location,new_vaccinations, total_vaccinations,population,total_vaccinations/population as vaccines_per_inhabitant from vaccination
order by 2,1
--use common table expression to calculate total of people vaccinated
With Pop_Vac(date,country_location,new_vaccinations,total_vaccinations,population,vaccines_per_inhabitant,people_vaccinated)
as
(
select date, country_location,new_vaccinations, total_vaccinations,population,total_vaccinations/population as vaccines_per_inhabitant,SUM(new_vaccinations) over (partition by country_location order by country_location,date) people_vaccinated from vaccination
)
select *,(people_vaccinated/population)*100 as percentage_vaccinated
from Pop_Vac

--select last total vaccinated population




--join deaths and vaccinations in order to analyze how these variables interact

--update location names for a proper join
 
select distinct Country from deaths order by country
select distinct country_location from vaccination order by country_location

update vaccination
set country_location = replace(country_location, 'Cote d%Ivoire', 'Cote dIvoire')
update vaccination
set country_location = replace(country_location, 'Czechia', 'Czech Republic')
update vaccination
set country_location = replace(country_location, 'Democratic Republic of Congo', 'Congo')
update deaths
set country = replace(country, 'Democratic Peoples Republic of Korea', 'North Korea')
update deaths
set country = replace(country, 'Falkland Islands (Malvinas)', 'Falkland Islands')
update vaccination
set country_location = replace(country_location, 'Laos', 'Lao Peoples Democratic Republic')
update vaccination
set country_location = replace(country_location, 'Micronesia (country)', 'Micronesia (Federated States of)')
update vaccination
set country_location = replace(country_location, 'Pitcairn', 'Pitcairn Islands')
update deaths
set country = replace(country, 'Republic of Korea', 'South Korea')
update vaccination
set country_location = replace(country_location, 'Russia', 'Russian Federation')
update vaccination
set country_location = replace(country_location, 'Sint Maarten (Dutch part)', 'Sint Maarten')
update vaccination
set country_location = replace(country_location, 'Syria', 'Syrian Arab Republic')
update deaths
set country = replace(country, 'The United Kingdom', 'United Kingdom')
update vaccination
set country_location = replace(country_location, 'Timor', 'Timor-Leste')
update deaths
set country = replace(country, 'Türkiye', 'Turkey')
update deaths
set country = replace(country, 'Holy See', 'Vatican')
update deaths
set country = replace(country, 'Venezuela (Bolivarian Republic of)', 'Venezuela')
update deaths
set country = replace(country, 'Viet Nam', 'Vietnam')




-- DEATH RATE, CASE RATE,VACCINATION RATE
--DROP view if exists deaths_vaccinations
create view deaths_vaccinations as
select d.Date_reported,d.Country,d.New_cases,d.Cumulative_cases,d.New_deaths,d.Cumulative_deaths,v.new_vaccinations,v.total_vaccinations,v.population from deaths as d
join vaccination as v
on d.Date_reported = v.date and d.Country=v.country_location

select * from deaths_vaccinations
order by Country, Date_reported


--DEATHS analysis
--death count per country
select country, MAX(Cumulative_deaths) as deaths from deaths_vaccinations
group by Country
order by deaths desc

--Death rate per day, country
select Date_reported,Country,Cumulative_deaths,Cumulative_cases,(Cumulative_deaths/NULLIF(Cumulative_cases,0))*100 as death_rate from deaths_vaccinations
--where country like '%argentina%'
order by Country, Date_reported

--global death rates per day
select date_reported, SUM(new_cases) cases, SUM(new_deaths) deaths,SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as death_rate
from deaths
group by Date_reported
order by 1

-- total death rates per country
create view death_rate_country as 
select  country, SUM(new_cases) cases, SUM(new_deaths) deaths,SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as death_rate
from deaths
group by country
--order by 4 desc



--Case rate per day, country (percentage of the population infected)
select date_reported, country, population,Cumulative_cases,(Cumulative_cases/population) *100 as case_rate from deaths_vaccinations
order by 2,1
--where country like '%brazil%'






















