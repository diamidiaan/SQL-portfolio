/*
Hotel Querry sample DATA EXPLORATION
for Powerbi visualisation
*/


--Unified dataset for powerbi visual

select * from dbo.eighteen
union
select * from dbo.nineteen
union
select * from dbo.twenty

--EDA
-- Temp table

with hotels as (select *
from dbo.eighteen
union
select * 
from dbo.nineteen
union
select *
from dbo.twenty
)
select * from hotels

-- is hotel revenue growing by year 

select arrival_date_year, sum(( stays_in_week_nights +stays_in_weekend_nights )*adr) as revenue 
from hotels
group by arrival_date_year

--

select * from hotels
left join dbo.market_segment
on hotels.market_segment = market_segment.market_segment
left join dbo.meal_cost
on meal_cost.meal = hotels.meal