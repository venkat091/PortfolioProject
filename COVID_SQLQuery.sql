SELECT location, date, population, total_cases, new_cases, total_deaths
FROM Portfolio.[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Death Percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio.[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Death Percentages in India, likelihood of dying if you are infected with coronovirus
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio.[dbo].[CovidDeaths]
WHERE location like '%India%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Percentages of population infected with coronovirus
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM Portfolio.[dbo].[CovidDeaths]
WHERE location like '%India%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentagePopulationInfected
FROM Portfolio.[dbo].[CovidDeaths]
-- WHERE location like '%India%' AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- showing countries with highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio.[dbo].[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BY Continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio.[dbo].[CovidDeaths]
WHERE continent IS NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio.[dbo].[CovidDeaths]
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global deaths
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
             (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM Portfolio.[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
-- Group BY date
ORDER BY 1, 2

-- Total poplation vs vaccinations
-- Using CTE
WITH PopulationVaccinated (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
		SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location order by CD.location, CD.date) as PeopleVaccinated
From Portfolio..CovidDeaths as CD
Join Portfolio..CovidVaccinations as CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
-- order by 2, 3
)
select *, (PeopleVaccinated/population)*100 as PercentofPeopleVaccinated
From PopulationVaccinated

-- Temp Table
Drop Table if exists PercentofPopuationVacinated
Create Table PercentofPopuationVacinated
(
continent nvarchar(225), location nvarchar(225), date datetime, population numeric, new_vaccinations numeric, PeopleVaccinated numeric
)
Insert into PercentofPopuationVacinated
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
		SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location order by CD.location, CD.date) as PeopleVaccinated
From Portfolio..CovidDeaths as CD
Join Portfolio..CovidVaccinations as CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
-- order by 2, 3

select *, (PeopleVaccinated/population)*100 as PercentVaccinated
From PercentofPopuationVacinated

-- Creaating view to store data for later viualization
CREATE VIEW VaccinationPercentage as
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
		SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location order by CD.location, CD.date) as PeopleVaccinated
From Portfolio..CovidDeaths as CD
Join Portfolio..CovidVaccinations as CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
