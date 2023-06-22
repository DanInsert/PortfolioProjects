Select *
FROM [dbo].[CovidDeaths$]
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM [dbo].[CovidVaccinations$]
--ORDER BY 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths$]
Order by 1,2

--Looking at Total Cases Vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercent
FROM [dbo].[CovidDeaths$]
Where location like '%States%'
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM [dbo].[CovidDeaths$]
--Where location like '%States%'
Order by 1,2

--Looking at Countries with Highest infections rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
FROM [dbo].[CovidDeaths$]
--Where location like '%States%'
Group by Location, population
Order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--BREAK THINGS DOWN BY CONTIENTS
--Showing contients with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM
(New_Cases)*100 as DeathPercentage
FROM [dbo].[CovidDeaths$]
--Where location like '%States%'
Where continent is not null
--group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [dbo].[CovidDeaths$] dea
Join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Data, Population, New_Vaccinations, RollingPeopleVaccinated) as 
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
    --,(RollingPeopleVaccinated/Populatiobigint
    From [dbo].[CovidDeaths$] dea
    Join [dbo].[CovidVaccinations$] vac on dea.location = vac.location and dea.date = vac.date
    Where dea.continent is not null
    --Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
    --,(RollingPeopleVaccinated/Populatiobigint
    From [dbo].[CovidDeaths$] dea
    Join [dbo].[CovidVaccinations$] vac on dea.location = vac.location and dea.date = vac.date
  --Where dea.continent is not null
    --Order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as 
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
   --,(RollingPeopleVaccinated/Populatiobigint
  From [dbo].[CovidDeaths$] dea
  Join [dbo].[CovidVaccinations$] vac on dea.location = vac.location and dea.date = vac.date
  Where dea.continent is not null
  --Order by 2,3

  
Select *
FROM PercentPopulationVaccinated