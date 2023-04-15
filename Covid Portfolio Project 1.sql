select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select * from PortfolioProject..CovidVaccinations
--order by 3, 4

select convert (int, portfolioproject..CovidDeaths.total_cases) from portfolioproject..CovidDeaths

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE PortfolioProject..covidvaccinations
ALTER COLUMN new_vaccinations float

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as TotalInfection
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's Break Things Down by Continent
--Showing Continents with highest death count per population

--select location, max(total_deaths) as TotalDeathCount
--from PortfolioProject..CovidDeaths
----where location like '%states%'
--where continent is null
--Group by location
--order by TotalDeathCount desc

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers



SELECT date, 
       SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
       (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2

--Total DeathPercentage

SELECT 
       SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
       (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
ORDER BY 1, 2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, 
(RollingPeopleVaccinated/population)*100
from portfolioproject..coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
SElect *, (RollingPeopleVaccinated/population)*100  
From PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar (255), 
date datetime, 
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

SElect *, (RollingPeopleVaccinated/population)*100  
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated