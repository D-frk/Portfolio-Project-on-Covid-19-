SELECT *
FROM [Portfolio Project on Covid'19 ]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project on Covid'19 ]..CovidVaccinations$
WHERE continent IS NOT NULL
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM [Portfolio Project on Covid'19 ]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project on Covid'19 ]..CovidDeaths$
WHERE location = 'Nigeria' AND continent IS NOT NULL
ORDER BY 1,2


SELECT location, date, population, total_cases,(total_cases/population)*100 AS Percentage_of_population_infected
FROM [Portfolio Project on Covid'19 ]..CovidDeaths$
WHERE location = 'Nigeria'
ORDER BY 1,2


SELECT location, date,population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percentage_of_population_infected
FROM [Portfolio Project on Covid'19 ]..CovidDeaths$
--WHERE location = 'Nigeria'
GROUP BY location,population,date
ORDER BY Percentage_of_population_infected DESC


SELECT continent, location,population, MAX(cast(total_deaths as int)) AS Highest_Death_Count
FROM [Portfolio Project on Covid'19 ]..CovidDeaths$
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY continent, location,population
ORDER BY Highest_Death_Count DESC

SELECT continent, MAX(cast(total_deaths as int)) AS Death_Count_By_Continent
FROM [Portfolio Project on Covid'19 ]..CovidDeaths$
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_Count_By_Continent DESC


SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 AS Death_Percentage
FROM [Portfolio Project on Covid'19 ]..CovidDeaths$
--WHERE location = 'Nigeria' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 DESC

--ROLLING COUNT OF VACC
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations_To_Date
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--CTE
WITH PopVsVac (continent,location,date,population,New_vaccinations,Total_Vaccinations_To_Date)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations_To_Date
--,(Total_Vaccinations_To_Date/population)*100,
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Total_Vaccinations_To_Date/population)*100 Percentage_Vaccinated_Till_Date
FROM PopVsVac


--TEMP TABLE
Drop Table if exists #PercentageVaccinatedTill_Date
CREATE TABLE #PercentageVaccinatedTill_Date
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
Total_Vaccinations_To_Date numeric
)

INSERT INTO #PercentageVaccinatedTill_Date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations_To_Date
--,(Total_Vaccinations_To_Date/population)*100,
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (Total_Vaccinations_To_Date/Population)*100
FROM #PercentageVaccinatedTill_Date

CREATE VIEW PercentageVaccinatedTill_Date AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Total_Vaccinations_To_Date
--,(Total_Vaccinations_To_Date/population)*100,
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
