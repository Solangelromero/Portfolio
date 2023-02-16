select *
from ..[CovidVaccinations];

select *
from ..[dbo].[CovidDeaths];

Select Location,date,total_cases,new_cases,total_deaths,population
from ..[dbo].[CovidDeaths];

Select Location,date,total_cases,new_cases,total_deaths,population
from ..[dbo].[CovidDeaths]
order by 1,2;

--total cases vs total deaths and death percentage
Select Location,date,total_cases,total_deaths,
(total_deaths/total_cases)*100 as deathPercentage
From Practice..CovidDeaths
Where Location like '%states%'
and continent is not null
Order by 1,2;

--total cases vs population and percent population with covid
Select Location,date,total_cases,population,
(total_cases/population)*100 as PopulationCovid
From Practice..CovidDeaths
Where Location like '%states%'
and continent is not null
Order by 1,2;

--country with highest infection rate vs population
Select Location,MAX(total_cases) as topInfectionCount,population,
MAX((total_cases/population)*100) as PopulationAffectedPercent
From Practice..[CovidDeaths]
Where continent is not null
Group by Location,population
Order by PopulationAffectedPercent desc;

--Countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Practice..CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc;

-- death count by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Practice..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;


-- global numbers 
Select date,Sum(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercent
From Practice..CovidDeaths
Where continent is not null
Group by date
Order by 1,2;


--total gobal numbers 
Select Sum(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercent
From Practice..CovidDeaths
Where continent is not null
Order by 1,2;

select *
from Practice..CovidVaccinations vac
Join Practice..CovidDeaths dea
on dea.Location = vac.Location
and dea.date = vac.date

--total population vs vaccination
select dea.continent, dea.Location,dea.date,dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order by dea.Location,
dea.date) as rollingVaccinations
from Practice..CovidDeaths dea
Join Practice..CovidVaccinations vac
on dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3;

--cte

with Vaccinations as
(
select dea.continent, dea.Location,dea.date,dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order by dea.Location,
dea.date) as rollingVaccinations
from Practice..CovidDeaths dea
Join Practice..CovidVaccinations vac
on dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null
)
select *,(rollingVaccinations/population)*100 as NumVaccinated
From Vaccinations
order by 2,3



--temp table 

DROP table if exists #PercentVac
Create table #PercentVac
(
Continent nvarchar (255),
Loaction nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
rollingVaccinations numeric
)

Insert into #PercentVac
select dea.continent, dea.Location,dea.date,dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order by dea.Location,
dea.date) as rollingVaccinations
from Practice..CovidDeaths dea
Join Practice..CovidVaccinations vac
on dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null

select *,(rollingVaccinations/population)*100 as NumVaccinated
From #PercentVac
order by 2,3

--creating view for visualization
Create view PopulationVac as
select dea.continent, dea.Location,dea.date,dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order by dea.Location,
dea.date) as rollingVaccinations
from Practice..CovidDeaths dea
Join Practice..CovidVaccinations vac
on dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null

Select *
From PopulationVac