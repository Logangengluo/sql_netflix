-- 15 Business Problems & Solutions
-- 1. Count the number of Movies vs TV Shows
SELECT type, count(*) 
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

SELECT type,
		rating as most_common_rating
FROM
(
	SELECT type, 
			rating, 
			count(*),
			RANK() OVER (PARTITION BY type ORDER BY count(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
	ORDER BY 1, 3 desc
) as t1
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
WHERE release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT UNNEST(STRING_TO_ARRAY(country,',')),
		COUNT(*)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT  RANK() OVER ( ORDER BY CAST(SUBSTRING(duration FROM 1 FOR POSITION (' ' IN duration)-1) AS INTEGER) DESC) AS rank_movie_duration,
		duration,
		*
FROM netflix
WHERE type ='Movie' AND duration IS NOT NULL
ORDER BY 1;


-- 6. Find content added in the last 5 years

SELECT date_added::DATE date_added_last5years,* FROM netflix
WHERE date_added::DATE BETWEEN CURRENT_DATE - INTERVAL '5 years' AND CURRENT_DATE 
ORDER BY 1;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';


8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	type = 'TV Show' AND SPLIT_PART(duration,' ',1)::INTEGER > 5;

-- 9. Count the number of content items in each genre

SELECT genre, COUNT(*)
FROM
(
	SELECT 
		listed_in,
		show_id,
		UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre
	FROM netflix
) AS tb_genre
GROUP BY 1
ORDER BY 2 DESC;

/*10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/

SELECT * FROM
(
	SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS country_new,release_year,count(*) AS num_content
	FROM netflix
	GROUP BY 1,2
) as tb
WHERE country_new LIKE '%India%'
ORDER BY num_content DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT 
		listed_in,
		show_id,
		UNNEST(STRING_TO_ARRAY(listed_in,', ')) AS genre
FROM netflix
WHERE type ='Movie' and genre = 'Ducumentaries';

-- 12. Find all content without a director

SELECT *
FROM netflix
WHERE director is NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
	actor,
	count(show_id) as num_movies_in_10yrs
FROM
(
SELECT show_id, UNNEST(STRING_TO_ARRAY(casts,', ')) AS actor
FROM netflix
WHERE date_added::DATE BETWEEN CURRENT_DATE - INTERVAL'10 years' AND CURRENT_DATE
) AS tb1
GROUP BY 1
HAVING actor = 'Salman Khan' ;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT actor, country, count(*) as num_movies
FROM
(
	SELECT show_id,
			actor,
			UNNEST(STRING_TO_ARRAY(country,', ')) AS country
	FROM
	(
		SELECT show_id, 
				UNNEST(STRING_TO_ARRAY(casts,', ')) AS actor, 
				country
		FROM netflix
	) AS tb1										-- actor array
)  AS tb2											-- country array
GROUP BY 1,2
HAVING country = 'India'
ORDER BY count(*) DESC
LIMIT 10;

/* 15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT CASE 
			WHEN description LIKE '%kill%' or description LIKE '%violence%' THEN 'Bad'
			ELSE 'Good'
		END AS category,
		count(*)
FROM netflix
GROUP BY 1;








