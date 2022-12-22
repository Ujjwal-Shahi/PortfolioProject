Select * 
 From PortfolioProject..CovidDeaths$
 Where continent is not null
 order by 3,4

 --Select * 
 --From PortfolioProject..CovidVaccinations$
 --order by 3,4

 --Select Data that we are going to be using

 Select location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths$
  Where continent is not null
 order by 1,2

 --Looking at Total Cases vs Total Deaths
 -- Shows likelihood of dying if you contract covud in your country

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
 From PortfolioProject..CovidDeaths$
 Where location like '%india%'
 and continent is not null
 order by 1,2

 --Looking at Total Cases vs Population
 --Shows what percentage  of population got Covid


  Select location, date,population, total_cases, (total_cases/population)*100 as PercentPopulation
 From PortfolioProject..CovidDeaths$
 --Where location like '%india%'
  Where continent is not null
 order by 1,2

 -- Looking Counntries with Highest Inection Rate compared to Population

   Select location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeaths$
 --Where location like '%india%'
  Where continent is not null
 Group by location,population
 order by PercentPopulationInfected desc

 -- Showing Countries with Highest Death count per population

 Select location, Max(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths$
 --Where location like '%india%'
  Where continent is not null
 Group by location
 order by TotalDeathCount desc

 --LET'S BREAK THINGS DOWN BY CONTINENT


 --Showing continents with highest death count per population
 Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths$
 --Where location like '%india%'
 Where continent is not null
 Group by continent
 order by TotalDeathCount desc

 --GOBAL NUMBERS

 Select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
 From PortfolioProject..CovidDeaths$
 --Where location like '%india%'
 where continent is not null
 Group by date
 order by 1,2

  Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
 From PortfolioProject..CovidDeaths$
 --Where location like '%india%'
 where continent is not null
 --Group by date
 order by 1,2

 --Looking at total Population vs Vaccinations

 --CTE

 With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
     and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #percentPopulationVaccinated

--Creating View to store data for later visualizations


Create View percentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From percentPopulationVaccinated