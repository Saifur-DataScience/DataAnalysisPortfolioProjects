USE PortfolioProject;

SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

-- Keeping on the columns that we need

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths ORDER BY 1, 2; 


-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, 
	   ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2; 


-- Looking at Total Cases vs Population
-- Shows what percent of total population got covid

SELECT location, date, total_cases, population, 
	   ROUND((total_cases/population)*100, 4) as PercentPopulationInfected
FROM CovidDeaths
WHERE location = 'India'
ORDER BY 1, 2; 

-- Looking at countries with highest infection rate compared to the population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
	   ROUND(MAX((total_cases/population)*100), 4) as PercentPopulationInfected
FROM CovidDeaths
--WHERE location = 'India'
GROUP BY location, population
ORDER BY 4 DESC;


-- Showing countries with highest death count per population
-- Total Deaths column is actually of type nvarchar and hence, need to cast it to INT

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Let's look at the data with respect to the continent now

SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc; 

-- Above query only shows partial data. For eg. Asia shows only for India
-- And North America is showing only for USA and not Canada

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount desc; 


-- Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as INT)) as TotalDeaths, 
	ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100, 4) as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date; 

-- Total cases across the globe vs total deaths

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as INT)) as TotalDeaths, 
	ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100, 4) as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL; 


-- Now let's look at the CovidVaccinations table as well

SELECT * 
FROM CovidVaccinations
WHERE location = 'India';


-- Let's join both the tables to get more insight

SELECT *
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	 ON cd.location = cv.location
	 AND cd.date = cv.date; 


-- Looking at total populations vs vaccinations

SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	 ON cd.location = cv.location
	 AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cd.location = 'India'
ORDER BY 2,3; 


-- Let's use rolling sum to see total number of vaccinated people on w.r.t date

SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations, 
	   SUM(CAST(cv.new_vaccinations as INT)) 
	   OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	 ON cd.location = cv.location
	 AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--AND cd.location = 'India'
ORDER BY 2,3; 


-- Creating a temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations, 
	   SUM(CONVERT(BIGINT, cv.new_vaccinations)) 
	   OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	 ON cd.location = cv.location
	 AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--AND cd.location = 'India'
--ORDER BY 2,3; 

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view for later visualization

Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations, 
	   SUM(CONVERT(BIGINT, cv.new_vaccinations)) 
	   OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	 ON cd.location = cv.location
	 AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3;

SELECT * FROM PercentPopulationVaccinated;