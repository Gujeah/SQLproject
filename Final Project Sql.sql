select *
from Project.. Covid1
order by 3,4
--select *
--from Project.. Vaccine
--order by 3,4

select location, date,total_cases,new_cases,total_deaths, population
from Project.. Covid1
order by 1,2
---Sum of total death and total cases
create view Sum_of_total_deaths_and_total_cases as
select sum(cast(isnull(total_cases, 0) as bigint)) as TotalCases, sum(cast(isnull(total_deaths, 0) as bigint)) as TotalDeaths
from Project..Covid1
--order by 1, 2;
select * from Sum_of_total_deaths_and_total_cases
----Looking at Total cases VS total deaths in Malawi

select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project.. Covid1
where location like '%malawi%'
order by 1,2
--Total cases VS population(the Percentage of Population that god Covid)
select location, date,total_cases,population, (total_cases/population)*100 as DeathPercentage
from Project.. Covid1
where location like '%malawi%' and continent is not null
order by 1,2
---Countries with the heighest infection rate overall
select location, population,max(total_cases) as maxmumcases, max((total_cases/population))*100 as DeathPercentageInfected
from Project.. Covid1
where continent is not null
group by location,population
order by DeathPercentageInfected desc
---showing countries with hieghest death count per population(is null include all parameters found in the dataset)
create view Countries_with_high_death_count as
select location, max(cast(total_deaths as int)) as TotalDeaths
from Project.. Covid1
where continent is  null
group by location
select * from Countries_with_high_death_count
order by TotalDeaths desc

-----Analysing by continent----------
select continent, max(cast(total_deaths as int)) as TotalDeaths
from Project.. Covid1
where continent is not null
group by continent
order by TotalDeaths desc
----Showing the continent with the highest death count-
create view continent_high_death as
select continent, max(cast (Total_deaths as int)) as TotalDeaths
from Project..Covid1
where continent is not null
group by continent
select* from continent_high_death
order by TotalDeaths desc
-----Global numbers of the new cases and new death on that particular date-------
select sum(new_cases) NewCases, sum(cast(new_deaths as int)) NewDeaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) DeathPercentage
from Project..Covid1
where continent is not null
--group by date
order by 1,2
------Looking at total population versus vaccinations
select* 
from project .. vaccine Vacc
-----------
--Using CTEs--------
with popvsvacc (continent, location,date,population,new_vaccinations,PeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(bigint, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as PeopleVaccinated
from Project ..Covid1 dea
join project .. vaccine Vacc
on dea.location=vacc.location
where dea.continent is not null
--order by 1,2
)
select *, (PeopleVaccinated/population)*100 as Peecentage
from popvsvacc
---Working with temp tables----
Drop table if exists #PercentageVaccine
create table #PercentageVaccine
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)
insert into #PercentageVaccine
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(bigint, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as PeopleVaccinated
from Project ..Covid1 dea
join project .. vaccine Vacc
on dea.location=vacc.location
where dea.continent is not null
--order by 1,2

select *, (PeopleVaccinated/population)*100 as Peecentage
from #PercentageVaccine

-----Creating views to store data for future use in tableau---
create view Percentagevacc as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(bigint, vacc.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as PeopleVaccinated
from Project ..Covid1 dea
join project .. vaccine Vacc
on dea.location=vacc.location
where dea.continent is not null

select * from Percentagevacc