-- View Covid Death table

select * from PortFolioProject..CovidDeaths

---- View Covid Vacination table
select * from PortFolioProject..CovidVaccinations

-- example of fields to draw from death table
select location,date, total_deaths,total_cases,new_cases,population 
from PortFolioProject..CovidDeaths 

-- Total Cases vs Total Deaths - Singapore case with percentile
-- Shows likelihood of dying if you contract covid in your country
-- Cumulative statistics

Select Location, date, total_cases,total_deaths, ROUND((total_deaths/total_cases)*100,4) as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%singapore%'
order by 2

---- Total Cases vs Population - Singapore case with percentile
---- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  round((total_cases/population)*100,4) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
 Where location like '%singapore%'
order by 2

---- Countries with Highest Infection Rate compared to Population
---- PercentPopulatedInfected = HighestInfectioncount / population * 100  

Select Location, Population, MAX(total_cases) as HighestInfectionCount, round(MAX(total_cases) / population * 100,4) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
---- Where location like '%Singapore%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

---- Countries with Highest Death Count per Population
---- PercentPopulatedDeath = HighestDeathcount / population * 100  

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount, round(MAX(cast(Total_deaths as int))/population * 100,4) as PercentPopulationDeath
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location,population
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Continent with Highest Death Count 
-- Showing contintents with the highest death count

Select Continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Continent with Highest Infected Count 
-- Showing contintents with the highest infected count

Select Continent,MAX(cast(total_cases as int)) as TotalInfectedCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalInfectedCount desc


-- GLOBAL NUMBERS
-- total case, total death,total,death percent
-- death percent = sum of death / sum of new case * 100 

Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%singapore%' 
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Join on location + date coz unique key , else too many redundant
-- RollingPeopleVaccinated is to get cumculative total of people vacinnated based on location and date


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as sumDeath 
from CovidDeaths dea inner join CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH CTE_ABC (continent,location,date,new_vac,sumDeath, population) 
as 
(
select dea.continent,dea.location,dea.date,vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as sumDeath , dea.population
from CovidDeaths dea inner join CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
)
SELECT *, (sumDeath / population)* 100 as SumDeathPercent from CTE_ABC
order by location desc


-- Using Temp Table to perform Calculation on Partition By in previous query
-- STEP 1 CREATE TEMP TABLE #PercentPopulationVaccinated 
-- DO THE QUERY NEEDED AS ABOVE CTE RESULT
-- INSERT INTO TEMP TABLE
-- ADD DROP TABLE IF EXIST

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_Vacc nvarchar(255),
sumDeath numeric,
Population numeric
)

insert into #PercentPopulationVaccinated  
select dea.continent,dea.location,dea.date,vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as sumDeath , dea.population
from CovidDeaths dea inner join CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 


SELECT *, (sumDeath / population)* 100 as SumDeathPercent
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
-- total case, total death,total,death percent
-- CREATE VIEW {NAME} as

CREATE VIEW TotalDeathStat as 

Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%singapore%' 
where continent is not null

select * from TotalDeathStat 