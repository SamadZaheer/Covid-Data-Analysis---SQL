-- Creating tables to import csv files for the COVID data

CREATE TABLE CovidVaccinations (
    iso_code TEXT,
    continent TEXT,
    location TEXT,
    date DATE,
    new_tests NUMERIC,
    total_tests NUMERIC,
    total_tests_per_thousand NUMERIC,
    new_tests_per_thousand NUMERIC,
    new_tests_smoothed NUMERIC,
    new_tests_smoothed_per_thousand NUMERIC,
    positive_rate NUMERIC,
    tests_per_case NUMERIC,
    tests_units TEXT,
    total_vaccinations NUMERIC,
    people_vaccinated NUMERIC,
    people_fully_vaccinated NUMERIC,
    new_vaccinations NUMERIC,
    new_vaccinations_smoothed NUMERIC,
    total_vaccinations_per_hundred NUMERIC,
    people_vaccinated_per_hundred NUMERIC,
    people_fully_vaccinated_per_hundred NUMERIC,
    new_vaccinations_smoothed_per_million NUMERIC,
    stringency_index NUMERIC,
    population_density NUMERIC,
    median_age NUMERIC,
    aged_65_older NUMERIC,
    aged_70_older NUMERIC,
    gdp_per_capita NUMERIC,
    extreme_poverty NUMERIC,
    cardiovasc_death_rate NUMERIC,
    diabetes_prevalence NUMERIC,
    female_smokers NUMERIC,
    male_smokers NUMERIC,
    handwashing_facilities NUMERIC,
    hospital_beds_per_thousand NUMERIC,
    life_expectancy NUMERIC,
    human_development_index NUMERIC
);

CREATE TABLE CovidDeaths (
    iso_code TEXT,
    continent TEXT,
    location TEXT,
    date DATE,
    population NUMERIC,
    total_cases NUMERIC,
    new_cases NUMERIC,
    new_cases_smoothed NUMERIC,
    total_deaths NUMERIC,
    new_deaths NUMERIC,
    new_deaths_smoothed NUMERIC,
    total_cases_per_million NUMERIC,
    new_cases_per_million NUMERIC,
    new_cases_smoothed_per_million NUMERIC,
    total_deaths_per_million NUMERIC,
    new_deaths_per_million NUMERIC,
    new_deaths_smoothed_per_million NUMERIC,
    reproduction_rate NUMERIC,
    icu_patients NUMERIC,
    icu_patients_per_million NUMERIC,
    hosp_patients NUMERIC,
    hosp_patients_per_million NUMERIC,
    weekly_icu_admissions NUMERIC,
    weekly_icu_admissions_per_million NUMERIC,
    weekly_hosp_admissions NUMERIC,
    weekly_hosp_admissions_per_million NUMERIC
);

SELECT * FROM coviddeaths
ORDER BY 3,4
LIMIT 10;

SELECT * FROM covidvaccinations
ORDER BY 3,4
LIMIT 10;

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM coviddeaths
ORDER BY 1,2;

-- Total Cases Vs Total Deaths
-- Likelihood of dying if you contract COVID
SELECT location, date, total_cases, total_deaths, 
ROUND((total_deaths/total_cases)*100,2) || '%' AS death_percentage
FROM coviddeaths
WHERE location = 'India'
ORDER BY 1,2;

-- Total Cases Vs Population
-- Percentage of population who got COVID
SELECT location, date, population, total_cases,
ROUND((total_cases/population)*100,2) || '%' AS positive_percentage
FROM coviddeaths
WHERE location = 'India'
ORDER BY 1,2;

-- Countries with highest infection rate wrt population
SELECT location, population, MAX(total_cases) AS highest_count,
ROUND(MAX((total_cases/population)*100),2) AS positive_percentage
FROM coviddeaths
GROUP BY location, population
ORDER BY positive_percentage DESC;

-- Countries with highest death count
SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Continents with highest death count
SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Global Numbers
-- Cases Vs Deaths
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

-- Total Cases Vs Death Percentage
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) || '%' AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL;

-- Analysing total population vs vaccinations, using rolling sum of new_vaccinatons over location
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_sum_vaccinations
FROM coviddeaths AS d
JOIN covidvaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- Creating Temporary Table
DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TABLE percent_population_vaccinated
(continent VARCHAR(50),
 location VARCHAR(100),
 date DATE,
 population NUMERIC,
 new_vaccinations NUMERIC,
 rolling_sum_vaccinations NUMERIC
);

INSERT INTO percent_population_vaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_sum_vaccinations
FROM coviddeaths AS d
JOIN covidvaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT *, ROUND((rolling_sum_vaccinations/population)*100,2) AS vacciantion_percentage
FROM percent_population_vaccinated;

-- Creating VIEW for visualisation
CREATE VIEW population_vaccinated
AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_sum_vaccinations
FROM coviddeaths AS d
JOIN covidvaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT * FROM population_vaccinated;




