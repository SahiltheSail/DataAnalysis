
--Select *
--From Portfolio_project..[covid-vaccinations]
--order by 3,4

Select *
From PortfolioProject..CovidDeaths$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2 

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%India%'
and continent is not null 
order by 1,2
-- Likelihood of a person in India dying from COVID is 1.105%

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%India'
order by 1,2
-- Likelihood of a person in India contracting COVID is 1.388%

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc
-- Andorra has the highest percent of population infected by COVID
-- A statistical test will determine if the high percentage is statistically significant or just pure chance.

Select Location, MAX(cast(total_deaths AS int)) as HighestDeath, population
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location, Population
order by HighestDeath desc
-- United States has the highest count of deaths due to COVID

Select Location, MAX(cast(total_deaths AS int)) as HighestDeath, population, Max((total_deaths/population))*100 as PercentPopulationDied
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location, Population
order by HighestDeath desc
-- United States has the highest percentage of deaths out of the population

Select Location, MAX(cast(total_deaths AS int)) as HighestDeath, population, Max((total_deaths/total_cases))*100 as PercentCasesDied
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location, Population
order by HighestDeath desc
-- United States has the highest percentage of deaths out of the infected

Select continent, MAX(cast(total_deaths as int)) as HighestDeath 
From PortfolioProject..CovidDeaths$
WHERE continent is not null
Group by continent
order by HighestDeath DESC
--Among the continents, North America has the highest death count
--Oceania includes Australasia, Melanesia, Micronesia, and Polynesia

SELECT date, SUM(new_cases) as dailyinfected, SUM(CAST(new_deaths AS int)) as dailydeaths,(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 as dailydeathpercent
From PortfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
--new_deaths is a NVARCHAR, so cast it as int
--daily number of deaths globally

SELECT SUM(new_cases) as dailyinfected, SUM(CAST(new_deaths AS int)) as dailydeaths,(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 as dailydeathpercent
From PortfolioProject..CovidDeaths$ 
WHERE continent IS NOT NULL
ORDER BY 1,2
-- Global death percentage is 2.11%

Select *
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
order by 1

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationtillday
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.location like '%India%'
order by 2,3
--Total vaccinations in India till 30/04/2021 is 142586233

--Learning CTE
-- No. of cols in CTE = No. of cols in Select
-- Cant use ORDER BY inside CTE
With VacofPop (continent, location, date, population, new_vaccinations, TotalVaccinationtillday)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationtillday
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
)
Select *, (TotalVaccinationtillday/Population)*100 as VacPopPercent
from VacofPop 
where VacofPop.continent is not null and VacofPop.location like '%India%'
-- By 30/04/2021, 10.33 % of India was vaccinated

--Learning Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationtillday
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 as VacPopPercent
From #PercentPopulationVaccinated
--End of Temp Table

-- Creating a View
Create View PercentPopulationDied as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationtillday
From PortfolioProject..CovidVaccinations$ vac
Join PortfolioProject..CovidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 

Select * from #PercentPopulationVaccinated





