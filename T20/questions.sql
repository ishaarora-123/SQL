select * from t20i;

alter table t20i add Marginvalue int;
alter table t20i add MarginType varchar(20);
UPDATE t20i
SET Marginvalue = cast(substring_index(Margin,' ',1) as signed)
where Margin != '-';
UPDATE t20i
SET MarginType = cast(substring_index(Margin,' ',-1) as char)
where Margin != '-';


-- give all the matches playes between india and south africa in 2024
select * from t20i where
((Team1 = 'South Africa' and Team2 = 'India')
or 
(Team1 = 'India' and Team2 = 'South Africa'))
and year(MatchDate) = 2024;

-- top team who won most matches in 2024
select Winner, count(*) as CountOfWins from t20i 
where year(MatchDate) = 2024 
group by Winner order by CountOfWins desc limit 1;

-- ranking of teams who won most to least matches in 2024
select dense_rank() over(order by count(*) desc) as RankOfPlayer, 
Winner, count(*) as CountOfWins 
from t20i where year(MatchDate) = 2024 and winner not in ('tied','no result')
group by Winner order by CountOfWins desc;

-- which team has the highest winning margin in runs and what is the average margin
select Winner , 
round(avg(cast(TRIM(SUBSTRING_INDEX(Margin, 'r', 1)) as signed)),1) as avg_run 
from t20i
where Margin like '% runs' 
group by Winner
order by avg_run desc
limit 1;

-- which team has the highest winning wickets in runs and what is the average margin
select Winner , 
round(avg(cast(TRIM(SUBSTRING_INDEX(Margin, 'r', 1)) as signed)),1) as avg_wicket
from t20i
where Margin like '% wickets' 
group by Winner
order by avg_wicket desc
limit 1;

-- list all the matches where the winning margins was greater than average margin
with cte as 
(
select *,
avg(marginvalue) over(partition by MarginType) as marginaverage
from t20i
)
select Winner, MatchDate, Margin from cte where Marginvalue > marginaverage;

-- team with most wins when chasing a target (win by wickets)
with cte2 as(
select dense_rank() over(order by count(*) desc) as rnk, count(*), Winner from t20i 
where MarginType = 'Wickets'
group by Winner
)
select * from cte2 where rnk = 1;

-- head to head data between England and Australia
set @teamA  = 'England';
set @teamB = 'Australia';
select Winner, count(*) from t20i
where (Team1 = @teamA and Team2 = @teamB) or
(Team1 = @teamB and Team2 = @teamA)
group by Winner;

-- identify the month in 2024 where highest number of matches are played
select month(MatchDate) as MatchMonth, monthname(MatchDate) as MatchMonthName, count(*) from t20i
where year(MatchDate) = 2024
group by MatchMonth, MatchMonthName
order by count(*) desc limit 1;

-- For each team, find how manymatches they played and their win percentage
with cte4 as 
(select Team1 as Team 
from t20i 
WHERE YEAR(MatchDate) = 2024

union all

select Team2 as Team 
from t20i
WHERE YEAR(MatchDate) = 2024
),
cte5 as(
select count(*) as winnerCount, Winner 
from t20i 
where year(MatchDate) = 2024
group by Winner
),
cte6 as(
select count(*) as allCount, Team 
from cte4 
group by Team
)
select c5.winnerCount, 
c6.allCount, 
IFNULL(c5.winnerCount/c6.allCount*100,0) as WinPercentage,
Team 
from cte6 c6 
left join cte5 c5 
on c6.Team = c5.Winner
order by c6.Team;

select * from t20i;
select Ground, Winner, dense_rank() over(partition by Winner) from t20i;