/*
Queries used for Tableau Project
*/

--1

SELECT SUM(new_cases) AS total_cases, SUM (new_deaths) AS total_deaths , SUM(new_deaths)/ SUM (new_cases) *100 AS Deatchpercentage
FROM PorfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--2 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PorfolioProject..Covid_Deaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

--3

SELECT location,population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS Percentage_of_population_infected
FROM PorfolioProject..Covid_Deaths
GROUP BY location, population
ORDER BY Percentage_of_population_infected DESC

--4

SELECT location, population,date, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PorfolioProject..Covid_Deaths
GROUP BY location, Population, date
ORDER BY PercentPopulationInfected DESC