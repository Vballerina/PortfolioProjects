SELECT *
FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

--Changing datatypes
ALTER TABLE PortfolioProjects..CovidDeaths ALTER COLUMN new_cases float NULL

ALTER TABLE PortfolioProjects..CovidVaccinations ALTER COLUMN new_vaccinations float NULL

--Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercantage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%Ukraine%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPercantage
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infaction Rate compare to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY 4 Desc

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY 2 Desc

--LET'S BREAK THINGS DOWN by CONTINENT
--Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY 2 Desc

--Showint Continents with Highest Death Count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY 2 Desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, nullif(SUM(new_deaths),0)/nullif(SUM(new_cases),0)*100 as DeathPercantage
FROM PortfolioProjects..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population) *100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2,3

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 1,2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVac
CREATE TABLE #PercentPopulationVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 1,2,3

SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVac

--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 1,2,3

SELECT *
FROM PercentPopulationVac