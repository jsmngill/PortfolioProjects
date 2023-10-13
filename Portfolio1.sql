select *
from PortfolioProject1..CovidDeaths$
where continent is not null
order by 3,4
Select *
from PortfolioProject1..CovidVaccinations$
--Selecting the important columns
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths$
where continent is not null
order by 1,2

--Total Cases VS Total Deaths
--Likelihood of dying if you get covid in India 
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths$
where location like '%India%' --Insights for particular country
where continent is not null
order by 1,2

--Total Cases VS Population
--% of population who got Covid
select Location, date, total_cases,population, (total_cases/population)*100 as peoplewithCovid
from PortfolioProject1..CovidDeaths$
--where location like '%India%' --Insights for particular country
where continent is not null
order by 1,2

--Country's with highest infection rate compared with population
select Location,max(total_cases) as HighestInfectionCount,population, Max((total_cases/population))*100 as PopulationInfected
from PortfolioProject1..CovidDeaths$
where continent is not null
group by Location,Population
order by PopulationInfected desc

--Country's with the highest death rates per population
select Location,max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject1..CovidDeaths$
where continent is not null
group by Location
order by HighestDeathCount desc

--Visulasing as Continents 
select location,max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject1..CovidDeaths$
where continent is null
group by location
order by HighestDeathCount desc

--Global Numbers
--NewCases regardless of country name
select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject1..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Overall regardless of dates
select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject1..CovidDeaths$
where continent is not null
order by 1,2
--Total Population VS Vaccination

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--TempTable
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths$ dea
JOIN PortfolioProject1..CovidVaccinations$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


