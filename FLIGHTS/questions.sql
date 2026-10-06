select * from Airports;
select * from Airlines;
select * from Flights;
select * from Passengers;
select * from Tickets;

-- find the busiest airport by the number of flights take off
with CountFlights as
(
select a.AirportID, a.Name, 
count(a.AirportID) as FlightTakeOffNumber 
from Airports a join Flights f 
on a.AirportID = f.Origin 
group by a.AirportID
), CountFlightsMax as
(
select max(FlightTakeOffNumber) as maxFlights 
from CountFlights
)
select * from CountFlights 
where FlightTakeOffNumber = 
(select maxFlights from CountFlightsMax);

-- total number of tickets sold per airline
select a.AirlineID, a.Name, 
count(t.TicketID) as TotalTicketsSold 
from Airlines a 
join Flights f on a.AirlineID = f.AirlineID
join Tickets t on f.flightID = t.flightID
group by a.AirlineID;

-- find all flights operated by 'IndiGo' with airport name(origin and destination)
select f.FlightID, a1.Name as OriginName,a2.Name as DestinationName
from Airlines air
join Flights f on air.AirlineID = f.AirlineID
join Airports a1 on a1.AirportID = f.Origin
join Airports a2 on a2.AirportID = f.Destination
where air.Name = 'IndiGo';

-- for each airport, show the top airline by number of flights departing from there
with cte4 as
(
select air.AirlineID, 
air.Name as AirlineName, 
f.Origin, 
a.Name as AirportName, 
count(Origin) as MaxFlightCount 
from Airlines air 
join Flights f on air.AirlineID = f.AirlineID
join Airports a on f.Origin = a.AirportID group by f.Origin, air.AirlineID
),
cte5 as
(
select *, 
rank() over(partition by Origin order by MaxFlightCount desc) as rown 
from cte4 
)
select AirlineName, AirportName, MaxFlightCount  from cte5 where rown = 1;

-- for each flight, show time in hours and categorize it as Short (<2h), Medium (2-5h) or Long (>5h)
with time_difference as
(
select * ,timediff(ArrivalTime, DepartureTime) as DifferenceInTime from Flights
)
select *,
case
when time_to_sec(DifferenceInTime) > 5*3600 then 'Long'
when time_to_sec(DifferenceInTime) between 2*3600 and 5*3600 then 'Medium'
when time_to_sec(DifferenceInTime) < 2*3600 then 'Short' end as FlightCategory
from time_difference;

-- for each passenger first and last flights date and number of flights;
select p.Name, 
min(DepartureTime) as FirstFlight, 
max(ArrivalTime) as LastFlight,
count(*) as TotalFlights
from Passengers p 
join Tickets t on p.PassengerID = t.PassengerID
join Flights f on t.FlightID = f.FlightID 
group by p.PassengerID;

-- flights and their highest price ticket sold for each route (origin -> destination)
with cte as
(
select a1.Name as OriginName,
a2.Name as DestinationName,
t.TicketID as TicketID,
t.Price as TicketPrice,
row_number() over(partition by f.Origin, f.Destination order by t.Price desc) as rn
from Flights f 
join Tickets t on f.FlightID = t.FlightID
join Airports a1 on f.Origin = a1.AirportID
join Airports a2 on f.Destination = a2.AirportID
)
select OriginName, 
DestinationName, 
TicketID,
TicketPrice
from cte where rn = 1
order by TicketPrice desc;

-- find the highest spending passenger in each Frequent Flyer Status group
with SatusCTE as 
(
select p.FrequentFlyerStatus as FrequentFlyerStatus,
sum(t.Price) as TotalPrice,
p.Name as Name,
rank() over(partition by p.FrequentFlyerStatus order by sum(t.Price) DESC) rn
from passengers p
join Tickets t 
on t.PassengerID = p.PassengerID
group by Name, FrequentFlyerStatus
)
select FrequentFlyerStatus, Name, TotalPrice from SatusCTE where rn = 1;

-- find the total revenue and number of tickets sold for each airline, and rank the airlines based on total revenue
select 
a.AirlineID,
a. Name as AirlineName,
sum(t.Price) as TotalRevenue,
count(t.Price) as TotalTickets,
rank() over(order by sum(t.Price) desc) as RankOfTotalRevenue
from Airlines a 
join Flights f on a.AirlineID = f.AirlineID
join Tickets t on t.FlightID = f.FlightID
group by a.AirlineID, a.Name;

-- for each passenger, identify their most frequently used airline, if a passenger have multiple, show all
with CTERank as 
(
select p.Name as PassengerName, 
a.Name as AirlineName, 
count(*) as CountOfAirline,
dense_rank() over (partition by p.Name order by count(*) desc) rankofAirlines
from Passengers p
join Tickets t on p.PassengerID = t.PassengerID
join Flights f on t.FlightID = f.FlightID
join Airlines a on f.AirlineID = a.AirlineID 
group by p.Name, a.Name
)
select PassengerName, 
AirlineName, 
CountOfAirline 
from CTERank 
where rankofAirlines = 1;