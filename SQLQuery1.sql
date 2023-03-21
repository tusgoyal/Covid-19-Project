--Loading the data from both tables

select * from dbo.covid_deaths order by 3,4
select * from dbo.covid_vaccinations order by 3,4

--selecting the data that we are going to use for future purpose

select location, date , total_cases, new_cases, total_deaths, population
from dbo.covid_deaths
order by 1,2

--We are going to compare total cases Vs total deaths for all countries

select location, date , total_cases, total_deaths , (total_deaths/total_cases) *100 as 'Death Percentage'
from dbo.covid_deaths
order by 1,2

-- Let us look at the data of total cases vs total deaths in India
--Another important insight from this data is it will show likelihood of dying if you contract covid in India

select location, date , total_cases, total_deaths , round(total_deaths/total_cases,3)*100 as 'Death %'
from dbo.covid_deaths
where location = 'India'
order by 1,2

--Let's us compare the Total Cases vs population in India 
--It will also give you the percentage of population who got covid in a particular date

select continent,location, date , population ,total_cases , round(total_cases/population,3)*100 as '% population Infected'
from dbo.covid_deaths
where location = 'India'
order by 1,2

--Let us check the countries highest infection rate with respect to their population

select location,  population ,max(total_cases) as 'Highest Infection rate', max(round(total_cases/population,4))*100 
as '% Population Infected'
from dbo.covid_deaths
where location not in 
('Upper middle income',
'Lower middle income',
'Low income',
'High income') and 
continent is not null
group by location ,population 
order by '% Population Infected' desc


--Now we are going to check what is the highest death count per population per country

select location , max(cast(total_deaths as int)) as 'Total Deaths'
from dbo.covid_deaths
where location not in 
('Upper middle income',
'Lower middle income',
'Low income',
'High income') and
continent is not null
group by location
order by 'Total Deaths' desc

--Now we are going to check the same highest death count as before but this time per continent

select continent , max(cast(total_deaths as int)) as 'Total Deaths'
from dbo.covid_deaths
where location not in 
('Upper middle income',
'Lower middle income',
'Low income',
'High income') and
continent is not null
group by continent
order by 'Total Deaths' desc

-- Let's check out the total number of new cases found on each day around the world

select date , sum(new_cases) as 'Numof_newcases' --, total_deaths , round(total_deaths/total_cases,3)*100 as 'Death %'
from dbo.covid_deaths
--where location = 'India'
where continent is not null
group by date 
order by 1

--Also in addition let us also check the new number of deaths on each day

select date , sum(new_cases) as 'Numof_newCases' , sum(new_deaths) as 'Numof_newDeaths'
from dbo.covid_deaths
--where location = 'India'
where continent is not null
group by date 
order by 1

--Let us add one more column and find death percentage on each day around the world

select date , sum(new_cases) as 'Numof_newCases' , sum(new_deaths) as 'Numof_newDeaths',
sum(new_deaths)/sum(new_cases) *100 as 'Death %'
from dbo.covid_deaths
where continent is not null
group by date 
order by 1

--Final Number

select sum(new_cases) as 'Numof_newCases' , sum(new_deaths) as 'Numof_newDeaths',
sum(new_deaths)/sum(new_cases) *100 as 'Death %'
from dbo.covid_deaths
where continent is not null
--group by date 
order by 1

--Looking at Total population vs vaccinations

select * from dbo.covid_deaths dth
join dbo.covid_vaccinations vcn
on dth.location = vcn.location 
and dth.date = vcn.date
where dth.continent is not null

--Checking the new vaccinations done 

select dth.continent , dth.location , dth.date , dth.population , 
vcn.new_vaccinations ,sum(convert(int,vcn.new_vaccinations)) over (partition by 
dth.location order by dth.location,dth.date) as rollingpeoplvaccinated
from dbo.covid_deaths dth
join dbo.covid_vaccinations vcn
on dth.location = vcn.location 
and dth.date = vcn.date
where dth.continent is not null
order by 2,3

---USE OF CTE------------------------

With PopvsVac (continent, location , date , population,new_vaccinations, rollingpeoplvaccinated)
as
(
select dth.continent , dth.location , dth.date , dth.population , 
vcn.new_vaccinations ,sum(convert(int,vcn.new_vaccinations)) over (partition by 
dth.location order by dth.location,dth.date) as rollingpeoplvaccinated
from dbo.covid_deaths dth
join dbo.covid_vaccinations vcn
on dth.location = vcn.location 
and dth.date = vcn.date
where dth.continent is not null
)

select *,(rollingpeoplvaccinated/population)*100 
from PopvsVac

--------TEMP TABLE-------------------------------

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplvaccinated numeric
)

INSERT into #percentpopulationvaccinated
select dth.continent , dth.location , dth.date , dth.population , 
vcn.new_vaccinations ,sum(convert(int,vcn.new_vaccinations)) over (partition by 
dth.location order by dth.location,dth.date) as rollingpeoplvaccinated
from dbo.covid_deaths dth
join dbo.covid_vaccinations vcn
on dth.location = vcn.location 
and dth.date = vcn.date
where dth.continent is not null


select *,(rollingpeoplvaccinated/population)*100 
from #percentpopulationvaccinated

---Create view to store data for data visualizations

CREATE VIEW Percentpopulationvaccinated as
select dth.continent , dth.location , dth.date , dth.population , 
vcn.new_vaccinations ,sum(convert(int,vcn.new_vaccinations)) over (partition by 
dth.location order by dth.location,dth.date) as rollingpeoplvaccinated
from dbo.covid_deaths dth
join dbo.covid_vaccinations vcn
on dth.location = vcn.location 
and dth.date = vcn.date
where dth.continent is not null

select * from
Percentpopulationvaccinated

