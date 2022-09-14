SELECT * FROM COVID..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT * FROM COVID..CovidVacinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID..CovidDeaths
order by 1,2


--Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM COVID..CovidDeaths
WHERE location = 'India'
order by 1,2


-- Looking ar total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM COVID..CovidDeaths
WHERE location = 'India'
order by 1,2


--Looking at countries with highest infection rates compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM COVID..CovidDeaths
GROUP BY location, population
order by PercentPopulationInfected desc


--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM COVID..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc


--showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM COVID..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc


--global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM COVID..CovidDeaths
where continent is not null
--GROUP BY date
order by 1,2


--Looking total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVID..CovidDeaths dea
JOIN COVID..CovidVacinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With cte as (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVID..CovidDeaths dea
JOIN COVID..CovidVacinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)

SELECT *, (RollingPeopleVaccinated/population)*100 as z
FROM cte



--create view to store data for visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM COVID..CovidDeaths dea
JOIN COVID..CovidVacinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

