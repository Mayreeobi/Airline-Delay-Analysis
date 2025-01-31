use project;

Create Table airline_delays (
 year int,
 month int,
 date	date,
 carrier_ID	varchar(10),
 carrier_name	varchar(255),
 airport_code	varchar(5),
 airport_name varchar(255),
 latitude	double,
 longitude	double,
 total_flights_arrival int,
 total_arrivals_delay_above_15_mins int,
 total_delays_due_to_carrier_reasons  double,
 total_delays_due_to_weather	double,
 total_delays_due_to_National_aviation_systems	double,
 total_delays_due_to_security_breach double,
 total_delays_due_to_late_aircraft	double,
 total_cancelled_flight int,
 total_diverted_flights	int,
 delay_due_to_late_arrival_in_mins int,	
 delay_due_to_carrier_reasons_in_mins	int,
 delay_due_to_waether_in_mins	int,
 delays_due_to_National_aviation_systems_in_mins	int,
 delays_due_to_security_breach_in_mins int,
 delays_due_to_late_aircraft_in_mins int
 );

SELECT * FROM project.airline_delays;

describe airline_delays;

-- Overall total flight
SELECT year,
     Sum(total_flights_arrival) as total_flight
From airline_delays
Group by year
Order by total_flight ASC;

-- Delay Rate: Percentage of flights delayed by more than 15 minutes
SELECT 
    ROUND((SUM(total_arrivals_delay_above_15_mins) / SUM(total_flights_arrival) * 100),2) AS delay_rate
FROM airline_delays;

-- Cancellation Rate: Percentage of flights cancelled
SELECT 
    ROUND(((SUM(total_cancelled_flight) / SUM(total_flights_arrival)) * 100),2) AS CancellationRate
FROM airline_delays;


-- Average Delay Rate per Flight:
SELECT 
    ROUND(SUM(delay_due_to_late_arrival_in_mins) / SUM(total_flights_arrival),2) AS AvgDelayRatePerFlight
FROM airline_delays;

-- On-time Rate
SELECT 
      ROUND(100 - (SUM(total_arrivals_delay_above_15_mins) / SUM(total_flights_arrival) * 100), 2) AS OnTime_rate
FROM airline_delays;


-- What is the busiest months and airport for flight
-- Busiest Months
SELECT year, month,
     Sum(total_flights_arrival) as total_flight
From airline_delays
Group by 1,2
order by total_flight desc;

-- Busiest Airports
SELECT airport_code, airport_name,
     Sum(total_flights_arrival) as total_flight
From airline_delays
Group by airport_code, airport_name
Order by total_flight desc;


-- which month experience the highest delay rate? 
SELECT 
    Date, 
    ROUND((SUM(total_arrivals_delay_above_15_mins) / SUM(total_flights_arrival) * 100),2) AS delay_rate
FROM airline_delays
GROUP BY date
ORDER BY delay_rate DESC;

-- Year-over-Year Delay Trends:
SELECT 
    year, 
    ROUND((SUM(total_arrivals_delay_above_15_mins) / SUM(total_flights_arrival) * 100), 2) AS delay_rate
FROM airline_delays
GROUP BY year
ORDER BY year;

SELECT 
    month, 
    ROUND(AVG(delay_due_to_late_arrival_in_mins), 2) AS avg_delay_time
FROM airline_delays
GROUP BY month
ORDER BY avg_delay_time DESC;



-- delay across different airline
SELECT 
    airport_code, 
   sum(total_flights_arrival) AS total_flights, 
    SUM(CASE WHEN total_arrivals_delay_above_15_mins THEN 1 ELSE 0 END) AS delayed_flights
FROM airline_delays
GROUP BY airport_code
ORDER BY delayed_flights DESC;


SELECT 
    carrier_name, 
    ROUND((SUM(total_arrivals_delay_above_15_mins) / SUM(total_flights_arrival) * 100), 2) AS delay_rate
FROM airline_delays
GROUP BY carrier_name
ORDER BY delay_rate DESC;

--  Primary Causes of Delays
SELECT 
    SUM(delay_due_to_carrier_reasons_in_mins) AS CarrierDelays,
    SUM(delay_due_to_waether_in_mins) AS WeatherDelays,
    SUM(delays_due_to_late_aircraft_in_mins) AS LateAircraftDelays,
    SUM(delay_due_to_late_arrival_in_mins) AS LateArrival,
    SUM(delays_due_to_security_breach_in_mins) AS SecurityBreach,
    SUM(delays_due_to_National_aviation_systems_in_mins) AS NationalAviation
FROM airline_delays;

SELECT 
    ROUND(SUM(total_delays_due_to_carrier_reasons),0) AS CarrierDelays,
    ROUND(SUM(total_delays_due_to_weather),0) AS WeatherDelays,
    ROUND(SUM(total_delays_due_to_late_aircraft),0) AS LateAircraftDelays,
    ROUND(SUM(total_delays_due_to_security_breach),0) AS SecurityBreach,
    ROUND(SUM(total_delays_due_to_National_aviation_systems),0) AS NationalAviationSystem
FROM airline_delays;


-- Airports Most Affected by Weather-Related Delays
SELECT 
    airport_name, 
    SUM(delay_due_to_waether_in_mins) AS TotalWeatherDelays
FROM airline_delays
GROUP BY airport_name
ORDER BY TotalWeatherDelays DESC;


-- Delays Between Peak and Off-Peak Seasons
SELECT 
    CASE 
        WHEN MONTH IN (6, 7, 8, 12) THEN 'Peak' 
        ELSE 'Off-Peak' 
    END AS season,
    SUM(total_flights_arrival) AS total_flights, 
    SUM(CASE WHEN total_arrivals_delay_above_15_mins > 0 THEN 1 ELSE 0 END) AS delayed_flights,
    (SUM(CASE WHEN total_arrivals_delay_above_15_mins THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS delay_rate
FROM airline_delays
GROUP BY season
ORDER BY delay_rate DESC;

-- Define peak season (e.g., June, July, August) and off-peak season (e.g., January, February, March)
SELECT year,
    CASE 
        WHEN Month IN (6, 7, 8, 12) THEN 'Peak'
        ELSE 'Off-Peak'
    END AS Season,
    ROUND(AVG(delay_due_to_late_arrival_in_mins),2) AS AvgDelayTime
FROM airline_delays
GROUP BY year, Season;

-- Geographical Patterns in Delay Occurrences (Coastal vs. Inland Airports) 
SELECT 
    CASE 
        WHEN latitude > 35 THEN 'Coastal' 
        ELSE 'Inland' 
    END AS Region,
    SUM(total_flights_arrival) AS total_flights, 
    SUM(CASE WHEN total_arrivals_delay_above_15_mins > 0 THEN 1 ELSE 0 END) AS delayed_flights,
    (SUM(CASE WHEN total_arrivals_delay_above_15_mins > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS delay_rate
FROM airline_delays
GROUP BY Region
ORDER BY delay_rate DESC;

--  Regions with Higher Delays Due to Weather Conditions delay_due_to_waether_in_mins
SELECT 
    latitude, 
    longitude, 
    SUM(total_flights_arrival) AS total_flights,
    SUM(CASE WHEN delay_due_to_waether_in_mins > 0 THEN 1 ELSE 0 END) AS weather_delays
FROM airline_delays
WHERE delay_due_to_waether_in_mins > 0
GROUP BY latitude, longitude
ORDER BY weather_delays DESC;

-- Percentage of Flights Experiencing Delays Over 15 Minutes
SELECT 
    (SUM(total_arrivals_delay_above_15_mins) * 100.0 / SUM(total_flights_arrival)) AS delayed_flights_percentage
FROM airline_delays;


-- Airports or Airlines with Better On-Time Performance
-- Airports with Best On-Time Performance
SELECT 
    airport_name,  
    ROUND(100 - (SUM(total_arrivals_delay_above_15_mins) / SUM(total_flights_arrival) * 100),2) AS OnTimePercentage
FROM airline_delays
GROUP BY airport_name
ORDER BY OnTimePercentage DESC;

-- Airlines with Best On-Time Performance
SELECT 
    carrier_name, 
    ROUND(100 - (SUM(total_arrivals_delay_above_15_mins) / SUM(total_flights_arrival) * 100),2) AS OnTimePercentage
FROM airline_delays
GROUP BY carrier_name
ORDER BY OnTimePercentage DESC;

-- Cancellation Rate by Airport:
SELECT 
    airport_name, 
    ROUND((SUM(total_cancelled_flight) / SUM(total_flights_arrival) * 100), 2) AS cancellation_rate
FROM airline_delays
GROUP BY airport_name
ORDER BY cancellation_rate DESC;





