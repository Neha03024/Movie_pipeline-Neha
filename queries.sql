-- 1️⃣  Which movie has the highest average rating?
SELECT 
    m.title,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM 
    ratings r
JOIN 
    movies m ON r.movie_id = m.movie_id
GROUP BY 
    m.movie_id
ORDER BY 
    avg_rating DESC
LIMIT 1;

-- 2️⃣  What are the top 5 movie genres with the highest average rating?
SELECT 
    mg.genre,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(DISTINCT m.movie_id) AS movie_count
FROM 
    movie_genres mg
JOIN 
    movies m ON mg.movie_id = m.movie_id
JOIN 
    ratings r ON r.movie_id = m.movie_id
GROUP BY 
    mg.genre
HAVING 
    movie_count > 5 -- skip tiny genres to avoid bias
ORDER BY 
    avg_rating DESC
LIMIT 5;

-- 3️⃣  Who is the director with the most movies?
SELECT 
    md.director,
    COUNT(DISTINCT md.movie_id) AS total_movies
FROM 
    movie_directors md
GROUP BY 
    md.director
ORDER BY 
    total_movies DESC
LIMIT 1;

-- 4️⃣  What is the average rating of movies released each year?
SELECT 
    m.year,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(DISTINCT m.movie_id) AS movie_count
FROM 
    movies m
JOIN 
    ratings r ON m.movie_id = r.movie_id
WHERE 
    m.year IS NOT NULL
GROUP BY 
    m.year
ORDER BY 
    m.year ASC;
