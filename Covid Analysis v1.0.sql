
SELECT *
from portfolio_covid..CovidDeaths$
WHERE continent is not null
order by 3,4

Alter table portfolio_covid..CovidDeaths$
drop column id

SELECT *
from portfolio_covid..CovidDeaths$
WHERE continent is not null
order by 3,4

SELECT *
from portfolio_covid..CovidVaccinations$
order by 3,4

SELECT *
from CovidDeaths$
order by 1,2

SELECT distinct location
from CovidDeaths$
WHERE continent is null
-- location does not always a country, especially for cases where the continent is null

--------------------

--Exploratory Data Analysis
--Total Cases vs Total Deaths
--Shows death rate if you are infected with Covid by country
SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as Death_Rate
FROM CovidDeaths$
WHERE continent is not null
Order by 1,2

--Total Cases vs Population
--Shows percentage of population infected by covid 
--Sort by countries with highest infection rate
SELECT location, population, MAX(total_cases) as HighestInfe,  MAX((total_cases/population))*100 as Infected_rate
FROM CovidDeaths$
WHERE continent is not null
GROUP BY population, location
Order by Infected_rate DESC

--Death count by location
SELECT location, MAX(total_deaths) as TotalDeathscount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY  location
Order by Totaldeathscount DESC

-- Realize data type of total deaths is string instead of int
-- covert total deaths to int
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY  location
Order by Totaldeathscount DESC

--Death count and death_rate by continent
SELECT location,Population, MAX(cast(total_deaths as int)) as TotalDeathsCount, max(total_deaths/population)*100 as Death_rate_by_continent
FROM CovidDeaths$
WHERE location in ('Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa')
GROUP BY  population,location
Order by Death_rate_by_continent DESC

-- Global Analysis
-- Total cases, deaths and death_rate globally, by date 
SELECT  date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Rate
FROM CovidDeaths$
WHERE continent is not null
Group by date
Order by 1,2

-- Cumulated cases, deaths and death rate
SELECT SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Rate
FROM CovidDeaths$
WHERE continent is not null
Order by 1,2


--Join CovidDeaths and CovidVaccinations tables on location and date
Select *
from CovidDeaths$
join CovidVaccinations$
	on CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date


-- Total Population vs Vaccinations
Select covidDeaths$.continent, covidDeaths$.location, covidDeaths$.date, new_vaccinations
from CovidDeaths$
join CovidVaccinations$
	on CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
Where CovidDeaths$.continent is not null
ORDER by 2,3

-- Total Population vs Vaccinations
-- Create a CTE
With PopvsVac (continent, location, date, population, new_vaccinations, cumulative_vaccination_count)
as
(
Select covidDeaths$.continent, covidDeaths$.location, covidDeaths$.date, covidDeaths$.population,new_vaccinations, 
 SUM(cast(new_vaccinations as bigint)) over (Partition by Coviddeaths$.location Order by covidDeaths$.location, covidDeaths$.date) as cumulative_vaccination_count 
from CovidDeaths$
join CovidVaccinations$
	on CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
Where CovidDeaths$.continent is not null
)
Select * , (cumulative_vaccination_count/population)*100 as vaccinated_population_percentage 
From PopvsVac
--WHERE location like '%states%'

--------------------
--Prepare views for visuallizations
Create View PercentpopulationVaccinated as 
Select covidDeaths$.continent, covidDeaths$.location, covidDeaths$.date, covidDeaths$.population,people_vaccinated, (people_vaccinated/population)*100 as vaccinated_population_percentage 
from CovidDeaths$
join CovidVaccinations$
	on CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
Where CovidDeaths$.continent is not null

Create View GlobalCasesvsDeaths as
SELECT  date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Rate
FROM CovidDeaths$
WHERE continent is not null
Group by date

Create View TotalCasesvsPopulation_bylocation as
SELECT location, population, MAX(total_cases) as HighestInfe,  MAX((total_cases/population))*100 as Infected_rate
FROM CovidDeaths$
WHERE continent is not null
GROUP BY population, location

Create View CumilatedCasesDeaths as
SELECT SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Rate
FROM CovidDeaths$
WHERE continent is not null

Create view totaldeathrate_byContinenet as
SELECT location,Population, MAX(cast(total_deaths as int)) as TotalDeathsCount, max(total_deaths/population)*100 as Death_rate_by_continent
FROM CovidDeaths$
WHERE location in ('Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa')
GROUP BY  population,location
