SELECT *
FROM PorfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject..Covid_ Vaccinations

-- Select Data that we are going to be using

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM PorfolioProject..Covid_Deaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- I had to CAST the total_deaths and total_cases into float to perform division
-- Shows likehood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS Deathpercentage
FROM PorfolioProject..Covid_Deaths
--WHERE location = 'Australia'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid

SELECT location, date,population, total_cases,(total_cases/population)*100 AS Percentage_of_population_infected
FROM PorfolioProject..Covid_Deaths
WHERE location = 'Australia'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS Percentage_of_population_infected
FROM PorfolioProject..Covid_Deaths
GROUP BY location, population
WHERE continent IS NOT NULL
ORDER BY Percentage_of_population_infected DESC

--Showing countries with highest death count per population

SELECT location, MAX(CAST (total_deaths AS bigint)) AS highest_death_count
FROM PorfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC

--Showing continents with highest death count per population

SELECT continent, MAX(CAST (total_deaths AS BIGINT)) AS highest_death_count
FROM PorfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC

-- Global numbers
-- To avoid the division by zero erro I needed to put the following sets

SET ARITHABORT OFF
SET ANSI_WARNINGS OFF

-- We group the deathpercentage group by date

SELECT date, SUM(new_cases) AS total_cases, SUM (new_deaths) AS total_deaths , SUM(new_deaths)/ SUM (new_cases) *100 AS Deatchpercentage
FROM PorfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- We look at the total death percentage

SELECT SUM(new_cases) AS total_cases, SUM (new_deaths) AS total_deaths , SUM(new_deaths)/ SUM (new_cases) *100 AS Deatchpercentage
FROM PorfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at total population vs vaccination

SELECT cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
SUM(CAST(cov.new_vaccinations AS bigint)) OVER (Partition by cod.location ORDER BY cod.location, cod.date) AS rolling_people_vaccinated
FROM PorfolioProject..Covid_Deaths AS Cod
LEFT JOIN PorfolioProject..[Covid_ Vaccinations] AS Cov
ON Cod.location = Cov.location AND Cod.date = Cov.date
WHERE cod.continent IS NOT NULL 
ORDER BY 1,2,3

-- WE use a CTE

WITH popvsvac AS
(SELECT cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
SUM(CAST(cov.new_vaccinations AS bigint)) OVER (Partition by cod.location ORDER BY cod.location, cod.date) AS rolling_people_vaccinated
FROM PorfolioProject..Covid_Deaths AS Cod
LEFT JOIN PorfolioProject..[Covid_ Vaccinations] AS Cov
ON Cod.location = Cov.location AND Cod.date = Cov.date
WHERE cod.continent IS NOT NULL 
--ORDER BY 1,2,3
)

SELECT *, (rolling_people_vaccinated/population) * 100
FROM popvsvac

-- Alternatively we can create a Temp table

DROP TABLE IF exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime, 
population numeric, 
new_vaccination numeric, 
rolling_people_vaccinated numeric)

INSERT INTO #percentpopulationvaccinated

SELECT cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
SUM(CAST(cov.new_vaccinations AS bigint)) OVER (Partition by cod.location ORDER BY cod.location, cod.date) AS rolling_people_vaccinated
FROM PorfolioProject..Covid_Deaths AS Cod
LEFT JOIN PorfolioProject..[Covid_ Vaccinations] AS Cov
ON Cod.location = Cov.location AND Cod.date = Cov.date
--WHERE cod.continent IS NOT NULL 
--ORDER BY 1,2,3

SELECT *, (rolling_people_vaccinated/population) * 100
FROM #percentpopulationvaccinated

-- Creating view to store data for visualization 

CREATE VIEW percentpopulationvaccinated AS 
SELECT cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
SUM(CAST(cov.new_vaccinations AS bigint)) OVER (Partition by cod.location ORDER BY cod.location, cod.date) AS rolling_people_vaccinated
FROM PorfolioProject..Covid_Deaths AS Cod
LEFT JOIN PorfolioProject..[Covid_ Vaccinations] AS Cov
ON Cod.location = Cov.location AND Cod.date = Cov.date
WHERE cod.continent IS NOT NULL 
--ORDER BY 1,2,3\

SELECT * 
FROM percentpopulationvaccinated
