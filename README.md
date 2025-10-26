----------------------------------------- Movie Data Pipeline------------------------------

------------------------------------------   Overview     ------------------------------------

This project simulates a real-world data engineering pipeline — taking raw movie data, enriching it with external metadata, and transforming it into analytical insights stored in a MySQL database.

The goal was to build a simple yet realistic system that:

1.Extracts movie and rating data from local CSV files (MovieLens dataset)

2.Enriches each movie with details from the OMDb API (director, plot, box office, etc.)

3.Cleans, transforms, and loads the data into MySQL

4.Enables SQL queries to uncover insights about ratings, genres, and directors

In short: it’s a complete journey from raw data → enriched data → insights.

------------------------------------------ Project Structure --------------------------------

movie_pipeline/
├── etl.py          # Python ETL script (Extract, Transform, Load)
├── schema.sql      # MySQL database schema
├── queries.sql     # Analytical SQL queries
├── README.md       # Project documentation
└── data/
    ├── movies.csv
    └── ratings.csv

------------------------------------------Tools and Frameworks-----------------------------

Programming   - Python 3,
Libraries	  - pandas, requests, SQLAlchemy, mysql-connector-python,
Database	  - MySQL,
External API  - OMDb API (Open Movie Database),
Dataset	      - MovieLens “small” dataset

------------------------------------------Setup & How to Run the Project-------------------

1️. Set Up Your Environment

Make sure Python 3.8 is installed in the system, along with MySQL Server.
we also need an OMDb API key — it’s free and can be generated from http://www.omdbapi.com/

2️. Install the Required Libraries

Once repository is cloned, open a terminal inside the project folder and install the dependencies:

pip install pandas sqlalchemy mysql-connector-python requests


3️. Create the Database

Launch MySQL and create a new database for this project:

CREATE DATABASE movie_db;

Then, load the provided schema:

mysql -u root -p movie_db < schema.sql

4️. Add the Data Files

Download the MovieLens “small” dataset from https://grouplens.org/datasets/movielens/latest/

Once downloaded, copy the movies.csv and ratings.csv files into the data/ folder of this project.

the folder should now look like this:

movie_pipeline/
└── data/
    ├── movies.csv
    └── ratings.csv


5️. Configure and Run the ETL Pipeline

Before running the script, open etl.py and update your credentials:

DB_PASSWORD = "your_mysql_password"
OMDB_API_KEY = "your_omdb_api_key"

Now run the ETL script:

python etl.py

This will:

1.Read and clean the MovieLens CSV files

2.Enrich each movie with extra details from the OMDb API

3.Handle missing or inconsistent records gracefully

4.Load the final, cleaned dataset into your MySQL database


----------------------------------------------Running Analytical Queries--------------------------------

Once data is loaded, execute:

mysql -u root -p movie_db < queries.sql

This will produce insights such as:

1. The highest-rated movie

2. Top 5 genres by rating

3. Director with the most movies

4. Average rating by release year

-----------------------------------------------Design Choices------------------------------------------

1.Normalized Database Schema:
Separate tables for movies, genres, and directors to maintain flexibility and prevent redundancy.

2.Idempotent Loading:
The ETL can be rerun multiple times without creating duplicate records.

3.Error Handling:
Wrapped API requests and database operations in try/except blocks to ensure graceful recovery from errors.

4.Performance Optimization:
Added indexes on movie_id and year for faster joins and aggregations.

5.Extensibility:
The schema is designed so that future datasets can be integrated easily.

----------------------------------------------Challenges and Solutions----------------------------------

1.Missing or inconsistent movie titles between MovieLens and OMDb:
Implemented fallback logic to skip failed lookups without interrupting the pipeline

2.OMDb API rate-limiting:
Added short sleep() delays between API calls

3.Inconsistent data types across sources:
Explicitly converted numeric, string, and date fields

4.Duplicate data handling:
Used primary keys and controlled inserts to prevent reloading duplicates

5.Schema relationships:
Designed normalized tables with foreign keys to maintain data integrity

---------------------------------------------Improvements Made During Development----------------------------

1.Graceful Handling of Missing Data:
Ensured incomplete API responses don’t break the ETL — they’re logged and safely skipped.

2.Robust Error Handling:
Added try/except for API calls and SQL inserts to prevent crashes.

3.Rate-Limit Compliance:
Introduced short delays between OMDb requests to avoid throttling.

4.Idempotent Data Loading:
Designed the logic so re-running the ETL won’t duplicate rows.

5.Type Validation and Cleaning:
Ensured numeric, text, and date consistency before loading to SQL.

6.Performance Indexing:
Added indexes on key columns to speed up joins and analytical queries.


---------------------------------------------Future Enhancements--------------------------------

1.API Caching:
Store OMDb responses locally to reduce repeated API calls.

2.Batch Inserts:
Use bulk inserts for faster loading of large datasets.

3.Visualization Dashboard:
Add Power BI, Tableau, or Streamlit dashboards for richer exploration.

4.Automation:
Schedule ETL jobs using Apache Airflow or cron.

5.Cloud Migration:
Migrate storage and analytics to a cloud warehouse (e.g., Snowflake or BigQuery).

----------------------------------------------Results------------------------------------------

1.Successfully extracted, enriched, and loaded movie data into a structured SQL database.

2.SQL queries produce accurate, meaningful insights.

3.The ETL pipeline is reliable, repeatable, and easily extendable.
