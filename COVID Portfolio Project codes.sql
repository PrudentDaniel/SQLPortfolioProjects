Covid 19 Data Exploration
Skills used: Joins, Aggregate Function, CTEs, Windows Function, Temp tables, Converting Data Types, Creating Views
*/

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--Select Data That We Are Going to Begin With

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2



--Total cases vs Total Deaths

--shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2



--Total cases vs Population

--shows what percentage of population got covid

Select location, date, population, total_cases, (total_deaths/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
order by 1,2


--Countries With Highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


--Countries with highest Death Count Per Population

Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
Group by location, population
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

--Continent with the Highest Deathcounts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- BREAKING GLOBAL NUMBERS (with agg. function)

--GLOBAL AGGREGATE NUMBERS BY DATE

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

--GLOBAL AGGREGATE NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2



--JOINING TWO TABLES TOGETHER

Select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccination
-- Shows the Number of People That Have Received at Least One Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Total Population vs Vaccination (Rolling Count)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- Using CTE to Make Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- Using TEMP TABLE to Make Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated