use PortfolioProject

-- Looking at Total Cases vs Total Deaths in the United States
-- Also shows likelihood of death if infected
select location, date, total_cases, total_deaths, (cast (total_deaths as float)/total_cases) * 100 as deathPercentage
from PortfolioProject..covidDeaths
where location = 'United States'
order by 1,2

-- Looking at Total Cases vs Population in the United States
-- Shows what percentage of population got Covid
select location, date,population, total_cases,  total_deaths, (cast (total_cases as float)/population) * 100 as infectedByPopulation
from PortfolioProject..covidDeaths
where location = 'United States'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date,population, total_cases,  total_deaths, (cast (total_cases as float)/population) * 100 as infectedByPopulation
from PortfolioProject..covidDeaths
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast (total_cases as float)/population)) * 100 as infectedByPopulation
from PortfolioProject..covidDeaths
group by location, population
order by infectedByPopulation desc

-- Showing Countries Death Count
select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing Continents Death Count (Right Way)
select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Showind Continents Death Count (Inaccurate Numbers)
select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Join
select * from
	PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs New Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Rolling Count of New Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) 
	OVER 
	(Partition by dea.location order by dea.location,dea.date) as RollingVaccinations	
from PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE
with PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) 
	OVER 
	(Partition by dea.location order by dea.location,dea.date) as RollingVaccinations	
from PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
select *, (RollingVaccinations/cast(population as float)) * 100
from PopVsVac


