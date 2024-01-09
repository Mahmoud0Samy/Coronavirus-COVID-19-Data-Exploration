USE CovidProject_db;

SELECT * 
FROM 
	CovidDeaths2023
WHERE 
	continent IS NOT NULL
ORDER BY 
	location;

-- Total cases vs total deaths by location
-- Death probability in the case of contracting Covid-19 in each country 
SELECT 
	location, 
	CAST(date AS DATE) AS date, 
	total_cases, 
	total_deaths, 
	ROUND((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100, 2) AS Death_Percentage_of_Cases 
FROM 
	CovidDeaths2023
WHERE 
	location = 'Egypt'
	AND total_deaths IS NOT NULL
	--AND continent IS NOT NULL
ORDER BY 
	2;

SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	ROUND((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100, 2) AS Death_Percentage_of_Cases 
FROM 
	CovidDeaths2023
WHERE 
	continent IS NULL
ORDER BY 
	1, 2;




SELECT 
	location, 
	MAX(CAST(total_cases AS BIGINT)) AS 'Max of Total Cases',
	MAX(CAST(total_deaths AS BIGINT)) AS 'Max of Total Deaths' 
FROM 
	CovidDeaths2023
WHERE 
	continent IS NOT NULL
GROUP BY 
	location
HAVING 
	'Max of Total Cases' IS NOT NULL 
	AND 'Max of Total Deaths' IS NOT NULL
ORDER BY 
	3 DESC, 2 DESC, 1;




-- Total cases vs population by location
-- Infection probability in each country
SELECT 
	location, 
	CAST(date AS DATE) AS date, 
	total_cases, 
	ROUND((CAST(total_cases AS FLOAT) / population) * 100, 4) AS 'Infected Percentage of the Population' 
FROM 
	CovidDeaths2023
WHERE 
	location = 'Egypt'
	AND total_cases IS NOT NULL
	--AND continent IS NOT NULL
ORDER BY 
	2;

SELECT 
	location, 
	date, 
	total_cases, 
	population, 
	ROUND((CAST(total_cases AS FLOAT) / population) * 100, 4) AS 'Infected Percentage of the Population' 
FROM 
	CovidDeaths2023
WHERE 
	continent IS NULL
ORDER BY 
	1, 2;




-- Maximum Infection rate vs population
SELECT 
	location, 
	MAX(CAST(total_cases AS FLOAT)) AS Highest_Infection_Count, 
	population, 
	ROUND(MAX((CAST(total_cases AS FLOAT) / population) * 100), 2) AS 'Infected Percentage of the Population' 
FROM 
	CovidDeaths2023
WHERE 
	continent IS NOT NULL
GROUP BY 
	location, 
	population
ORDER BY 
	'Infected Percentage of the Population' DESC;

-- Maximum Death rate vs population
SELECT 
	location, 
	MAX(CAST(total_deaths AS FLOAT)) AS Highest_Death_Count, 
	population, 
	ROUND(MAX((CAST(total_deaths AS FLOAT) / population) * 100), 2) AS 'Death Percentage of the Population' 
FROM 
	CovidDeaths2023
WHERE 
	continent IS NOT NULL
GROUP BY 
	location,
	population
ORDER BY 
	'Death Percentage of the Population' DESC;




-- Maximum Death count by Continent
SELECT 
	location, 
	MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count 
FROM 
	CovidDeaths2023
WHERE 
	continent IS NULL
GROUP BY 
	location, 
	population
ORDER BY 
	Highest_Death_Count DESC;

-- Maximum Infection count by Continent
SELECT 
	location, 
	MAX(CAST(total_cases AS INT)) AS Highest_Infection_Count 
FROM 
	CovidDeaths2023
WHERE 
	continent IS NULL
GROUP BY 
	location, 
	population
ORDER BY 
	Highest_Infection_Count DESC;




-- Total cases vs total deaths by date
-- Death probability in the case of contracting Covid-19 in each country 
SELECT 
	SUM(CAST(new_cases AS INT)) AS Total_New_Cases,
	SUM(CAST(new_deaths AS INT))AS Total_New_Deaths,
	ROUND(SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100, 2) AS Death_Percentage_of_Cases 
FROM 
	CovidDeaths2023
WHERE 
	location = 'Egypt'
ORDER BY 
	1, 2;

SELECT
	CAST(D.date AS DATE) date,
	new_cases,
	new_deaths,
	V.new_vaccinations
FROM 
	CovidDeaths2023 D
JOIN
	CovidVaccinations2023 V
		ON D.location = V.location
		AND D.date = V.date
WHERE 
	D.location = 'Egypt'
	AND new_cases IS NOT NULL
ORDER BY 
	1, 2;








SELECT * 
FROM 
	CovidVaccinations2023
WHERE 
	continent IS NOT NULL
ORDER BY 
	location;


-- Population vs Vaccination rate
SELECT 
	D.continent,
	D.location,
	D.date,
	D.population,
	V.new_vaccinations,
	SUM(CAST(V.new_vaccinations AS BIGINT)) 
	OVER 
		(PARTITION BY D.location
			ORDER BY D.location, D.date) AS Sum_of_New_Vaccinations_Rolling
FROM 
	CovidDeaths2023 D
JOIN
	CovidVaccinations2023 V
		ON D.location = V.location
		AND D.date = V.date
WHERE
	D.continent IS NOT NULL
ORDER BY
	2,3;

-- Using a CTE so we can divide the Sum_of_New_Vaccinations_Rolling column by the population INCLUDING BOOSTERS
WITH Rolling_VaccS_vs_Population (
	continent,
	location,
	date,
	population, 
	new_vaccinations,
	Sum_of_New_Vaccinations_Rolling)
AS (
	SELECT 
		D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS BIGINT)) 
		OVER 
			(PARTITION BY D.location
				ORDER BY D.location, D.date) AS Sum_of_New_Vaccinations_Rolling
	FROM 
		CovidDeaths2023 D
	JOIN
		CovidVaccinations2023 V
			ON D.location = V.location
			AND D.date = V.date
	WHERE
		D.continent IS NOT NULL)
SELECT 
	*,
	(Sum_of_New_Vaccinations_Rolling / population ) * 100 AS Sum_of_New_Vaccinations_Rolling_From_Population
FROM
	Rolling_VaccS_vs_Population;

-- Using a Temp_Table so we can divide the Sum_of_New_Vaccinations_Rolling column by the population INCLUDING BOOSTERS
DROP TABLE IF EXISTS #Rolling_VaccS_vs_Population_Temp
CREATE TABLE #Rolling_VaccS_vs_Population_Temp (
	continent nvarchar(255),
	location nvarchar(255),
	date DATETIME,
	population NUMERIC,
	new_vaccinations NUMERIC,
	Sum_of_New_Vaccinations_Rolling NUMERIC
);

INSERT INTO
	#Rolling_VaccS_vs_Population_Temp
SELECT 
		D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS NUMERIC)) 
		OVER 
			(PARTITION BY D.location
				ORDER BY D.location, D.date) AS Sum_of_New_Vaccinations_Rolling
	FROM 
		CovidDeaths2023 D
	JOIN
		CovidVaccinations2023 V
			ON D.location = V.location
			AND D.date = V.date;

SELECT 
	*,
	(Sum_of_New_Vaccinations_Rolling / population ) * 100 AS Sum_of_New_Vaccinations_Rolling_From_Population
FROM
	#Rolling_VaccS_vs_Population_Temp;

-- Using a view so we can divide the Sum_of_New_Vaccinations_Rolling column by the population INCLUDING BOOSTERS
DROP VIEW IF EXISTS Rolling_VaccS_vs_Population_View
CREATE VIEW Rolling_VaccS_vs_Population_View AS
SELECT 
		D.continent,
		D.location,
		D.date,
		D.population,
		V.new_vaccinations,
		SUM(CAST(V.new_vaccinations AS FLOAT)) 
		OVER 
			(PARTITION BY D.location
				ORDER BY D.location, D.date) AS Sum_of_New_Vaccinations_Rolling
	FROM 
		CovidDeaths2023 D
	JOIN
		CovidVaccinations2023 V
			ON D.location = V.location
			AND D.date = V.date
	WHERE
		D.continent IS NOT NULL;

SELECT 
	*,
	(Sum_of_New_Vaccinations_Rolling / population ) * 100 AS Sum_of_New_Vaccinations_Rolling_From_Population
FROM
	Rolling_VaccS_vs_Population_View;