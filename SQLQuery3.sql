Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject.dbo.CovidVaccinations$
--Order by 3, 4

--Select data that we will use
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Order by 1, 2

--Looking at Total_cases vs Total_deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%United_Kingdom%' and continent is not null
Order by 1, 2

--Looking at Total_cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%United_Kingdom%'
Where continent is not null
Order by 1, 2

--Looking at Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%United_Kingdom%'
Where continent is not null
Group by location, population
Order by PercentagePopulationInfected desc

--Showing Countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
--Where location like '%United_Kingdom%'
Group by location
Order by TotalDeathCount desc


--Breakdown by Continents
--Showing Continents with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
Where continent is not Null
--Where location like '%United_Kingdom%'
Group by continent
Order by TotalDeathCount desc


--Global Numbers (Global death percentage)
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%United_Kingdom%' 
Where continent is not null
--Group by date
Order by 1, 2

--Looking at Total Population vs Vaccination
--Joining CovidDeaths and CovidVaccination tables
Select *
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location=vac.location 
	and dea.date=vac.date

--Cumulative number of people vaccinated by country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE (Alternate method of computing cumulative number of vaccinated peiople by country)
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location=vac.location 
	and dea.date=vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store Data for later visualisation
Create View PercentPopulationVaccinated4 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select*
From PercentPopulationVaccinated

