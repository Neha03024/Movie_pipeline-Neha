-- 1.  Which movie has the highest average rating?

SELECT title, AVG(rating) AS avg_rating
FROM movies
JOIN ratings USING (movie_id)
GROUP BY title
ORDER BY avg_rating DESC
LIMIT 1;


-- 2. What are the top 5 movie genres with the highest average rating?

SELECT genre, ROUND(AVG(rating), 2) AS avg_rating
FROM movie_genres
JOIN ratings USING (movie_id)
GROUP BY genre
ORDER BY avg_rating DESC
LIMIT 5;

-- 3. Who is the director with the most movies?

SELECT director, COUNT(movie_id) AS total_movies
FROM movie_directors
GROUP BY director
ORDER BY total_movies DESC
LIMIT 5;

-- 4️ What is the average rating of movies released each year?

SELECT year, ROUND(AVG(rating), 2) AS avg_rating
FROM movies
JOIN ratings USING (movie_id)
WHERE year IS NOT NULL
GROUP BY year
ORDER BY year;



