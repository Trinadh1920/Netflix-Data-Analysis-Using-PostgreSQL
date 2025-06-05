select * from netflix;
CREATE TABLE netflix (
    show_id TEXT PRIMARY KEY,
    type TEXT,
    title TEXT,
    director TEXT,
    casts TEXT,
    country TEXT,
    release_year INT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT,
	added_date Date,
	added_month INT,
	added_year INT
);
select * from netflix;
ALTER TABLE netflix ADD COLUMN duration_value INT;
ALTER TABLE netflix ADD COLUMN duration_type VARCHAR(30);

UPDATE netflix
SET duration_value = CAST(SPLIT_PART(duration, ' ', 1) AS INT), 
    duration_type = SPLIT_PART(duration, ' ', -1);


select count(distinct listed_in) from netflix;

--Normalizing the tables to create a data base schema

--creating table types
CREATE TABLE types (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);

-- creating table directors

CREATE TABLE directors (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);

--creating table show_directors
CREATE TABLE show_directors (
    show_id TEXT REFERENCES shows(show_id),
    director_id INTEGER REFERENCES directors(id),
    PRIMARY KEY (show_id, director_id)
);



-- creating table countries


CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

-- creating show_countries

CREATE TABLE show_countries (
    show_id TEXT REFERENCES shows(show_id),
    country_id INTEGER REFERENCES countries(id),
    PRIMARY KEY (show_id, country_id)
);

-- creating table ratings

CREATE TABLE ratings (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);

-- creating table duration_types

CREATE TABLE duration_types (
    id SERIAL PRIMARY KEY,
    type TEXT UNIQUE
);

-- creating a table for cast 

CREATE TABLE cast_members (
    id int PRIMARY KEY,
    name TEXT UNIQUE
);

--creating a table for show_cast which is used to show which cast acted in which show

CREATE TABLE show_cast (
    show_id TEXT REFERENCES shows(show_id),
    actor_id INT REFERENCES cast_members(id),
    PRIMARY KEY (show_id, actor_id)
);


-- creating main table shows
CREATE TABLE shows (
    show_id TEXT PRIMARY KEY,
    title TEXT,
    type_id INT REFERENCES types(id),
    release_year INT,
    rating_id INT REFERENCES ratings(id),
    duration_value INT,
    duration_type_id INT REFERENCES duration_types(id),
    description TEXT,
    added_date DATE
);





