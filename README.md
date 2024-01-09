# Coronavirus (COVID-19)


## Overview

This repository contains data and code for exploring COVID-19 trends in Egypt. The purpose of this project is to analyze
and visualize relevant data to gain insights into the impact of the coronavirus in Egypt.


## Data Source

- [Our World In Data (OWID)](https://ourworldindata.org/coronavirus): The OWID provides global COVID-19 data, including information specific to Egypt.
- Unfortunately the excel files are too big for github to upload

## File Structure

- `Query Output For Visualization/`: MS SQL query output as Excel to use in tableau.
- `Visualizations/`: Output directory for saving visualizations generated during exploration.


## Data Exploration

The `Query.sql` file contains SQL queries that explore various aspects of COVID-19 data in and outside of Egypt.
Feel free to run the file and modify it to suit your specific analysis requirements.

Certainly! Let's go through each of the SQL queries to understand their purpose:

### Query 1:

```sql
SELECT
	location,
	MAX(new_cases) AS MAX_Deaths
FROM 
	CovidDeaths2023
WHERE
	continent IS NULL
	AND location IN ('High income','Upper middle income','Low income','Lower middle income')
GROUP BY
	location;
```

**Explanation:**
- **Objective:** Find the maximum number of new cases (MAX_Deaths) for each specified income level category in countries where the continent information is missing.
- **Columns Selected:**
  - `location`: Country name or income level category.
  - `MAX_Deaths`: Maximum number of new cases in each category.
- **Filter Conditions:**
  - `continent IS NULL`: Only consider records where the continent information is not available.
  - `location IN ('High income','Upper middle income','Low income','Lower middle income')`: Filter records for specific income levels.
- **Grouping:**
  - `GROUP BY location`: Group the results by the 'location' (country or income level category).

### Query 2:

```sql
SELECT 
	MAX(new_cases) AS Total_New_Cases,
	MAX(new_cases) AS Total_New_Deaths,
	ROUND(MAX(CAST(new_deaths AS FLOAT))/MAX(CAST(new_cases AS FLOAT))*100, 2) AS Death_Percentage_of_Cases 
FROM 
	CovidDeaths2023
WHERE 
	location = 'Egypt'
ORDER BY 
	1, 2;
```

**Explanation:**
- **Objective:** Calculate various statistics related to COVID-19 cases and deaths for Egypt.
- **Columns Selected:**
  - `Total_New_Cases`: Maximum number of new cases in Egypt.
  - `Total_New_Deaths`: Maximum number of new deaths in Egypt.
  - `Death_Percentage_of_Cases`: Calculate the percentage of deaths among cases, rounded to two decimal places.
- **Filter Conditions:**
  - `location = 'Egypt'`: Only consider records for Egypt.
- **Ordering:**
  - `ORDER BY 1, 2`: Order the results by the first and second columns (Total_New_Cases and Total_New_Deaths).

### Query 3:

```sql
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
```

**Explanation:**
- **Objective:** Retrieve data on new cases, new deaths, and new vaccinations for Egypt, joining data from two tables.
- **Columns Selected:**
  - `date`: Date of the data.
  - `new_cases`: Number of new COVID-19 cases.
  - `new_deaths`: Number of new deaths.
  - `new_vaccinations`: Number of new vaccinations.
- **Tables Joined:**
  - `CovidDeaths2023 D` and `CovidVaccinations2023 V` are joined on location and date.
- **Filter Conditions:**
  - `D.location = 'Egypt'`: Only consider records for Egypt.
  - `new_cases IS NOT NULL`: Exclude records where the number of new cases is missing.
- **Ordering:**
  - `ORDER BY 1, 2`: Order the results by date and the number of new cases.

### Query 4:

```sql
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
ORDER BY 
	2;
```

**Explanation:**
- **Objective:** Retrieve data on total cases, total deaths, and calculate the percentage of deaths among total cases for Egypt.
- **Columns Selected:**
  - `location`: Country name.
  - `date`: Date of the data.
  - `total_cases`: Total number of COVID-19 cases.
  - `total_deaths`: Total number of deaths.
  - `Death_Percentage_of_Cases`: Percentage of deaths among total cases, rounded to two decimal places.
- **Filter Conditions:**
  - `location = 'Egypt'`: Only consider records for Egypt.
  - `total_deaths IS NOT NULL`: Exclude records where the total number of deaths is missing.
- **Ordering:**
  - `ORDER BY 2`: Order the results by date.

### Query 5:

```sql
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
```

**Explanation:**
- **Objective:** Find the country with the highest infection count, along with related population statistics.
- **Columns Selected:**
  - `location`: Country name.
  - `Highest_Infection_Count`: Maximum total number of COVID-19 cases in a country.
  - `population`: Total population of the country.
  - `'Infected Percentage of the Population'`: Percentage of the population infected, rounded to two decimal places.
- **Filter Conditions:**
  - `continent IS NOT NULL`: Exclude records where the continent information is missing.
- **Grouping:**
  - `GROUP BY location, population`: Group the results by location and population.
- **Ordering:**
  - `ORDER BY 'Infected Percentage of the Population' DESC`: Order the results by the infected percentage of the population in descending order.

## Visualizations

Visualizations generated after the data exploration process can be found in the `Visualizations/` directory.

![DASHBOARD](Visualizations/Dashboard.png)

Our initial visualization offers a global perspective, thanks to OWID's categorization of countries into four income classes: 'High Income Countries,' 'High Middle Income Countries,' 'Low Middle Income Countries,' and 'Low Income Countries.' The visualization highlights that 'High Middle Income Countries' exhibit the highest number of deaths compared to other countries. This trend could be attributed to the economic fragility of these nations. Despite having sufficient resources to attract tourists (an unfavorable condition at the onset of the COVID-19 pandemic), they may lack the financial means to establish a robust healthcare system capable of withstanding crises such as the one posed by COVID-19.

![Viz1](/Visualizations/1.png)

In the second visualization, we observe the increasing trend of total new cases and total new deaths in Egypt. This upward trajectory continues until a plateau is reached between late April and early May 2023, where the data stabilizes at a maximum of 516,023 total cases and 24,830 new deaths, representing a mortality rate of 4.81% among the infected individuals.

![Viz2](/Visualizations/2.png)

The third visualization depicts the weekly fluctuations in new cases and new deaths in Egypt. Although the numerical values differ significantly, the underlying pattern remains consistent. The visualization also includes a reference line indicating the commencement of vaccinations in Egypt around January 24, 2021, according to [Ahram Online](https://english.ahram.org.eg/NewsContent/1/64/404860/Egypt/Politics-/Egypts-coronavirus-vaccination-campaign-A-timeline.aspx#:~:text=a%20satellite%20channel.-,24%20January,-Ahmed%20Hemdan%20is). Unfortunately, the dataset lacks week-by-week vaccination records, displaying only two spikes: one on May 23, 2021, with 84,223 new vaccinations and another on May 15, 2022, with 78,722 new vaccinations, suggesting irregular updates.

![Viz3](/Visualizations/3.png)

The final visualization returns to the global scale, presenting a map of the Middle East and Europe. It compares the infection rates of each country relative to its population. San Marino, the mountainous microstate surrounded by north-central Italy, stands out with the highest infection rate relative to its population, reaching 75%.

![Viz5](/Visualizations/4.png)


## Contributing

If you find issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

## Citation

Edouard Mathieu, Hannah Ritchie, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino, Joe Hasell, Bobbie Macdonald, Saloni Dattani, Diana Beltekian, Esteban Ortiz-Ospina and Max Roser (2020) - "Coronavirus Pandemic (COVID-19)". Published online at OurWorldInData.org. Retrieved from: [Online Resource](https://ourworldindata.org/coronavirus)
