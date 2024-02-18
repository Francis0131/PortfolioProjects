select * 
from dbo.CovidDeaths
where continent is not null
order by 3,4

-- select * 
-- from dbo.CovidVaccinations

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%states%'
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%states%'
order by 1, 2


-- Looking at countries with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPopulationPercentage
from dbo.CovidDeaths
--where location like '%states%'
group by location, population
order by InfectedPopulationPercentage desc


-- Showing countries with the highest Death Count per Population

select location,Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Breaking it down by Continent


--Showing the continents with highest death count

select continent, max(cast(total_deaths as int))as TotalDeathCount
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers


-- Death percentage around the world

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as
	DeathPercentage
from dbo.CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2

-- Looking at Total Population vs Vaccination
-- Use CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3  
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac




-- Temp Table


Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
lovation nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3  

select *, (RollingPeopleVaccinated/population)*100
from  #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3  


select * 
from PercentPopulationVaccinated