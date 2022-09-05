SELECT *
FROM Portfolio..CovidDeaths
Where continent is not null
order by 3,4

SELECT *
FROM Portfolio..CovidVaccinations
order by 3,4
Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From Portfolio..CovidDeaths
WHERE location like '%states%'
Order by 1,2

-- Looking at the Total Cases VS Population
-- Shows percentage of population with covid

Select Location, date, population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
WHERE location like '%Europe%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc

--Showing the countries with the highest death count per Population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(New_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From Portfolio..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated,

FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--USE CTE

	With PopvsVac (Continent, Location, Date, Population, New_vaccionations, Rolling_People_Vaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as Rolling_People_Vaccinated
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)
as Rolling_People_Vaccinated
FROM Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

	Select * 
	from PercentPopulationVaccinated