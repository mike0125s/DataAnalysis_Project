select Location, date , total_cases, new_cases, total_deaths, population
from Project..CovidDeaths$
order by 1,2


-- Total Cases Vs Total Deaths
--shows likelihood of dying if you contract covid in your country

select Location, date , total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percantage
from Project..CovidDeaths$
where Location = 'India'
and continent is not null
order by 1,2



-- Total Cases  Vs Populaton
-- Shows what percentage of population got infected

select Location, date ,Population , total_cases, (total_cases/Population)*100 as Infected_Percantage
from Project..CovidDeaths$
where Location = 'India'
order by 1,2


--Countries with highest infection rate compared to population

select Location,Population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/Population)*100 as Infected_Percantage
from Project..CovidDeaths$
--where Location = 'India'
Group by Location,Population
order by Infected_Percantage desc



--Countries with the highest death count per population

select Location, MAX(cast(total_deaths as int)) as Highest_Deaths_Count
from Project..CovidDeaths$
--where Location = 'India'
Where continent is not null
Group by Location,Population
order by Highest_Deaths_Count desc


-- Breaking things down by Continent

select continent, MAX(cast(total_deaths as int)) as Highest_Deaths_Count
from Project..CovidDeaths$
--where Location = 'India'
Where continent is not null
Group by continent
order by Highest_Deaths_Count desc



-- Global Numbers

select  date , SUM(new_cases) as Total_Cases , SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percent_Global
from Project..CovidDeaths$
where continent is not null
Group by date
order by 1,2


-- Total Population Vs Vaccination 
-- Percentage of Population that has recived atleast one vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated

From Project..CovidDeaths$ dea
Join Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths$ dea
Join Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths$ dea
Join Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





--Creating View to store data 

CREATE  VIEW Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths$ dea
Join Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


select * from PercentPopulationVaccinated

























