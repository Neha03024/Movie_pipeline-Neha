import pandas as pd
import requests
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError
from time import sleep
import os

#  CONFIGURATION  #
DB_USER = "root"     
DB_PASSWORD = "your_sql_password"
DB_HOST = "localhost"
DB_NAME = "movie_db"
OMDB_API_KEY = "your_ombd_key"  # get from http://www.omdbapi.com/apikey.aspx

# create SQLAlchemy engine
engine = create_engine(f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}", echo=False)

#  EXTRACT  #
print("Reading CSV files...")
movies = pd.read_csv("data/movies.csv")
ratings = pd.read_csv("data/ratings.csv")

print(f"Movies loaded: {len(movies)}, Ratings loaded: {len(ratings)}")

#  TRANSFORM  #

# Split 'genres' into lists
movies["genres"] = movies["genres"].apply(lambda g: g.split("|") if isinstance(g, str) else [])

# Extract release year from title if present
import re
def extract_year(title):
    match = re.search(r'\((\d{4})\)', title)
    return int(match.group(1)) if match else None

movies["year"] = movies["title"].apply(extract_year)

# Drop duplicates just in case
movies.drop_duplicates(subset=["movieId"], inplace=True)
ratings.drop_duplicates(inplace=True)

#  ENRICH WITH OMDb  #
def fetch_omdb_data(title):
    try:
        params = {"t": title, "apikey": OMDB_API_KEY}
        r = requests.get("http://www.omdbapi.com/", params=params, timeout=10)
        data = r.json()
        if data.get("Response") == "True":
            return {
                "imdb_id": data.get("imdbID"),
                "director": data.get("Director"),
                "plot": data.get("Plot"),
                "box_office": data.get("BoxOffice"),
            }
        else:
            return {"imdb_id": None, "director": None, "plot": None, "box_office": None}
    except Exception as e:
        print(f"Error fetching {title}: {e}")
        return {"imdb_id": None, "director": None, "plot": None, "box_office": None}

print("Fetching OMDb details... (this can take a while)")
enriched_data = []
for i, row in movies.iterrows():
    omdb = fetch_omdb_data(row["title"])
    enriched_data.append(omdb)
    if i % 50 == 0:
        print(f"Fetched {i}/{len(movies)} movies...")
        sleep(1)  # avoid hitting rate limits

enriched_df = pd.DataFrame(enriched_data)
movies = pd.concat([movies, enriched_df], axis=1)

#  LOAD  #
print("Loading data into MySQL...")

# Movies table
movies_table = movies.rename(columns={
    "movieId": "movie_id",
    "title": "title",
    "imdb_id": "imdb_id",
    "plot": "plot",
    "box_office": "box_office",
    "year": "year"
})[["movie_id", "title", "year", "imdb_id", "plot", "box_office"]]

# Load movies
try:
    movies_table.to_sql("movies", con=engine, if_exists="append", index=False)
    print("Movies loaded successfully.")
except SQLAlchemyError as e:
    print("Error loading movies:", e)

# Genres table
genres_records = []
for _, row in movies.iterrows():
    for g in row["genres"]:
        genres_records.append({"movie_id": row["movieId"], "genre": g})

genres_df = pd.DataFrame(genres_records)
try:
    genres_df.to_sql("movie_genres", con=engine, if_exists="append", index=False)
    print("Genres loaded successfully.")
except SQLAlchemyError as e:
    print("Error loading genres:", e)

# Directors table
directors_records = []
for _, row in movies.iterrows():
    director = row.get("director")  # Assign first
    if director:  # Check if it's not None or empty
        for d in str(director).split(","):
            directors_records.append({"movie_id": row["movieId"], "director": d.strip()})

directors_df = pd.DataFrame(directors_records)
try:
    directors_df.to_sql("movie_directors", con=engine, if_exists="append", index=False)
    print("Directors loaded successfully.")
except SQLAlchemyError as e:
    print("Error loading directors:", e)


# Users table
users_df = pd.DataFrame(ratings["userId"].unique(), columns=["user_id"])
try:
    users_df.to_sql("users", con=engine, if_exists="append", index=False)
    print("Users loaded successfully.")
except SQLAlchemyError as e:
    print("Error loading users:", e)

# Ratings table
ratings_table = ratings.rename(columns={
    "userId": "user_id",
    "movieId": "movie_id",
    "rating": "rating",
    "timestamp": "rating_ts"
})
try:
    ratings_table.to_sql("ratings", con=engine, if_exists="append", index=False)
    print("Ratings loaded successfully.")
except SQLAlchemyError as e:
    print("Error loading ratings:", e)

print("ETL completed successfully")
