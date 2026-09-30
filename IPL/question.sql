select * from IPLPlayers;

-- spending on players of each team
select Team, sum(Price_in_cr) as total_spending from IPLPlayers group by Team order by total_spending desc;

-- top 3 highest-paid allrounder across all teams
select Player, team, Price_in_cr from IPLPlayers where Role = 'All-rounder' order by Price_in_cr desc limit 3;

-- highest paid member in each team
with cte as
(select Player, team, Price_in_cr, 
row_number() over(partition by team order by Price_in_cr desc) as row_num
from IPLPlayers)
select team, Player as TopPlayer, Price_in_cr from cte where row_num = 1 order by Price_in_cr desc;

-- top 2 paid players in each company
with cte2 as
(select Player, team, Price_in_cr, 
row_number() over(partition by team) as row_num
from IPLPlayers)
select team, Player as TopPlayer, row_num, Price_in_cr from cte2 where row_num <= 2;

-- top 2 paid players in each company
with cte3 as
(select Player, team, Price_in_cr, 
row_number() over(partition by team) as row_num
from IPLPlayers)
select team, 
max(case when row_num = 1 then player end )as TopPlayer,
max(case when row_num = 1 then Price_in_cr end )as TopPlayerPrice,
max(case when row_num = 2 then player end )as `2ndTopPlayer`,
max(case when row_num = 1 then Price_in_cr end )as `2ndTopPlayerPrice`
from cte3
group by team;

-- calculate the percentage contribution of each player's price to their team's total spending

with cte4 as
(select Player, team, Price_in_cr, 
sum(Price_in_cr) over(partition by team) as total
from IPLPlayers)
select Player, team, Price_in_cr, 
round(sum(Price_in_cr) over(partition by team)/total*100,2) as percent from cte4;

-- classify players as high, medium, low
-- prize > 15, high
-- prize between 5 and 15, medium
-- prize < 5, low
-- find out number of players in each bracket

with cte5 as
(
select Team, Player, Price_in_cr, 
case when Price_in_cr > 15 then 'High'
	when Price_in_cr between 5 and 15 then 'Medium'
    when Price_in_cr < 5 then 'Low' end as salarybracket
from IPLPlayers
)
select Team, salarybracket, count(*) from cte5 
group by Team, salarybracket
order by Team, salarybracket;

-- find average of indian players and compare it with overseas players using subquery?
(select 'Indian' as `Type`, avg(Price_in_cr) from IPLPlayers where `Type` like '%Indian%')
union all
(select 'Overseas' as `Type`, avg(Price_in_cr) from IPLPlayers where `Type` like '%Overseas%');

-- select players which have price greater than team average 
with cte6 as
(
select Team, Player, Price_in_cr,
avg(Price_in_cr) over(partition by team) as TeamAverage from IPLPlayers
)
select Player, Team, TeamAverage, Price_in_cr from cte6 where Price_in_cr > TeamAverage;

-- select most expensive player in each role and their price
-- select Role, max(Price_in_cr), Player from IPLPlayers group by Role;
with cte7 as
(
select `Role`, Player,Price_in_cr,
max(Price_in_cr) over(partition by Role) as Max from IPLPlayers
)
select Role, Player, Price_in_cr from cte7 where Max = Price_in_cr order by `Role`, Player;