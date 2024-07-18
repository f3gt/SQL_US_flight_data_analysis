select FlightDate from flightS

select * from airports

select * from weather

select * from flights

--Weekly Distribution of Flights

SELECT DATEPART(ISO_WEEK, FlightDate) AS weekofyear, 
       COUNT(FlightDate) AS total_flights
FROM flights
GROUP BY DATEPART(ISO_WEEK, FlightDate)
ORDER BY weekofyear, total_flights;

--Monthly Distribution of Flights

select case DATEPART(month, FlightDate) 
	when 1 then 'JAN' 
	when 2 then 'FEB' 
	when 3 then 'MAR' 
	when 4 then 'APR' 
	when 5 then 'MAY' 
	when 6 then 'JUN' 
	when 7 then 'JUL' 
	when 8 then 'AUG' 
	when 9 then 'SEPT'
	when 10 then 'OCT' 
	when 11 then 'NOV' 
	when 12 then 'DEC' 
	end as monthofyear,
	count(FlightDate) as total_flights
	from  flights
   group by DATEPART(month, FlightDate)
   order by DATEPART(month, FlightDate),total_flights


--- Flights Departing from City

select (Dep_CityName ) as City,count(Tail_Number) as flights_per_city
from flights
group by Dep_CityName
order by flights_per_city desc

--Flights by Airline

select Airline, count(*) as flight_per_airline
from flights
group by Airline
order by flight_per_airline desc

-- Weekly and monthly delay of flights

SELECT DATEPART(WEEKDAY, f.FlightDate) AS day_of_week,
       DATEPART(MONTH, f.FlightDate) AS month,
       COUNT(f.Dep_Delay) AS week_day_delay_flights,
       m.monthly_delay_flight
FROM flights f
INNER JOIN (
    SELECT DATEPART(MONTH, m.FlightDate) AS month, 
           COUNT(*) AS monthly_delay_flight
    FROM flights m
    WHERE m.Dep_Delay > 0
    GROUP BY DATEPART(MONTH, m.FlightDate)
) AS m ON DATEPART(MONTH, f.FlightDate) = m.month
WHERE f.Dep_Delay > 0
GROUP BY DATEPART(WEEKDAY, f.FlightDate), DATEPART(MONTH, f.FlightDate), m.monthly_delay_flight
ORDER BY DATEPART(MONTH, f.FlightDate), DATEPART(WEEKDAY, f.FlightDate)


--Number of delay flights by departure city

select Dep_CityName,count(*) as flight_delay
from flights
where Dep_Delay>0
group by Dep_CityName
order by flight_delay desc

--Number of flights delay by airline

select Airline,count(*) as flight_delay
from flights
where Dep_Delay>0
group by Airline
order by flight_delay desc

--Avg Arrival Delay,Departure Delay on Days of week

select Day_Of_Week,Avg(Dep_Delay) as Average_dep_delay,Avg(Arr_Delay) as Average_Arr_delay
from flights
group by Day_Of_Week
order by Day_Of_Week asc

--Average delay at origin

select Avg(Delay_Weather) weather_delay,Avg(Delay_LastAircraft) last_aircraft_delay,
	   Avg(Delay_NAS) nas_delay,Avg(Delay_Security) security_delay,Avg(Delay_Carrier) carrier_delay
from flights

--Distribution of cancelled flights weekly and monthly
--Updating FlightDate in to suitable format 'yyyy-mm-dd'

update cancelled
set FlightDate=( 
    TRY_CONVERT(DATE, FlightDate, 103)
)


select datepart(WEEKDAY,c.FlightDate) Day_of_week,datepart(MONTH,c.FlightDate) Months,count(*) as weekly_cancelled,m.Monthly_cancelled
from cancelled c
	inner join (
	select DATEPART(MONTH,m.FlightDate) as months,count(*) as Monthly_cancelled
	from cancelled m
	where m.Cancelled=1
	group by DATEPART(MONTH,m.FlightDate)
	)as m on datepart(MONTH,c.FlightDate)=m.months
	where c.Cancelled=1
	group by datepart(WEEKDAY,c.FlightDate),datepart(MONTH,c.FlightDate),m.Monthly_cancelled
	order by Months,Day_of_week

-- Distribution of cancelled fligts across different Airlines

select Airline, count(*) as flights_cancelled
from cancelled
where Cancelled=1
group by Airline
order by flights_cancelled desc

---- Distribution of cancelled fligts across different Departure City

select Dep_CityName, count(*) as flights_cancelled
from cancelled
where Cancelled=1
group by Dep_CityName
order by flights_cancelled desc

-- Distribution of cancelled fligts across different Departure City

select Arr_CityName, count(*) as flights_cancelled
from cancelled
where Cancelled=1
group by Arr_CityName
order by flights_cancelled desc


--Distribution of Weekly and monthly diverted Flights

select datepart(WEEKDAY,c.FlightDate) as week_day,datepart(MONTH,c.FlightDate) as Months,count(*) as Week_day_flight_diversion,m.Monthly_flight_diversion
from cancelled c
inner join
	(select datepart(MONTH,m.FlightDate) as months,count(*) as monthly_flight_diversion
	from cancelled m
	where Diverted=1
	group by datepart(MONTH,m.FlightDate)
	) as m on datepart(MONTH,c.FlightDate)=m.months
	where c.Diverted=1
	group by datepart(WEEKDAY,c.FlightDate),datepart(MONTH,c.FlightDate), m.monthly_flight_diversion
	order by datepart(MONTH,c.FlightDate),datepart(WEEKDAY,c.FlightDate)

-- Diversion of flights across different Departure City

select Dep_CityName,count(*) as total_flights
from cancelled
where Diverted=1
group by Dep_CityName
order by total_flights desc

-- Diversion of flights across different Arrival City

select Arr_CityName,count(*) as total_flights
from cancelled
where Diverted=1
group by Arr_CityName
order by total_flights desc

-- Climate Impact on Flight Cancellations and Diversions

select airport_id as airport,
		tavg as average_temp,
		tmin as min_temp,
		tmax as max_temp,
		prcp as precipitation,
		snow as snowfall,
		wdir as wind_direction,
		wspd as wind_speed,
		pres as pressure,
		count(*) as flights_cancelled
		from weather w
		join cancelled c
		on c.Dep_Airport=w.airport_id and c.FlightDate=w.time
		where c.Cancelled=1
		group by w.tavg ,
				w.airport_id,
				w.tmin ,
				w.tmax ,
				w.prcp ,
				w.snow ,
				w.wdir ,
				w.wspd ,
				w.pres ,
			
		ORDER BY flights_cancelled DESC


 

