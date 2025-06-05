-- NOW CREATION OF TABLES IS COMPLETED

-- INSERT THE DATA INTO THE TABLES

-- Types
INSERT INTO types (name)
SELECT DISTINCT type
FROM netflix;


-- Directors
--for this import data from the directors.csv

select * from shows;
-- Countries
-- for this import data from the countries.csv

-- Ratings
INSERT INTO ratings (name)
SELECT DISTINCT rating
FROM netflix;

-- Duration Types
INSERT INTO duration_types (type)
SELECT DISTINCT duration_type
FROM netflix;

-- inserting the data into the main shows table
INSERT INTO shows (
    show_id, title, type_id, director_id,
    release_year, rating_id, duration_value, duration_type_id,
    description, added_date, added_month, added_year
)
SELECT
    r.show_id,
    r.title,
    t.id,
    r.release_year,
    rt.id,
    r.duration_value,
    dt.id,
    r.description,
    r.added_year
FROM netflix r
LEFT JOIN types t ON r.type = t.name
LEFT JOIN ratings rt ON r.rating = rt.name
LEFT JOIN duration_types dt ON r.duration_type = dt.type;




-- import the data into cast_members table from the casts.csv

--insert the data into show_cast table

INSERT INTO show_cast (show_id, actor_id)
SELECT DISTINCT
    n.show_id,
    c.id
FROM 
    netflix n,
    LATERAL unnest(string_to_array(n.casts, ',')) AS raw_name
JOIN 
    cast_members c ON TRIM(LOWER(c.name)) = TRIM(LOWER(raw_name));




--  insert the data into the show_countries table
INSERT INTO show_countries (show_id, country_id)
SELECT DISTINCt
    n.show_id,
    c.id
FROM 
    netflix n,
    LATERAL unnest(string_to_array(n.country, ',')) AS raw_name
JOIN 
    countries c ON TRIM(LOWER(c.name)) = TRIM(LOWER(raw_name));


-- inserting into show_directors table

INSERT INTO show_directors (show_id, director_id)
SELECT DISTINCT
    n.show_id,
    d.id
FROM 
    netflix n,
    LATERAL unnest(string_to_array(n.director, ',')) AS raw_name
JOIN 
    directors d ON TRIM(LOWER(d.name)) = TRIM(LOWER(raw_name));


