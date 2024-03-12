create database flights_eda;

use flights;

select monthname(date_of_journey), count(*)
from flights
group by monthname(date_of_journey)
order by count(*) desc limit 1;

select dayname(date_of_journey), avg(Price)
from flights
group by dayname(date_of_journey)
order by avg(Price) desc limit 1;

select distinct monthname(t1.date_of_journey), airline,
count(t1.airline) over(partition by t1.Airline, monthname(t1.date_of_journey)) as 'num_flights'
from flights.flights t1
where t1.airline in (select distinct airline 
								from flights.flights t2
                                where t2.Airline = t1.Airline)
order by airline;

select *
from flights;

select *
from flights
where source = 'Banglore' and Destination = 'New Delhi'
and Dep_Time > '10:00:00' and Dep_Time < '14:00:00';

select count(*)
from flights
where source = 'Banglore'
and  dayname(Date_of_journey) in ('Saturday', 'Sunday');

select *,
addtime(dep_time,duration) as 'arrival_time'
from flights;

alter table flights 
add column Departure DATETIME after Destination;

select  str_to_date(concat(date_of_journey,' ',dep_time),'%Y-%m-%d %H:%i')
from flights;

update flights
set Departure = str_to_date(concat(date_of_journey,' ',dep_time),'%Y-%m-%d %H:%i');

select *
from flights;

alter table flights 
add column Duration_mins integer after Departure,
add column Arrival datetime;

select *
from flights;

select duration,
replace(substring_index(duration,' ',1),'h','')*60 +
case 
	when substring_index(duration,' ',-1) = substring_index(duration,' ',1) then 0 
    else replace(substring_index(duration,' ',-1),'m','') 
end as 'mins'
from flights;

update flights
set Duration_mins = case
						when duration like '%h%m' then
							substring_index(duration,'h',1)*60+
                            substring_index(substring_index(duration,'',-1),'m',1)
						when duration like '%h' then
							substring_index(duration,'h',1)*60
						when duration like '%m' then
							substring_index(duration,'m',1)
					end;
                    
update flights
set arrival = date_add(departure,interval duration_mins minute);

select *
from flights;

select time(arrival)
from flights;

select Date(arrival)
from flights;

select count(*)
from flights
where date(departure) != date(arrival);

select Source,Destination,time_format(sec_to_time(avg(duration_mins)*60),'%kH %im') as 'average_duration'
from flights
group by  source, destination;

 select *
 from flights
 where total_stops = 'non-stop' and 
 date(departure) < date(arrival);
 
 select airline,quarter(departure), count(*)
 from flights
 group by  airline ,quarter(departure)
 order by airline asc;
 
 select Source,Destination,time_format(sec_to_time(avg(duration_mins)*60),'%kH %im') as 'average_duration'
from flights
group by  source, destination
order by  average_duration desc;

with temp_table as (select *,
case 
	when total_stops = 'non-stop' then 'non-stop'
    else 'wth-stop'
end as 'temp'
from flights)

select temp,
time_format(sec_to_time(avg(duration_mins)*60),'%kH %im') as 'average_duration'
from temp_table
group by temp;

select *
from flights
where Airline = 'Air India'
and source = 'Delhi'
and date(Departure) between '2019-01-01' and '2019-01-31';

select airline,max(duration)
from flights
group by airline
order by max(Duration) desc;

select source,destination, round(avg(Duration),2)
from flights
group by source,Destination
having avg(Duration) > 3;

select dayname(departure),
sum(case when hour(departure) between '0' and '5' then 1 else 0 end) as '12AM - 6AM',
sum(case when hour(departure) between '6' and '11' then 1 else 0 end) as '6AM - 12PM',
sum(case when hour(departure) between '12' and '17' then 1 else 0 end) as '12PM - 6PM',
sum(Case when hour(departure) between '18' and  '23' then 1 else 0 end) as '6PM - 12PM',
sum(case when hour(departure) between '0' and '23' then 1 else 0 end) as '12AM - 11:59 PM'
from flights
where source = 'Banglore' and destination = 'Delhi'
group by dayname(Departure);


select dayname(Departure),
avg(case when hour(departure) between '0' and '5' then price else null end) as '12AM - 6AM',
avg(case when hour(departure) between '6' and '11' then price else null end) as '6AM - 12PM',
avg(case when hour(departure) between '12' and '17' then price else null end) as '12PM - 6PM',
avg(case when hour(departure) between '18' and '23' then price else null end) as '6PM - 12PM'
from flights
where source = 'Banglore' and destination = 'Delhi'
group by dayname(departure);
