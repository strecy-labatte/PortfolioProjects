
Select *
From [Portfolio Project]..['covid deaths$']
Where continent is not null
order by 3,4 

--Select *
--From [Portfolio Project]..['covid vaccinations$']
--order by 3,4 

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['covid deaths$']
order by 1,2 

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..['covid deaths$']
where location like '%states%'
order by 1,2 

Select Location, date, total_cases, population,(total_cases/population)*100 as InfectedPopulationPercentage
From [Portfolio Project]..['covid deaths$']
where location like '%states%'
order by 1,2 
--shows what percentage of the population contracted covid

--Examine countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
From [Portfolio Project]..['covid deaths$']
--where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

--Displays countries with the highest death count per population

Select Location, MAX(Total_deaths) as TotalDeathCount 
From [Portfolio Project]..['covid deaths$']
Where continent is not null
Group by Location
order by TotalDeathCount desc

Select location, MAX(Total_deaths) as TotalDeathCount 
From [Portfolio Project]..['covid deaths$']
Where continent is null
Group by location
order by TotalDeathCount desc

--break down by continent
Select continent, MAX(Total_deaths) as TotalDeathCount 
From [Portfolio Project]..['covid deaths$']
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

--refer back to 43,51 of clip

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases) *100 as DeathPercentage
From [Portfolio Project]..['covid deaths$']
--where location like '%states%'
where continent is not null
Group By date 
order by 1,2 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases) *100 as DeathPercentage
From [Portfolio Project]..['covid deaths$']
--where location like '%states%'
where continent is not null
Group By date 
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases) *100 as DeathPercentage
From [Portfolio Project]..['covid deaths$']
--where location like '%states%'
where continent is not null
--Group By date 
order by 1,2 

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['covid deaths$'] dea
Join [Portfolio Project]..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--UTILIZE CTE

With PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['covid deaths$'] dea
Join [Portfolio Project]..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVacc


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['covid deaths$'] dea
Join [Portfolio Project]..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['covid deaths$'] dea
Join [Portfolio Project]..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated