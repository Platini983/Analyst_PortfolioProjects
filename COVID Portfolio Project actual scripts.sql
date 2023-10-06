Select *
from PorfolioProject..CovidDeaths
order by 3, 4


--Select *
--from PorfolioProject..CovidVaccinations
--order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total cases vs Total Deaths
-- Showa likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths) / NULLIF(CONVERT(float,total_cases), 0))*100 as DeathPercentage
from PorfolioProject..CovidDeaths
Where location like '%Ghana%'
order by 1, 2




-- Looking at Total Cases vs Population
-- shows what percentage of population got covid
--
Select Location, date, population, total_cases, (CONVERT(float,total_cases) / NULLIF(CONVERT(float,population), 0))*100 as PercentPopulationInfected
from PorfolioProject..CovidDeaths
Where location like '%Ghana%'
order by 1, 2


-- Looking att countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float,total_cases) / NULLIF(CONVERT(float,population), 0)))*100 as PercentPopulationInfected
from PorfolioProject..CovidDeaths
--Where location like '%Ghana%'
Group by Location, population
order by PercentPopulationInfected desc


-- showing Countries with  Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths
--Where location like '%Ghana%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- BY CONTINENT
--Continent with Highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths
--Where location like '%Ghana%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PorfolioProject..CovidDeaths
--Where location like '%Ghana%' 
Where continent is not null
order by 1, 2



-- Total Population vs Vacination

Select *
from CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)* 100
from CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3



-- USE CTE

with PopsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)* 100
from CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)* 100
from PopsVac





--USE TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)* 100
from CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population)* 100
from #PercentPopulationVaccinated





-- Creating  View to Store data for Visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)* 100
from CovidDeaths dea
Join CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3


Select *
from PercentPopulationVaccinated
