SELECT *
FROM Portfolio..CovidDeathscsv

-- Total cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infectation_percentage
FROM Portfolio..CovidDeathscsv
ORDER BY location, date

-- Countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeathscsv
Group by Location, Population
order by PercentPopulationInfected desc

-- Infectation percentage in Algeria
SELECT location, date, total_cases,population, (total_cases/population)*100 AS infectation_percentage
FROM Portfolio..CovidDeathscsv
WHERE location = 'Algeria'

-- Total_deaths vs total_cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Portfolio..CovidDeathscsv
ORDER BY location, date

-- Death percentage by country
SELECT location, SUM(CAST(new_deaths as int)) AS total_deaths,population, (SUM(CAST(new_deaths as int))/population)*100 AS death_percentage
FROM Portfolio..CovidDeathscsv
GROUP BY location, population 
ORDER BY death_percentage DESC

-- Death percentage in Algeria by population
SELECT location, date, total_deaths, population, (total_deaths/population)*100 AS death_percentage
FROM Portfolio..CovidDeathscsv
WHERE location = 'Algeria'

-- Death percentage in Algeria compared to the infected population
SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 AS death_percentage
FROM Portfolio..CovidDeathscsv
WHERE location = 'Algeria'

-- Death by continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeathscsv
Where continent is not null 
Group by continent
order by TotalDeathCount desc

SELECT *
FROM Portfolio..CovidVaccinationscsv

-- Join the two tables on the location and date
SELECT *
FROM Portfolio..CovidDeathscsv AS dea
JOIN Portfolio..CovidVaccinationscsv AS vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeathscsv dea
Join Portfolio..CovidVaccinationscsv vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeathscsv dea
Join Portfolio..CovidVaccinationscsv vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinated_Percentage
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeathscsv dea
Join Portfolio..CovidVaccinationscsv vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinated_Percentage
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeathscsv dea
Join Portfolio..CovidVaccinationscsv vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
