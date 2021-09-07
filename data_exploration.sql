SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY Location,Date

-- Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT Location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY Location,Date


SELECT Location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY Location,Date

-- Looking at the Total Cases vs Population in the United States
-- Shows what percentage of the population got COVID

SELECT Location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY Location,Date


-- Looking at Countries with Highest Infection Rate compared to Population 

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population 

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by location 
ORDER BY TotalDeathCount DESC

-- Break down by continent

--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent is null
--Group by location
--ORDER BY TotalDeathCount DESC

-- Showing the contintents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

-- TEMP Table

-- DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated



-- Creating View to store later for Tableau 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null