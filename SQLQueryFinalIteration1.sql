

SELECT *
FROM PortfolioProjects..[Covid deaths]
WHERE continent != ''

UPDATE PortfolioProjects..CovidVaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = ''


SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..[Covid deaths]
ORDER BY 2, 3

ALTER TABLE PortfolioProjects..[Covid deaths]
	ALTER COLUMN new_cases bigint

-- Observing the total_deaths vs total_cases
-- this query shows how likely it is to die if you get infected
SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentages
FROM PortfolioProjects..[Covid deaths]
WHERE location = 'Nigeria'
ORDER BY 2, 3


-- Observing the total_cases  vs population
-- This query shows the percentage of population that has covid
SELECT continent, location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProjects..[Covid deaths]
WHERE location = 'Nigeria'
ORDER BY 2, 3

SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProjects..[Covid deaths]
--WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with the highest death count
SELECT continent, location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProjects..[Covid deaths]
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Death count by continent
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProjects..[Covid deaths]
--WHERE location = 'Nigeria'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Sums
SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(CAST(new_deaths AS NUMERIC(18,0)))/SUM(CAST(new_cases AS NUMERIC(18,0)))*100 AS DeathPercentage
FROM PortfolioProjects..[Covid deaths]
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Query for Total population vs Vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date )
 AS RollingVaccinationCount
FROM PortfolioProjects..[Covid deaths] dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY  2, 3
)
SELECT *, (RollingVaccinationCount/Population)*100
FROM PopvsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date )
 AS RollingVaccinationCount
FROM PortfolioProjects..[Covid deaths] dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY  2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
