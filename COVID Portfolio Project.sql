select * 
from PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3, 4

--select * 
--from PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--Data to be used

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

--Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covif in your country

select location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2

--Looking Total Cases vs Population
--Shows what percentage of population got Covid (USA)

select location, date, population, total_cases, 
       (CAST(total_cases AS float)/CAST(population AS float))*100 AS CovidPopulationPercentage
from PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2

--Countries with the highest infection rate compare to population

select location, population, MAX(total_cases) AS HighestInfectionCount, 
       max((CAST(total_cases AS float)/CAST(population AS float)))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--SHowing countries with the highest death count per population

select location, MAX(total_deaths) AS TotalDeathCount 
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
group by location
order by TotalDeathCount desc

--Divide by continent

--Showing continents with the highest death count per population

select continent, MAX(total_deaths) AS TotalDeathCount 
from PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, 
		CASE
			WHEN SUM(cast(new_deaths as float)) = 0 THEN (SUM(cast(new_deaths as float)) / 1) 
			ELSE (SUM(cast(new_deaths as float)) / SUM(new_cases)) * 100 
		END AS DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1, 2

-----------------------------------------------------------
-- Looking at Total Population vs Vaccinations

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(VAC.new_vaccinations) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
Where DEA.continent is not null
ORDER BY 2,3

----USE OF CTE

With PopvsVAC (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(VAC.new_vaccinations) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
Where DEA.continent is not null
)
Select *, (CAST(RollingPeopleVaccinated AS float)/CAST(Population AS float)) * 100
from PopvsVAC

-- Temp Table ----------------------------------------------------------
 
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
NewVaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(VAC.new_vaccinations) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
Where DEA.continent is not null
--ORDER BY 2,3

Select *, (CAST(RollingPeopleVaccinated AS float)/CAST(Population AS float)) * 100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(VAC.new_vaccinations) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
Where DEA.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated