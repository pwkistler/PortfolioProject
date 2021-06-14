/*
	Queries used to collect data for Tableau Dashboard
*/


--------------------

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..Covid_Deaths
where continent is not NULL
order by 1, 2;


---------------------

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
where continent is NULL
	and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;


-------------------

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-----------------

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Covid_Deaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;


--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaxxed) as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location
	Order by dea.location, dea.date) as RollingPeopleVaxxed
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
)
Select *, (RollingPeopleVaxxed / Population) * 100 as PercentageVaxxed
from PopvsVac;


--TEMP TABLE

DROP Table if exists #PercentPopVaxxed
Create Table #PercentPopVaxxed (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaxxed numeric
)

Insert into #PercentPopVaxxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location
	Order by dea.location, dea.date) as RollingPeopleVaxxed
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not NULL

Select *, (RollingPeopleVaxxed / Population) * 100 as PercentageVaxxed
from #PercentPopVaxxed;


--Creating view to store data for future visuals

Create View PercentPopVaxxed as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location
	Order by dea.location, dea.date) as RollingPeopleVaxxed
From PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not NULL

Select *
From PercentPopVaxxed;