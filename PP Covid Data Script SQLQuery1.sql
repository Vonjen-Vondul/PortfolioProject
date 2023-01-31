Select *
From ProjectPortfolio..CovidDeaths
order by 3,4

--Select *
--From ProjectPortfolio..CovidVaccinations
--order by 3,4

Select location,date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
order by 1,2

--looking at total cases vs total deaths --
--showing likelihood of dying if you contract covid in Nigeria 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
WHERE LOCATION LIKE '%Nigeria%'
order by 1,2	

--looking at the total cases vs Population--
--showing percentage of population that got covid in Nigeria 

Select location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
WHERE LOCATION LIKE '%Nigeria%'
order by 1,2


--looking at countries with highest infextion rate compared to population--

Select Location, population, max(total_cases) as HigestInfectionCount, max((total_deaths/population))*100 as 
PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--WHERE LOCATION LIKE '%Nigeria%'
group by Location, Population 
order by PercentPopulationInfected desc

-- showing the countries with the highest death count per population--

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--WHERE LOCATION LIKE '%Nigeria%'
where continent is not null
group by Location 
order by TotalDeathCount desc


-- breaking things down by continent--
--shoowing the continents with the deathcount per population--

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--WHERE LOCATION LIKE '%Nigeria%'
where continent is not null
group by continent 
order by TotalDeathCount desc

--global numbers--

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)as deaathPercentage
From ProjectPortfolio..CovidDeaths
--WHERE LOCATION LIKE '%Nigeria%'
where continent is not null
group by date
order by 1,2	


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)as deaathPercentage
From ProjectPortfolio..CovidDeaths
--WHERE LOCATION LIKE '%Nigeria%'
where continent is not null
--group by date
order by 1,2	


--joining the deaths and vaccinations--

select * from ProjectPortfolio..CovidDeaths as Dea
join ProjectPortfolio..CovidVaccinations as Vac
on Dea.location = Vac.location
and Dea.date = Vac.date

--loooking at total population vs Vaccinations--

select Dea.continent,Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
from ProjectPortfolio..CovidVaccinations as Vac
join ProjectPortfolio..CovidDeaths as Dea
	on Dea.location = Vac.location
	and Dea.date= Vac.date
where Dea.continent is not null
order by 1,2,3

--rolling vaccinations--

select Dea.continent,Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum(convert(int,Vac.new_vaccinations)) over (partition by Dea.location order by Dea.location,Dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidVaccinations as Vac
join ProjectPortfolio..CovidDeaths as Dea
	on Dea.location = Vac.location
	and Dea.date= Vac.date
where Dea.continent is not null
order by 1,2,3


--use a CTE--

with popvsVac (Continent,location, date, population, new_vaccinations,RollingPeopleVaccinated)
as (
select Dea.continent,Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum(convert(int,Vac.new_vaccinations)) over (partition by Dea.location order by Dea.location,Dea.date) as RollingPeopleVaccinated
--, max(RollingPeopleVaccinated)/population)*100
from ProjectPortfolio..CovidVaccinations as Vac
join ProjectPortfolio..CovidDeaths as Dea
	on Dea.location = Vac.location
	and Dea.date= Vac.date
where Dea.continent is not null
--order by 1,2,3
)

select *, (RollingPeopleVaccinated/population)*100
from popvsVac


--temp table--

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum(convert(int,Vac.new_vaccinations)) over (partition by Dea.location order by Dea.location,
Dea.date) as RollingPeopleVaccinated
--,max(RollingPeopleVaccinated)/population)*100
from ProjectPortfolio..CovidVaccinations as Vac
join ProjectPortfolio..CovidDeaths as Dea
	on Dea.location = Vac.location
	and Dea.date= Vac.date
--where Dea.continent is not null
--order by 1,2,3

select (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store later--

create view PercentPopulationVaccinated as
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum(convert(int,Vac.new_vaccinations)) over (partition by Dea.location order by Dea.location,
Dea.date) as RollingPeopleVaccinated
--,max(RollingPeopleVaccinated)/population)*100
from ProjectPortfolio..CovidVaccinations as Vac
join ProjectPortfolio..CovidDeaths as Dea
	on Dea.location = Vac.location
	and Dea.date= Vac.date
where Dea.continent is not null
--order by 1,2,3

select * from PercentPopulationVaccinated