--SELECT *
--FROM PortfolioProject..['Covid Vaccinations$']
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..['Covid Deaths']
--WHERE continent IS NOT NULL
--ORDER BY 3,4

-- Select Data tha we're going to use

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject.. ['Covid Deaths']
--ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of death from contraction of COVID in Australia

--SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS 'Death Percentage'
--FROM PortfolioProject.. ['Covid Deaths']
--WHERE location LIKE 'Australia'
--ORDER BY 1,2 desc


-- Looking at the total cases vs the population

--SELECT Location, date, total_cases, population, ROUND((total_cases/population)*100,2) AS 'Population Contraction Percentage'
--FROM PortfolioProject.. ['Covid Deaths']
--WHERE location LIKE 'Australia'
--ORDER BY 1,2 desc


-- Looking at countries with highest infection rate compared to the population

--SELECT Location, Population,MAX(total_cases) AS 'HighestInfectionCount', ROUND(MAX((total_cases/population)*100),2) AS 'PercentagePopulationInfected'
--FROM PortfolioProject.. ['Covid Deaths']
--WHERE location LIKE '%states%'
--GROUP BY location, population
--ORDER BY 'PercentagePopulationInfected' DESC

-- Showing Countries with the Highest Death Count per Population

--SELECT Location, Population, MAX(CAST(total_deaths AS INT)) AS 'TotalDeathCount'
--FROM PortfolioProject.. ['Covid Deaths']
--WHERE location LIKE '%states%'
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY 'TotalDeathCount' DESC


-- Showing the Continents with the Highest Death Count

--SELECT location, MAX(CAST(total_deaths AS INT)) AS 'TotalDeathCount'
--FROM PortfolioProject.. ['Covid Deaths']
--WHERE location LIKE '%states%'
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY 'TotalDeathCount' DESC

-- Global Death numbers total

--SELECT SUM(new_cases) AS 'Total_Cases', SUM(CAST(new_deaths AS INT)) AS 'Total_Deaths', ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS 'Death_Percentage(%)'
--FROM PortfolioProject.. ['Covid Deaths']
--WHERE location LIKE 'Australia'
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2 desc

-- Let's see total death percentage over time

--SELECT date,SUM(new_cases) AS 'Total_Cases', SUM(CAST(new_deaths AS INT)) AS 'Total_Deaths', ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS 'Death_Percentage(%)'
--FROM PortfolioProject.. ['Covid Deaths']
--WHERE location LIKE 'Australia'
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2 desc


-- Looking at Total Population vs Vaccinations

--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
--FROM PortfolioProject.. ['Covid Deaths'] dea
--JOIN PortfolioProject.. ['Covid Vaccinations$'] vac
--ON dea.location = vac.location
--AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


--Running total of Vaccinations per Country

SELECT dea.continent AS 'Continent', dea.location AS 'Location', dea.date AS 'Date', 
dea.population AS 'Population', vac.new_vaccinations AS 'NewVaccinations',SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS 'RunningVaccinationsTotal' --('RunningVaccinationsTotal'/Population)*100 AS 'TotalVaccinationPercentage'
FROM PortfolioProject.. ['Covid Deaths'] dea
JOIN PortfolioProject.. ['Covid Vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RunningVaccinationsTotal)
AS
(
SELECT dea.continent AS 'Continent', dea.location AS 'Location', dea.date AS 'Date', 
dea.population AS 'Population', vac.new_vaccinations AS 'NewVaccinations', SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS 'RunningVaccinationsTotal' --('RunningVaccinationsTotal'/Population)*100 AS 'TotalVaccinationPercentage'
FROM PortfolioProject.. ['Covid Deaths'] dea
JOIN PortfolioProject.. ['Covid Vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, ROUND((RunningVaccinationsTotal/population*100),2) AS 'PopvsVac'
FROM PopvsVac

-- Temporary Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RunningVaccinationsTotal numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent AS 'Continent', dea.location AS 'Location', dea.date AS 'Date', 
dea.population AS 'Population', vac.new_vaccinations AS 'NewVaccinations', SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS 'RunningVaccinationsTotal' --('RunningVaccinationsTotal'/Population)*100 AS 'TotalVaccinationPercentage'
FROM PortfolioProject.. ['Covid Deaths'] dea
JOIN PortfolioProject.. ['Covid Vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, ROUND((RunningVaccinationsTotal/population*100),2) AS 'PopvsVac'
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent AS 'Continent', dea.location AS 'Location', dea.date AS 'Date', 
dea.population AS 'Population', vac.new_vaccinations AS 'NewVaccinations', SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS 'RunningVaccinationsTotal' --('RunningVaccinationsTotal'/Population)*100 AS 'TotalVaccinationPercentage'
FROM PortfolioProject.. ['Covid Deaths'] dea
JOIN PortfolioProject.. ['Covid Vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated