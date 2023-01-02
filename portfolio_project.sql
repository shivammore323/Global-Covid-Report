use portfolioproject

select * from CovidDeaths
select * from CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by location

-- Looking at total cases vs total deaths
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%India%'
and continent is not null
order by location,date

-- Looking at total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths
where location like '%India%'
and continent is not null
order by location,date

-- Looking at highest infection rate
select location, population, max(total_cases) as HighestInfectionCount,Max((total_cases/population)*100) as PrecentPopulationInfected
from CovidDeaths
where continent is not null
group by location,population
order by PrecentPopulationInfected desc

-- Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCounts
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCounts desc

-- Break down using continents
select location, max(cast(total_deaths as int)) as TotalDeathCounts
from CovidDeaths
where continent is null
group by location
order by TotalDeathCounts desc

-- Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage
from CovidDeaths
--where location like '%India%'
where continent is not null
--group by date
--order by date

-- Looking at total population vs total vaccinations

select cd.continent, cd.location, cd.date, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as bigint)) over(partition by cd.location order by cd.location,cd.date) as rollingPeopleVaccinated
from CovidDeaths as cd inner join CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by continent,location,date

-- Use Cte

with PopVsVac(continent,location,date,new_vaccinations,population,rollingPeopleVaccinated) as  (select cd.continent, cd.location, cd.date, cv.new_vaccinations, cd.population,
sum(cast(cv.new_vaccinations as bigint)) over(partition by cd.location order by cd.location,cd.date) as rollingPeopleVaccinated
from CovidDeaths as cd inner join CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null)
--and cd.location like 'India')
--order by continent,location,date)
select *, (rollingPeopleVaccinated/population)*100 as PercentVaccinations from PopVsVac

-- Creating View to store data for later visualization
Create view PercentPopulationVaccinated as (select cd.continent, cd.location, cd.date, cv.new_vaccinations, cd.population,
sum(cast(cv.new_vaccinations as bigint)) over(partition by cd.location order by cd.location,cd.date) as rollingPeopleVaccinated
from CovidDeaths as cd inner join CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null)
--and cd.location like 'India')
--order by continent,location,date)

/* Queries for Tableau vizualization */
-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc





