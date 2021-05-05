SELECT * FROM PortfolioProject..[Covid Deaths]
where continent is not null
order by 3,4;
--SELECT * FROM PortfolioProject..['Covid Vaccinations'] order by 3,4

--Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..[Covid Deaths]
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--shows likelihood of dying if you get infected by covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
where Location='Belgium'
and continent is not null
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..[Covid Deaths]
--where Location='Belgium'
order by 1,2

--Looking at Countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..[Covid Deaths]
--where Location='Belgium'
group by Location, Population 
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
--where Location='Belgium'
where continent is not null
group by Location, Population 
order by TotalDeathCount desc


--Let's break things down by continent


--Showing continents with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
--where Location='Belgium'
where continent is null
group by location
order by TotalDeathCount desc


--Global numbers per day
SELECT Date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
--where Location='Belgium'
where continent is not null
group by date
order by 1,2

--Global numbers total
SELECT SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
--where Location='Belgium'
where continent is not null
--group by date
order by 1,2


--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Use Temp Table

--DROP table if exists #PercentPeopleVaccinated
CREATE Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPeopleVaccinated


--Creating view to store data for later visualizations

CREATE view PercentPeopleVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * 
FROM PercentPeopleVaccinated