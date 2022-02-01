select *
from coviddeaths
where continent is not null
order by 3,4

--select *
--from covidvaccinations
--order by 3,4

--select data that we are going to use

select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
where location= 'germany' and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as percentpopulationinfected
from coviddeaths
where continent is not null
----where location= 'germany'
order by 1,2


--looking at countries with highest infection rate  compared to population

select location,population,max(total_cases) as highestinfectioncount,max(total_cases/population)*100 as percentpopulationinfected
from coviddeaths
where continent is not null
----where location= 'germany'
group by location,population
order by percentpopulationinfected desc

--showing contries with highest death count per population

select location,max(cast(total_deaths as int)) as highestdeathcounts
from PortfolioProject..coviddeaths
where continent is not null
group by location
order by highestdeathcounts desc

--lets break things down by continent

--showing continents with highestdeathcount per population


select continent,max(cast(total_deaths as int)) as highestdeathcounts
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by highestdeathcounts desc

----global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
--total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
----where location= 'germany'
where continent is not null
--group by date
order by 1,2 

--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location)
as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--using cte

with popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location)
as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac


--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location)
as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
--order by 2,3

select * 
from #percentpopulationvaccinated

--creating views to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location)
as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3