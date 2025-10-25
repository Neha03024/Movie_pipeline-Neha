-- schema.sql
-- Idempotent schema: drops and recreates tables for a clean run.
-- NOTE: in production you wouldn't drop tables blindly; this is for assignment/testing simplicity.

DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS movie_directors;

-- 2. Drop the parent tables last
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;

-- Movies table: basic movie metadata + enrichment fields from OMDb
CREATE TABLE movies (
    movie_id INT PRIMARY KEY,             -- from MovieLens
    title VARCHAR(255) NOT NULL,
    year INT,
    imdb_id VARCHAR(20),                  -- if available from OMDb / mapping
    plot TEXT,
    box_office VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Genres normalized: many-to-many via movie_genres
CREATE TABLE movie_genres (
    movie_id INT,
    genre VARCHAR(100),
    PRIMARY KEY (movie_id, genre),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- Directors normalized: allows multiple directors per movie if needed
CREATE TABLE movie_directors (
    movie_id INT,
    director VARCHAR(255),
    PRIMARY KEY (movie_id, director),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- Users table (minimal; MovieLens has user_ids in ratings.csv)
CREATE TABLE users (
    user_id INT PRIMARY KEY
);

-- Ratings table
CREATE TABLE ratings (
    user_id INT,
    movie_id INT,
    rating FLOAT,
    rating_ts BIGINT,       -- keep original timestamp; convert to datetime when needed
    PRIMARY KEY (user_id, movie_id, rating_ts), -- makes the load idempotent if we treat same triple as duplicate
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

-- Useful indexes for analytical queries
CREATE INDEX idx_ratings_movie ON ratings(movie_id);
CREATE INDEX idx_movies_year ON movies(year);


