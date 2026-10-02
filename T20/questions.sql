select * from T20i;

alter table T20i add Marginvalue int;
alter table T20i add MarginType varchar(20);
UPDATE T20i
SET Marginvalue = cast(substring_index(Margin,' ',1) as signed)
where Margin != '-';
UPDATE T20i
SET MarginType = cast(substring_index(Margin,' ',-1) as char)
where Margin != '-';
select distinct(MarginType) from T20i;
UPDATE T20i
SET MarginType = REPLACE(MarginType, 'run', 'runs')
WHERE MarginType LIKE 'run';

-- give all the matches playes between india and south africa in 2024
select * from T20i where
((Team1 = 'South Africa' and Team2 = 'India')
or 
(Team1 = 'India' and Team2 = 'South Africa'))
and year(MatchDate) = 2024;

-- top team who won most matches in 2024
select Winner, count(*) as CountOfWins from T20i 
where year(MatchDate) = 2024 
group by Winner order by CountOfWins desc limit 1;

-- ranking of teams who won most to least matches in 2024
select dense_rank() over(order by count(*) desc) as RankOfTeam, 
Winner, count(*) as CountOfWins 
from T20i where year(MatchDate) = 2024 and winner not in ('tied','no result')
group by Winner order by CountOfWins desc;

-- which team has the highest average winning margin in runs and what is the average margin
select Winner , 
round(avg(cast(TRIM(SUBSTRING_INDEX(Margin, 'r', 1)) as signed)),1) as avg_run 
from T20i
where Margin like '% runs' 
group by Winner
order by avg_run desc
limit 1;

-- which team has the highest average winning margin in wickets and what is the average margin
select Winner , 
round(avg(cast(TRIM(SUBSTRING_INDEX(Margin, 'r', 1)) as signed)),1) as avg_wicket
from T20i
where Margin like '% wickets' 
group by Winner
order by avg_wicket desc
limit 1;

-- list all the matches where the winning margins was greater than average margin
with cte as 
(
select *,
avg(marginvalue) over(partition by MarginType) as marginaverage
from T20i
)
select Winner, MatchDate, Margin from cte where Marginvalue > marginaverage;

-- team with most wins when chasing a target (win by wickets)
with cte2 as(
select dense_rank() over(order by count(*) desc) as rnk, count(*), Winner from T20i 
where MarginType = 'Wickets'
group by Winner
)
select * from cte2 where rnk = 1;

-- head to head data between England and Australia
set @teamA  = 'England';
set @teamB = 'Australia';
select Winner, count(*) from T20i
where (Team1 = @teamA and Team2 = @teamB) or
(Team1 = @teamB and Team2 = @teamA)
group by Winner;

-- identify the month in 2024 where highest number of matches are played
select month(MatchDate) as MatchMonth, monthname(MatchDate) as MatchMonthName, count(*) from T20i
where year(MatchDate) = 2024
group by MatchMonth, MatchMonthName
order by count(*) desc limit 1;

-- For each team, find how manymatches they played and their win percentage
with AllTeams as 
(select Team1 as Team 
from T20i 
WHERE YEAR(MatchDate) = 2024

union all

select Team2 as Team 
from T20i
WHERE YEAR(MatchDate) = 2024
),
CWinnerCount as(
select count(*) as winnerCount, Winner 
from T20i 
where year(MatchDate) = 2024
group by Winner
),
CAllCount as(
select IFNULL(count(*),0) as allCount, Team 
from AllTeams 
group by Team
)
select Team,
cac.allCount, 
IFNULL(cwc.winnerCount,0), 
IFNULL(cwc.winnerCount/cac.allCount*100,0) as WinPercentage
from CAllCount cac 
left join CWinnerCount cwc 
on cac.Team = cwc.Winner
order by cac.Team;

select * from T20i;

-- Most successful team in each Ground
with WinCountFilter as
(
select Ground, Winner, count(*) as winCount 
from T20i 
where Winner not in ('no result', 'tied') 
group by Ground,Winner
),
RankByWin as
(
select Ground, Winner, winCount, 
dense_rank() over(partition by Ground order by winCOunt desc) as dense_rank1 
from WinCountFilter
)
select Ground, Winner, winCount 
from RankByWin 
where dense_rank1 = 1;