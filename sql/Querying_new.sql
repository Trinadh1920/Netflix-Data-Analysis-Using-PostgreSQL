--querying
select * from shows;
--1)How many shows are there in total?
select count(*) as no_of_shows from shows;

--2)List all movies released in the year 2020.

select s.title from shows s inner join types t on s.type_id = t.id
where t.name = 'movie' and s.release_year = 2020;

-- 3) Find the total number of shows for each type (Movie/TV Show).

select t.name as Type_Of_Show , count(*) as No_Of_Shows from shows s  
inner join types t on s.type_id=
t.id  group by t.name ;

                      -- or with out join
	
select type_id as show_type, count(*) as No_Of_Shows from shows  
 group by type_id ;           


-- 4) List distinct ratings available in the dataset.

select distinct name  from  ratings;

--5)Find the number of shows associated with each country
--(using normalized countries and show_countries)?

select c.name as Country_Name,count(*) as No_Of_Shows from shows s 
inner join show_countries sc  on s.show_id = sc.show_id 
inner join countries c on sc.country_id = c.id group by c.name order by  No_Of_Shows desc;


--6) Which directors have the highest number of shows on Netflix?
select name as director_name, count(*) as No_Of_Shows from directors inner join show_directors on id = director_id 
where name not ilike 'unknown'group by name order by No_Of_Shows desc;

--7) List the top 5 actors who acted in the most number of shows.

select name as actor_name, count(*) as No_Of_Shows from cast_members inner join show_cast on id = actor_id 
where name not ilike 'unknown'group by name order by No_Of_Shows desc limit 5;

--8) Which countries have produced the most TV Shows? (Use show_countries, countries, and netflix)

select c.name as country_name ,count(*)as No_Of_Tv_Shows from countries c inner join show_countries sc on c.id = sc.country_id
inner join shows s on s.show_id = sc.show_id
inner join types t on s.type_id = t.id 
where c.name not ilike 'unknown' and t.name ilike 'tv show' group by c.name order by No_Of_Tv_Shows desc;

-- 9) Find the average duration (in minutes) of movies by rating.

select r.name as Type_Of_Rating ,(concat(cast(round(avg(s.duration_value),3)as text),' min')) as Avg_Duration_Of_Movies_In_This_Rating from shows s
inner join types t on s.type_id=t.id
inner join ratings r on  s.rating_id = r.id
inner join duration_types dt on s.duration_type_id = dt.id
where t.name ilike 'movie' and dt.type ilike 'min'
group by r.name ;


-- 10)Show the number of shows added each year (based on added_year).

select added_year as Year_added , count(*) as No_Of_Shows_Added_In_That_Year
from shows group by added_year ;

-- 11) Which actors have appeared in both Movies and TV Shows?


								    

SELECT cm.name AS actor_name
FROM cast_members cm
JOIN show_cast sc ON cm.id = sc.actor_id
JOIN shows s ON s.show_id = sc.show_id
JOIN types t ON s.type_id = t.id
WHERE cm.name NOT ILIKE 'unknown'
GROUP BY cm.name
HAVING COUNT(DISTINCT t.name) > 1;



-- 12)Find the shows with more than 3 actors.
select s.title as show ,count(distinct sc.actor_id) as No_Of_Actors  from shows as s
join show_cast as sc on s.show_id = sc.show_id
group by s.show_id
having count(distinct sc.actor_id)>=3 
order by No_Of_Actors desc;

--13)List all shows directed by directors who have directed more than 5 shows.

select s.title as Show_Name ,d.name as Director_Name 
from shows  as s 
join show_directors as sd on s.show_id = sd.show_id 
join directors as d on sd.director_id = d.id
where d.name not ilike 'unknown'
and d.id in(
select director_id 
from show_directors
group by director_id
having count(distinct show_id)>5
);


--14)Find the most common release year for shows.
select release_year,count(*)as no_of_shows_released from shows 
group by release_year order by count(*) desc limit 1;

--15)List all shows with actors whose names start with ‘A’.
select  s.title,cm.name as Actor_name from shows as s
join show_cast as sc on  s.show_id = sc.show_id
join cast_members as cm on sc.actor_id = cm.id
where cm.name ilike 'A%';


-- 16) Using a window function, rank shows by release year within each country (via show_countries).

select c.name,s.title,s.release_year,dense_rank() over(partition by c.name order by release_year) as rank
from shows as s inner join show_countries as sc on 	
s.show_id = sc.show_id
inner join countries as c on sc.country_id = c.id 
where c.name not ilike 'unknown'
order by c.name ,s.release_year



-- 17) Create a CTE to find shows that are both directed and acted by the same person.
with directors_joined as (
select s.show_id,s.title,d.name as director_name ,cm.name as actor_name from shows as s
inner join show_directors as sd on s.show_Id = sd.show_id 
inner join directors as d on sd.director_id = d.id 
inner join show_cast as sc on s.show_id = sc.show_id 
inner join cast_members as cm on sc.actor_id = cm.id where cm.name not ilike 'unknown'  and d.name not ilike 'unknown'
order by s.show_id
)

select show_Id,title, director_name as director_and_actor from directors_joined where director_name = actor_name


--18)Find  shows added in the same month over different years.
with dates as (
select show_id,title,to_char(added_date,'mm') as month,to_char(added_date,'yyyy') as year
from shows order by show_id 
)

select * from dates order by month,year;


-- 19) Determine the 3 most frequently cast actors per country (via show_cast, cast_members, show_countries).

with cte as (
select  cm.name as actor_name,c.name as country ,
count( sco.show_id)as no_of_shows,
dense_rank() over(partition by c.name order by count( sco.show_id) desc) as rank
from show_cast as sc 
inner join cast_members as cm on sc.actor_id = cm.id
inner join show_countries as sco on sc.show_id = sco.show_id
inner join countries as c on sco.country_id = c.id
where c.name not ilike 'unknown' and cm.name not ilike 'unknown'
group by country,actor_name
order by country desc,no_of_shows desc
)

select * from cte where rank <=3


-- 20) List the top 10 countries with the longest total movie durations.

select 
c.name as country_name ,sum(s.duration_value)||' min' as total_movies_duration_length 
from shows s 
inner join duration_types dt on s.duration_type_id = dt.id
inner join show_countries sc on sc.show_id = s.show_id
inner join countries c on c.id = sc.country_id
inner join types as t on s.type_id = t.id
where dt.type ='min' and c.name not ilike 'unknown' 
group by c.name
order by sum(s.duration_value)::numeric desc
limit 10



--21) Write a query to identify “one-hit” directors (those with only one show).
with cte as (
select director_id from show_directors group by director_id having count(distinct show_id)=1
)
select   d.name from directors as  d inner join cte as c on d.id = c.director_id 
where d.name not ilike 'unknown'
order by d.name


--22) Use a window function to find movies with the longest duration per release year .

with cte as (
select  s.title,s.duration_value,s.release_year,dense_rank()over(partition by s.release_year order by s.duration_value desc) as rank
from shows s 
inner join duration_types dt on s.duration_type_id = dt.id
where dt.type ilike 'min' 
)
select title as movie,duration_value||' min' as duration_of_movie,release_year  from cte where rank = 1

--23 )Find all actors who appear in more than one show with the same director
select d.name as director,cm.name as actor , count( s.show_id) as no_of_Shows_together
from shows as s 
inner join show_directors as sd on s.show_id = sd.show_id
inner join directors as d on sd.director_id = d.id
inner join show_cast as sc on s.show_id = sc.show_id
inner join cast_members as cm on sc.actor_id = cm.id
where d.name not ilike 'unknown' and cm.name not ilike 'unknown'
group by d.name,cm.name 
having count( s.show_id)>1 
order by no_of_shows_together desc

--24) Create a procedure that accepts a year and returns all shows added that year.

CREATE OR REPLACE PROCEDURE get_shows_by_year(target_year INT)
LANGUAGE plpgsql
AS $$
DECLARE
    record RECORD;  -- This declares a generic row-type variable
BEGIN
    -- Print the year
    RAISE NOTICE 'Shows added in %:', target_year;

    -- Loop over query results and print each one
    FOR record IN
        SELECT title, added_date
        FROM shows
        WHERE to_char(added_date,'YYYY') = target_year::text
    LOOP
        RAISE NOTICE 'Title: %, Added Date: %', record.title, record.added_date;
    END LOOP;
END;
$$;

call get_shows_by_year(2020);


-- 25) List shows where the same actor appears multiple times.

SELECT 
    s.title AS show_title,
    cm.name AS actor_name,
    COUNT(*) AS appearances
FROM 
    show_cast sc
JOIN shows s ON sc.show_id = s.show_id
JOIN cast_members cm ON sc.actor_id = cm.id
GROUP BY 
    s.title, cm.name
HAVING 
    COUNT(*) > 1
ORDER BY 
    appearances DESC;
 
