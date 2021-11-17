--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data that we are going to start with 
Select CovidDeaths.location, CovidDeaths.date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths as CovidDeaths 
Join PortfolioProject..CovidVaccinations as CovidVaccinations on CovidDeaths.location=CovidVaccinations.location
Where CovidDeaths.continent is not null

-- Shows the percentage of likelihood of dying if you contracted covid in Venezuela this year 
Select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths 
Where location = 'Venezuela'and date >= '2021-01-01 00:00:00.000' 
Order by 1,2

--Shows the percentaje of infected population in Venezuela this year 
Select CovidDeaths.location, CovidDeaths.date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths as CovidDeaths
Join PortfolioProject..CovidVaccinations as CovidVaccinations on CovidVaccinations.location=CovidDeaths.location
Where CovidDeaths.location = 'Venezuela'and CovidDeaths.date >= '2021-01-01 00:00:00.000'
Order by 1,2

--Shows countries with the highest infection rates compared to their populations 
Select CovidDeaths.location, population, MAX(total_cases) as HighesCasesCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths as CovidDeaths
Join PortfolioProject..CovidVaccinations as CovidVaccinations on CovidVaccinations.location=CovidDeaths.location
Where CovidDeaths.continent is not null 
Group by CovidDeaths.location, population
Order by InfectedPopulationPercentage desc 

-- Shows continents with the highest death rates 
Select location, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc 

-- Global numbers 
Select date, Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int)) as TotalDeaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths 
Where continent is not null  
Group by date 
Order by 1,2

-- Global numbers without date distinction 
Select Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int)) as TotalDeaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths 
Where continent is not null  
Order by 1,2

-- Looking at total population vs vaccinations 
Select Deaths.continent, Deaths.location, Deaths.date, population, Vaccinations.new_vaccinations
From PortfolioProject..CovidDeaths as Deaths
Join PortfolioProject..CovidVaccinations as Vaccinations 
on Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Where Deaths.continent is not null 
Order by 2,3

-- Rolling count of new vaccinations per day in each location 
Select Deaths.continent, Deaths.location, Deaths.date, population, Vaccinations.new_vaccinations
, sum (convert (int, Vaccinations.new_vaccinations)) over (Partition by Deaths.location order by Deaths.location, Deaths.date) as TotalPeopleVaccinated 
From PortfolioProject..CovidDeaths as Deaths
Join PortfolioProject..CovidVaccinations as Vaccinations 
on Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
Where Deaths.continent is not null 
Order by 2,3

-- Looking at population vs people vaccinated rolling count 

Drop table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(Continent nvarchar (255), 
Location nvarchar (255),
Date datetime , 
Population numeric, 
New_Vaccinations numeric,
TotalPeopleVaccinated  numeric
)

Insert into #PercentPeopleVaccinated
Select Deaths.continent, Deaths.location, Deaths.date, population, Vaccinations.new_vaccinations
, sum (convert (bigint, Vaccinations.new_vaccinations)) over (Partition by Deaths.location order by Deaths.location, Deaths.date) as TotalPeopleVaccinated  
From PortfolioProject..CovidDeaths as Deaths
Join PortfolioProject..CovidVaccinations as Vaccinations 
on Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
where  Deaths.continent is not null 
 Select *, (TotalPeopleVaccinated/population)*100
 From #PercentPeopleVaccinated


 -- Creating View to store data for later visualizations

create view PercentPeopleVaccinated as 
Select Deaths.continent, Deaths.location, Deaths.date, population, Vaccinations.new_vaccinations
, sum (convert (bigint, Vaccinations.new_vaccinations)) over (Partition by Deaths.location order by Deaths.location, Deaths.date) as TotalPeopleVaccinated  
From PortfolioProject..CovidDeaths as Deaths
Join PortfolioProject..CovidVaccinations as Vaccinations 
on Deaths.location = Vaccinations.location
and Deaths.date = Vaccinations.date
where  Deaths.continent is not null 

 