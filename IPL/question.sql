select * from IPLPlayers ;

select distinct(`type`) from IPLPlayers;

UPDATE IPLPlayers
SET Type = REPLACE(Type, 'Overseas(', 'Overseas (')
WHERE Type LIKE 'Overseas%';

UPDATE IPLPlayers
SET Type = REPLACE(Type, 'India (', 'Indian (')
WHERE Type LIKE 'India (%';

ALTER TABLE IPLPlayers
ADD Players2 NVARCHAR(120);
UPDATE IPLPlayers
SET Players2 = TRIM(SUBSTRING_INDEX(Player, '(', 1))
WHERE Player LIKE '%(%';
UPDATE IPLPlayers
SET Player = Players2
WHERE Player LIKE '%(%';
ALTER TABLE IPLPlayers
DROP COLUMN Players2;

-- 1. How much is each team spending on its players?
select Team, sum(Price_in_cr) as total_spending from IPLPlayers group by Team order by total_spending desc;

-- 2. Who are the top 3 highest-paid all-rounders?
select Player, team, Price_in_cr from IPLPlayers where Role = 'All-rounder' order by Price_in_cr desc limit 3;

-- 3. Who is the highest-paid player in each team?
with rankofeachteamplayer as
(select Player, team, Price_in_cr, 
row_number() over(partition by team order by Price_in_cr desc) as row_num
from IPLPlayers)
select team, Player as TopPlayer, Price_in_cr from rankofeachteamplayer where row_num = 1 order by Price_in_cr desc;

-- 4. Who are the top 2 highest-paid players in each team?
with rankofeachplayer as
(select Player, team, Price_in_cr, 
row_number() over(partition by team order by Price_in_cr desc) as row_num
from IPLPlayers)
select team, Player as TopPlayer, row_num, Price_in_cr from rankofeachplayer where row_num <= 2;

-- 5. Can the top 2 players of each team be displayed as columns?
with rankofeachplayer2 as
(select Player, team, Price_in_cr, 
row_number() over(partition by team order by Price_in_cr desc) as row_num
from IPLPlayers)
select team, 
max(case when row_num = 1 then player end )as TopPlayer,
max(case when row_num = 1 then Price_in_cr end )as TopPlayerPrice,
max(case when row_num = 2 then player end )as `2ndTopPlayer`,
max(case when row_num = 2 then Price_in_cr end )as `2ndTopPlayerPrice`
from rankofeachplayer2
group by team;

-- 6. What percentage of a team's total spending does each player contribute?
with sumofeachteam as
(select Player, team, Price_in_cr, 
sum(Price_in_cr) over(partition by team) as total
from IPLPlayers)
select Player, team, Price_in_cr, 
round(Price_in_cr/total*100,2) as percent from sumofeachteam;

-- 7. How many players fall into High, Medium and Low price brackets?
-- classify players as high, medium, low
-- prize > 15, high
-- prize between 5 and 15, medium
-- prize < 5, low
-- find out number of players in each bracket

with pricebracket as
(
select Team, Player, Price_in_cr, 
case when Price_in_cr > 15 then 'High'
	when Price_in_cr between 5 and 15 then 'Medium'
    when Price_in_cr < 5 then 'Low' end as salarybracket
from IPLPlayers
)
select Team, salarybracket, count(*) from pricebracket
group by Team, salarybracket
order by Team, salarybracket;

-- 8. What is the average price of Indian vs Overseas players?
(select 'Indian' as `Type`, avg(Price_in_cr) from IPLPlayers where `Type` like '%Indian%')
union all
(select 'Overseas' as `Type`, avg(Price_in_cr) from IPLPlayers where `Type` like '%Overseas%');

-- 9. Which players are more expensive than their team's average player price?
with averageofteam as
(
select Team, Player, Price_in_cr,
avg(Price_in_cr) over(partition by team) as TeamAverage from IPLPlayers
)
select Player, Team, TeamAverage, Price_in_cr from averageofteam where Price_in_cr > TeamAverage;

-- 10. Who is the most expensive player in each role?
with maxoforeachrole as
(
select `Role`, Player,Price_in_cr,
max(Price_in_cr) over(partition by Role) as Max from IPLPlayers
)
select Role, Player, Price_in_cr from maxoforeachrole where Max = Price_in_cr order by `Role`, Player;