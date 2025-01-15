create Database NetflixDB;
use NetflixDB;
select * from netflix_titles;

# 1. Count the number of Movies vs TV Shows
select type,count(*) from netflix_titles group by type;

# 2. Find the most common rating for movies and TV shows

with MainCommonRating as(
with CommonRating as(
	select type,rating,count(*) as RatingCount from netflix_titles group by Type,rating order by count(*) desc)
	select type,rating,
	rank() over(partition by type order by RatingCount desc) as RankRating
	from commonRating
	group by type,rating)
select * from MainCommonRating where RankRating = '1';

# 3. List all movies released in a specific year (e.g., 2020)

select Type,title,director,cast,release_year,rating from netflix_titles 
where release_year = '2020' and type = 'Movie';

# 4. Find the top 5 countries with the most content on Netflix
select * from netflix_titles;

with Top5Country as(
select 
-- substring_Index(country,',',1),
show_Id,
TRIM(substring_Index(substring_Index(country,',',n.n),',',-1)) as Country_Split
from netflix_titles join (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
          UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
          on CHAR_LENGTH(country)-CHAR_LENGTH(REPLACE(country, ',', '')) >= n.n-1
)
select country_split,count(show_Id) from Top5Country where country_split is not null
group by country_split order by count(show_Id) desc limit 5;

select country,CHAR_LENGTH(country),CHAR_LENGTH(country)-CHAR_LENGTH(REPLACE(country, ',', '')) from netflix_titles group by country;

# 5. Identify the longest movie

select max(cast(substring_Index(duration,' ',1) as decimal))as Longest_Movie from netflix_titles where type = 'Movie';

# 6. Find content added in the last 5 years

select *,YEAR(str_to_date(date_added,'%M %d,%Y')) as Date_Added_Test from netflix_titles
where Year(str_to_date(date_added,'%M %d,%Y')) >= year(current_date())-5;

# 7. Find all the movies/TV shows by director 'Ashwiny Iyer Tiwari'!
select * from netflix_titles where director = 'Ashwiny Iyer Tiwari';
select distinct director from netflix_titles;

with Flim_Director as(
select show_id,
	trim(substring_index(substring_index(director,',',n.n),',',-1)) as director_name
from netflix_titles
    join (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
          UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
          on char_length(director)-char_length(replace(director,',',' ')) >= n.n-1
) select FD.show_id,nt.* from Flim_Director FD join netflix_titles nt on nt.show_id = FD.Show_ID
where director_name = 'Ashwiny Iyer Tiwari';

# 8. List all TV shows with more than 5 seasons
select * from netflix_titles where substring_index(duration,' ',1) > 5 and type = 'TV Show';

# 9. Count the number of content items in each genre

# 10. Find each year and the average numbers of content release in India on netflix. 
# return top 5 year with highest avg content release!
select show_id,release_year from netflix_titles where country = 'India';

select country,release_year,count(show_Id)/
((select count(show_id) from netflix_titles where country = 'India')*100) as AVG_
from netflix_titles where country = 'India' group by country,release_year
order by AVG_ desc;

# 11. List all movies that are documentaries
select * from netflix_titles where listed_in like 'Documentaries%';

# 12. Find all content without a director
select * from netflix_titles where trim(director) = '' or director is null;

# 13. Find how many movies actor 'Vijay Sethupathi' appeared in last 10 years!
select * from netflix_titles where cast like '%Vijay Sethupathi%';

# 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select cast from netflix_titles;
select cast,substring_Index(cast,',',-1),char_length(cast)-char_length(replace(cast,',',''))
from netflix_titles;

with Cast_Names as (
select country,
trim(substring_index(substring_Index(cast,',',n.n),',',-1)) as Cast_Distinct
from netflix_titles join
(
select 1 as n union select 2 as n union select 3 as n union select 4 as n union
select 5 as n union select 6 as n union select 7 as n union select 8 as n 
union select 9 union select 10) n 
on char_length(cast)-char_length(replace(cast,',','')) >= n.n-1)
select cast_distinct,count(*) from Cast_Names where country = 'India' and cast_distinct <> ''
group by cast_distinct
order by count(*) desc
limit 10;

# 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
# the description field. Label content containing these keywords as 'Bad' and all other 
# content as 'Good'. Count how many items fall into each category.
select * from netflix_titles;
select `type`,count(*),
	case when description like '%kill%' or description like '%violence%' then 'Bad Content'
		 else 'Good Content'
    end as 'Content Split'
from netflix_titles
group by 1,3
order by 2;