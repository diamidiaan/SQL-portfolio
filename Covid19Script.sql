/*
COVID19 DATA EXPLORATION
*/



-- Data to be used
select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2



--Breaking down by countries
-----------------------------


--Total cases vs total deaths
--shows the likelihood of dying if you contract covid (in the states)
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--Total cases vs population
-- the percentage of population who contracted covid (in the states)
select location, date, total_cases, population, (total_cases/population)*100 as covidpercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--Countries with the highest infection rate compared to population
select location,population, MAX (total_cases) as Highestinfectioncount  --, Max((total_cases/population))*100 as covid_infectionpercentage
From PortfolioProject..CovidDeaths
Group by location,population



-- Countries with the highest death count per population
select location, MAX (cast(total_deaths as int))as Totaldeathscount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by Totaldeathscount desc



--Breaking down by continent
------------------------------

--Continents with the highest death count per population

select location, MAX (cast(total_deaths as int))as Totaldeathscount 
From PortfolioProject..CovidDeaths
Where continent is null               ---data shows null in continent, and continent in location so 'is null' will return the continents only
Group by location
order by Totaldeathscount desc


--GLOBAL NUMBERS

--- total cases, total deaths and percentage
select  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date 
order by 1, 2

----
select date,  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date 
order by 1, 2



--Total Population vs Vaccinations
-- Percentage of population that has received at least one Covid vaccine
Select  DT.continent, DT.location, DT.date, DT.population, VC.new_vaccinations
, sum(cast(VC.new_vaccinations as numeric)) OVER (Partition by DT.location Order by DT.location, DT.date ) as RollingPeopleVaccinated
From	PortfolioProject..CovidDeaths DT
	JOIN PortfolioProject..CovidVaccination VC
	ON	DT.location = VC.location
	and DT.date = VC.date
Where DT.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVC (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select  DT.continent, DT.location, DT.date, DT.population, VC.new_vaccinations
, sum(cast(VC.new_vaccinations as numeric)) OVER (Partition by DT.location Order by DT.location, DT.date ) as RollingPeopleVaccinated
From	PortfolioProject..CovidDeaths DT
	JOIN PortfolioProject..CovidVaccination VC
	ON	DT.location = VC.location
	and DT.date = VC.date
Where DT.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVC


--Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select  DT.continent, DT.location, DT.date, DT.population, VC.new_vaccinations 
,SUM(CAST(VC.new_vaccinations AS numeric)) OVER (Partition by DT.location Order by DT.location, DT.date ) AS RollingPeopleVaccinated 
From	PortfolioProject..CovidDeaths DT
	JOIN PortfolioProject..CovidVaccination VC
	ON	DT.location = VC.location
	and DT.date = VC.date
Where DT.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select  DT.continent, DT.location, DT.date, DT.population, VC.new_vaccinations
, sum(cast(VC.new_vaccinations as numeric)) OVER (Partition by DT.location Order by DT.location, DT.date ) as RollingPeopleVaccinated
From	PortfolioProject..CovidDeaths DT
	JOIN PortfolioProject..CovidVaccination VC
	ON	DT.location = VC.location
	and DT.date = VC.date
Where DT.continent is not null

Select *
From PercentPopulationVaccinated



--Create View ContinentHighestDeath as
--select location, MAX (cast(total_deaths as int))as Totaldeathscount 
--From PortfolioProject..CovidDeaths
--Where continent is null               ---data shows null in continent, and continent in location so 'is null' will return the continents only
--Group by location
--order by Totaldeathscount desc