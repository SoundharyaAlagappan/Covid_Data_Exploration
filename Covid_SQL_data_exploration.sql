create database covid_portfolio;
use covid_portfolio;
SELECT * FROM covid_deaths;
SELECT * FROM covid_project.covid_vaccination;

SELECT * FROM covid_deaths ORDER BY 3 , 4;
SELECT * FROM covid_project.covid_vaccination ORDER BY 3 , 4;
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_portfolio.covid_deaths
WHERE
    total_cases != 0
ORDER BY 1 , 2;

-- total_cases VS total_deaths --
-- show likelihood of dying if you contract covid --
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS deathpercentage
FROM
    covid_portfolio.covid_deaths
WHERE
    total_cases != 0
ORDER BY 1 , 2;

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS deathpercentage
FROM
    covid_portfolio.covid_deaths
WHERE
    total_cases != 0
        AND location LIKE '%ndia%'
ORDER BY 1 , 2;

SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases / population) * 100 AS percentage_infected
FROM
    covid_portfolio.covid_deaths
WHERE
    total_cases != 0
ORDER BY 1 , 2;


-- looking for countries with highest infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS highestinfectioncount,
    MAX(total_cases / population) * 100 AS percentagepopulationinfected
FROM
    covid_portfolio.covid_deaths
GROUP BY 1 , 2
ORDER BY percentagepopulationinfected DESC;

-- looking for countries with highest death count per population
SELECT 
    location, population, MAX(total_deaths) AS totaldeathcount
FROM
    covid_portfolio.covid_deaths
WHERE
    continent != '0'
GROUP BY location , population
ORDER BY totaldeathcount DESC;


-- lets break things down by continent --
SELECT 
    covid_deaths.continent, MAX(total_deaths) AS totaldeathcount
FROM
    covid_deaths
WHERE
    continent != '0'
GROUP BY continent
ORDER BY totaldeathcount DESC;

-- Global numbers
SELECT 
    date,
    SUM(total_cases) AS Total_Cases,
    SUM(total_deaths) AS Total_deaths,
    SUM(total_deaths) / SUM(population) * 100 AS deathpercentage
FROM
    covid_portfolio.covid_deaths
WHERE
    total_cases != 0
GROUP BY date
ORDER BY 1 , 2;SELECT 
    SUM(total_cases) AS Total_Cases,
    SUM(total_deaths) AS Total_deaths,
    SUM(total_deaths) / SUM(population) * 100 AS deathpercentage
FROM
    covid_portfolio.covid_deaths
WHERE
    total_cases != 0
ORDER BY 1 , 2;SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations
FROM
    covid_portfolio.covid_deaths dea
        JOIN
    covid_project.covid_vaccination vac ON dea.date = vac.date
        AND dea.location = vac.location
WHERE
    dea.continent != '0'
        AND vac.new_vaccinations != 0
ORDER BY 2 , 3;

#creates rolling sum of new vaccinations by each day by location
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order  by dea.location,dea.date) #rolling sum
as rolling_people_vaccinated  
from 
covid_portfolio.covid_deaths dea
join covid_project.covid_vaccination vac
on  dea.date = vac.date
where dea.continent != "0" and vac.new_vaccinations!=0
order by 2,3;

-- we cannot use rolling_people_vaccinated directly to get desired result ie., to know percentage of people vaccinated
-- we want max(rolling_people_vaccinated)/total_population but its not possible hence we have to go with temp table or cte
-- with cte
with populationVsVaccination (continent,Location,Date,Population,new_vaccinations,rolling_people_vaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from covid_portfolio.covid_deaths dea 
join covid_project.covid_vaccination vac
on dea.location=vac.location and dea.date=vac.date 
where dea.continent !="0" 
)
select*,(rolling_people_vaccinated/population)*100
from populationVsVaccination;

#Temp table
-- Create Table #PercentagePopulationVaccinated
-- (Continent nvarchar(255),
-- location nvarchar(255),
-- date datetime,
-- Population numeric,
-- new_vaccinations numeric,
-- rolling_people_vaccinated numeric)
-- Insert into #PercentagePopulationVaccinated
-- select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
-- sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_sumpeoplevaccinated
-- from covid_portfolio.covid_deaths dea 
-- join covid_project.covid_vaccination vac
-- on dea.location=vac.location and dea.date=vac.date 
-- where dea.continent !="0"
-- Select *,(rolling_people_vaccinated/population)*100
-- from #PercentagePopulationVaccinated;

#creating view to store data for visualizations
create view percentpeoplevaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from covid_portfolio.covid_deaths dea 
join covid_project.covid_vaccination vac
on dea.location=vac.location and dea.date=vac.date 
where dea.continent !="0" 
order by 2,3;



SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    MAX(vac.total_vaccinations) AS rollingpeoplevaccinated
FROM
    covid_portfolio.covid_deaths dea
        JOIN
    covid_project.covid_vaccination vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent != '0'
ORDER BY 2 , 3;

-- 1.
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS death_percentage
FROM
    covid_portfolio.covid_deaths
WHERE
    continent != '0'
ORDER BY 1 , 2;

-- 2.
SELECT 
    location, continent, SUM(new_deaths) AS totaldeathcount
FROM
    covid_portfolio.covid_deaths
WHERE
    continent != '0'
        AND location NOT IN ('world' , 'European union', 'International')
GROUP BY location , continent
ORDER BY totaldeathcount DESC;

-- 3.
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / population) * 100 AS PercentagePopulationInfected
FROM
    covid_portfolio.covid_deaths
GROUP BY location , population
ORDER BY percentagepopulationinfected DESC;



