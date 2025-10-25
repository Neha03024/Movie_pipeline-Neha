
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS movie_directors;

DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;

-- Movies table:
CREATE TABLE movies (
    movie_id INT PRIMARY KEY,             
    title VARCHAR(255) NOT NULL,
    year INT,
    imdb_id VARCHAR(20),                
    plot TEXT,
    box_office VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Genres normalized:
CREATE TABLE movie_genres (
    movie_id INT,
    genre VARCHAR(100),
    PRIMARY KEY (movie_id, genre),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- Directors normalized: 
CREATE TABLE movie_directors (
    movie_id INT,
    director VARCHAR(255),
    PRIMARY KEY (movie_id, director),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- Users table :
CREATE TABLE users (
    user_id INT PRIMARY KEY
);

-- Ratings table
CREATE TABLE ratings (
    user_id INT,
    movie_id INT,
    rating FLOAT,
    rating_ts BIGINT,       
    PRIMARY KEY (user_id, movie_id, rating_ts), 
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- Useful indexes for analytical queries
CREATE INDEX idx_ratings_movie ON ratings(movie_id);
CREATE INDEX idx_movies_year ON movies(year);


