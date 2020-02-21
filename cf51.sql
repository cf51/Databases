/* F28DM CW2
username = cf51
*/ 

/*
Question 1

Question: How many female actors are listed in the dataset supplied?
Answer: 32896 

*/ 

-- Selecting the actorid (unique) and counting it where the sex is female
SELECT COUNT(actorid) AS 'Number of females actors'
FROM imdb_actors 
WHERE sex = 'F'; 

/*
Question 2

Question: What is the title of the earliest movie in the dataset? 
Answer: The Lodger 1898 

*/ 

-- Selecting the title, ordering by the year ascending (the oldest is at the top)
-- and limiting to 1 record, so the only record shown in the top (earliest movie title)
SELECT title AS 'Earliest Movie'
FROM imdb_movies
ORDER BY year ASC LIMIT 1; 

/*
Question 3

Question: How many movies have more than 5 directors?
Answer: 8 
*/

/*
 Using a subquery to select the movieid's that have more than 5 directors, then querying 
 that subquery to count the number of movieid's 
*/
SELECT COUNT(num_of_movies_over_5.counting) AS 'Movies with more than 5 directors' FROM
(SELECT COUNT(*) AS counting, movieid FROM 
imdb_movies2directors 
GROUP BY movieid
HAVING COUNT(*) > 5) num_of_movies_over_5; 

/*
Question 4

Question: Give the title of which movie has the most directors?
Answer: Fantasia (1940)
*/ 

/*
 Selecting the title, counting the directorid (number of directors). Ordering by number of 
 directors descending, so the top record has the most directors, then limiting to 1 so 
 only the top record is shown (the title of the movie with the most directors)
*/
SELECT title, COUNT(directorid) AS num_of_directors FROM imdb_movies2directors 
JOIN imdb_movies ON imdb_movies2directors.movieid = imdb_movies.movieid
GROUP BY imdb_movies2directors.movieid
HAVING COUNT(*) 
ORDER BY num_of_directors DESC limit  1; 


/*
Question 5

Question: What is the total running time of all the Sci-Fi movies in the dataset?
Answer: 2169 

*/ 

/*
 Selecting the time1, summing it to get the total time, joining the movies2direcots table 
 with movieid as the foreign key (allowing me to get the genre). Selecting where the genre
 is sci-fi
*/
SELECT SUM(time1) AS 'Total running time of all sci-fi movies'
FROM imdb_runningtimes JOIN imdb_movies2directors
ON imdb_runningtimes.movieid = imdb_movies2directors.movieid 
WHERE genre='Sci-Fi';

/*
Question 6 

Question: How many movies star both ‘Ewan McGregor’ and ‘Robert Carlyle’? (i.e. both actors are starring in the same movie)
Answer: 2 

Total number of films they have starred on individually minus 
the ones they haven't starred together on 
*/
SELECT COUNT(movieid) - COUNT(DISTINCT movieid) AS 'Number of films' FROM imdb_actors 
JOIN imdb_movies2actors ON imdb_actors.actorid = imdb_movies2actors.actorid
WHERE imdb_actors.name = "McGregor, Ewan" OR imdb_actors.name = "Carlyle, Robert (I)"; 

/*
Question 7

Question: How many actors (male / female) have worked together on 10 or more films?
Answer: 6 

*/ 

/*
 I used 4 queries for this question, 
 
 Query 1: Getting the actor name, joining on the actorid where the count on 
 the movieid is > 9. This gives you the actors that have worked on 
 10 or more films.

 Query 2: Getting the actor name as actor_name2, joining on actorid & movieid 
 where the actorname is in table 1. This shows all actors with all the other 
 actors they have worked with. 

 Query 3: Counting the actor_name2, joining with the other table where 
 actor_name2 appears more than 9 times. This shows all the actors that 
 have worked on 10 or more movies together 

 Query 4: Counting the total number of actor name, where the names in column
 1 aren't the names in column 2. This stops the problem of them being counted 
 twice, once in each column. This gives the total count of acotrs that have 
 worked together on 10 or more films.  

*/

SELECT COUNT(final_sum.number_of_actors) AS 'Number of actors' FROM
(SELECT COUNT(all_actors_10_movies.actor_name2) AS number_of_actors, imdb_actors.name FROM
imdb_actors
JOIN imdb_movies2actors ON imdb_movies2actors.actorid = imdb_actors.actorid
JOIN 

(SELECT imdb_actors.name AS actor_name2, imdb_movies.movieid 
FROM imdb_movies
JOIN imdb_movies2actors ON imdb_movies.movieid = imdb_movies2actors.movieid
JOIN imdb_actors ON imdb_movies2actors.actorid = imdb_actors.actorid
WHERE imdb_actors.name IN

(SELECT imdb_actors.name AS actor_name
FROM imdb_actors
JOIN imdb_movies2actors ON imdb_movies2actors.actorid = imdb_actors.actorid
GROUP BY actor_name
HAVING COUNT(imdb_movies2actors.movieid) >9)) AS all_actors_10_movies

ON imdb_movies2actors.movieid = all_actors_10_movies.movieid
GROUP BY all_actors_10_movies.actor_name2, imdb_actors.name
HAVING number_of_actors >9
AND imdb_actors.name < all_actors_10_movies.actor_name2) final_sum;

/*
Question 8 

Question: Assign the number of movies released per decade as 
listed below (1960-69, 1970-79, 1980-89,1990-99,2000-2010)
Answer: 1960-1969 = 192
        1970-1979 = 249
        1980-1989 = 593
        1990-1999 = 2184
        2000-2010 = 167

*/

/* 
 Using a case statement to sort the years in decades, using CONVERT as year in the movies
 table is orginally a VARCHAR so you have to convert to SIGNED (64-bit int). Counting the 
 movieid, showing the number of movies, then grouping by year_case (the decade). Ordering
 by decade ascending and limiting to 5, this stops 2011 onwards being shown. 
*/
SELECT CASE
        WHEN CONVERT(imdb_movies.year, SIGNED) BETWEEN 1960 AND 1969 THEN '1960-1969'
        WHEN CONVERT(imdb_movies.year, SIGNED) BETWEEN 1970 AND 1979 THEN '1970-1970'
        WHEN CONVERT(imdb_movies.year, SIGNED) BETWEEN 1980 AND 1989 THEN '1980-1989'
        WHEN CONVERT(imdb_movies.year, SIGNED) BETWEEN 1990 AND 1999 THEN '1990-1999'
        WHEN CONVERT(imdb_movies.year, SIGNED) BETWEEN 2000 AND 2010 THEN '2000-2010'
        ELSE '2011'
END AS year_case , COUNT(movieid) AS movies_released
FROM imdb_movies
GROUP BY year_case
ORDER BY year_case ASC LIMIT 5; 

/*
Question 9 

Question: How many movies have more female actors than male actors?
Answer: 324

*/ 
/* 
 Using 1 sub query to find the number of females in each movie, based on its movieid. 
 Using another subquery to find the number of males in each movie, based on its movieid
 Querying they two subqueries to find the movieid's where there are more females than males,
 then counting the number of movieid's, showing how many movies have more female than
 male actors. 

*/

-- Counting all just now, will be specified in the WHERE
SELECT COUNT(*) AS 'Movies with more females than males' FROM
-- Selecting the movieid, couting the sex where they are females 
(SELECT movieid, COUNT(sex) AS females_count
FROM imdb_actors 
-- Joining movies2actors with actorid as the primary key (allowing me to get the movieid)
JOIN imdb_movies2actors ON imdb_actors.actorid = imdb_movies2actors.actorid  
WHERE sex = 'F'
-- Grouping by the movieid to see the number of females for each movie 
GROUP BY movieid
) AS sub_query_f
JOIN 
-- Selecting the movieid, couting the sex where they are males 
(SELECT movieid, COUNT(sex) AS males_count
FROM imdb_actors 
-- Joining movies2actors with actorid as the primary key (allowing me to get the movieid)
JOIN imdb_movies2actors ON imdb_actors.actorid = imdb_movies2actors.actorid  
WHERE sex = 'M' 
-- Grouping by the movieid to see the number of males for each movie 
GROUP BY movieid) AS sub_query_m 
ON sub_query_f.movieid = sub_query_m.movieid
-- Selecting where count of females from the female subquery is greater than the count of
-- males from the male subquery 
WHERE sub_query_f.females_count > sub_query_m.males_count; 


/*
Question 10 

Question: Based ratings with 10,000 or more votes, 
what is the top movie genre using the average rank per movie genre as the metric?
(Note: where a higher value for rank is considered a better movie)

Answer: Film-Noir

*/ 

-- Selecting the genre, using AVG to get the average rank
SELECT genre,  AVG(rank) AS avg_rank FROM imdb_movies2directors 
-- Joining imdb ratings with movieid as the foreign key (allowing me to get the votes)
JOIN imdb_ratings ON imdb_movies2directors.movieid = imdb_ratings.movieid
-- Selecting ratings with 10,000 votes or more 
WHERE votes >= 10000
-- Grouping by genre as we want to see highest ranked movie genre 
GROUP BY genre 
-- Ordering by avg_rank descending, so the highest is at the top and limiting to 1
-- So the only record shown is the top which is the top ranked genre 
ORDER BY avg_rank DESC limit 1; 
 

/*
Question 11 

Question: List any actors (male/female) that have starred in 10 or more different film genres. 
Answer: Peck, Gregory

*/

/* 
 Using a subquery to show all of the actors in the database and the different film 
 genres that thye have starred on. Then I query that subquery to find all of the names 
 that appear 10 or more times. This gives me the actors/actresses that have worked on 10 
 or more different film genres 
*/ 

-- Selecting the name as its all that is required for the answer 
SELECT name FROM
(SELECT name, genre FROM imdb_movies2actors
-- Joining movies2directors table with movieid as the foreign key (allowing me to get the genre)
JOIN imdb_movies2directors ON imdb_movies2actors.movieid = imdb_movies2directors.movieid
-- Joining actors table with actorid as the foreign key (allowing me to get name)
JOIN imdb_actors ON imdb_movies2actors.actorid = imdb_actors.actorid
GROUP by name, genre) show_all_query 
GROUP BY name
-- Selecting names that appear 10 or more times 
HAVING COUNT(name) >= 10; 


/*
Question 12 

Question: How many movies have an actor/actress that also wrote and directed the movie?
Answer: 324

*/ 

-- Selecting the movies title, counting to know how many there are and using DISTINCT to avoid duplicates
SELECT COUNT(DISTINCT imdb_movies.title) AS 'Actors that also wrote and directed the movie' FROM imdb_movies
-- Joining the movie2directors table with movieid as the foreign key (allowing me to next access the director table)
JOIN imdb_movies2directors ON imdb_movies.movieid = imdb_movies2directors.movieid
-- Joining the directors table with directorid as the foreign key (allowing me to next compare the director name)
JOIN imdb_directors ON imdb_movies2directors.directorid = imdb_directors.directorid
-- Joining the writers table with the name as the foreign key (comparing writer and director name)
JOIN imdb_writers ON imdb_directors.name = imdb_writers.name
-- Joining the movie2writers table with movieid as the foreign key (allowing me to check that it is the same movie)
JOIN imdb_movies2writers ON imdb_movies.movieid = imdb_movies2writers.movieid
-- Joining the actors table with name as the foreign key (comparing the actor and writer name)
JOIN imdb_actors ON imdb_writers.name = imdb_actors.name
-- Joining the movie2actors table with actorid as the foreign key (allowing me to check the actor is on the same movie)
JOIN imdb_movies2actors ON imdb_actors.actorid = imdb_movies2actors.actorid
-- Selecting where the writerid are equal and the movieid are equal (Meaning they have wrote, acted and directed the same movie)
WHERE imdb_writers.writerid = imdb_movies2writers.writerid  AND imdb_movies.movieid = imdb_movies2actors.movieid; 


/*
Question 13

Question: Which decade has the highest average ranked movies? (put the first year from the decade, so for 1900-1909 you would put 1900) 
Answer: 1930s - 7.2 

*/ 

/*
 Using a case statement to split the years into decades, using AVG on rank to find the average rank for that movie
 joining the movies table with movieid as the foreign key (allowing me to get the year). Grouping by the year case
 statement (decade) rather than each individual rank, then ordering by avg_rank DESC (highest is at top) then 
 limiting to 1 so only the top record is shown (the highest ranked movie)
*/

SELECT CASE 
        WHEN year BETWEEN 1890 AND 1899 THEN '1890s'
        WHEN year BETWEEN 1900 AND 1909 THEN '1900s'
        WHEN year BETWEEN 1910 AND 1919 THEN '1910s'
        WHEN year BETWEEN 1920 AND 1929 THEN '1920s'
        WHEN year BETWEEN 1930 AND 1939 THEN '1930s'
        WHEN year BETWEEN 1940 AND 1949 THEN '1940s'
        WHEN year BETWEEN 1950 AND 1959 THEN '1950s'
        WHEN year BETWEEN 1960 AND 1969 THEN '1960s'
        WHEN year BETWEEN 1970 AND 1979 THEN '1970s'
        WHEN year BETWEEN 1980 AND 1989 THEN '1980s'
        WHEN year BETWEEN 1990 AND 1999 THEN '1990s'
        WHEN year BETWEEN 2000 AND 2009 THEN '2000s'
        WHEN year BETWEEN 2010 AND 2019 THEN '2010s'
        ELSE '2020'
END AS year_case ,  AVG(rank) AS avg_rank
FROM imdb_ratings 
JOIN imdb_movies ON imdb_ratings.movieid = imdb_movies.movieid
GROUP BY year_case
ORDER BY avg_rank DESC LIMIT 1; 



/*
Question 14 

Question: How many movies are missing a genre in the dataset?
Answer: 14 

*/ 

-- Selecting the title, counting to know how many and using distict to avoid duplicates
SELECT COUNT(DISTINCT title) AS 'Number of movies missing a genre' FROM imdb_movies2directors
-- Joining movies2directors with movieid as the foreign key (allowing me to get the title and the genre)
JOIN imdb_movies 
ON imdb_movies2directors.movieid = imdb_movies.movieid
-- Selecting where the genre IS null, using IS rather than '=' as NULL is not equal to anything 
WHERE genre IS NULL; 



/*
Question 15 

Question: how many movies have an actor/actress written and directed but not starred in? (i.e.
the person that wrote and directed the movie is an actor/actress but they didn't star
in their own movie)
Answer: 531

*/ 

-- Selecting the movies title, counting to know how many there are and using DISTINCT to avoid duplicates
SELECT COUNT(DISTINCT imdb_movies.title) AS 'Actors that wrote, directed but didnt star in' FROM imdb_movies
-- Joining the movie2directors table with movieid as the foreign key (allowing me to next access the director table)
JOIN imdb_movies2directors ON imdb_movies.movieid = imdb_movies2directors.movieid
-- Joining the directors table with directorid as the foreign key (allowing me to next compare the director name)
JOIN imdb_directors ON imdb_movies2directors.directorid = imdb_directors.directorid
-- Joining the writers table with the name as the foreign key (comparing writer and director name)
JOIN imdb_writers ON imdb_directors.name = imdb_writers.name
-- Joining the movie2writers table with movieid as the foreign key (allowing me to check that it is the same movie)
JOIN imdb_movies2writers ON imdb_movies.movieid = imdb_movies2writers.movieid
-- Joining the actors table with name as the foreign key (comparing the actor and writer name)
JOIN imdb_actors ON imdb_writers.name = imdb_actors.name
-- Joining the movie2actors table with actorid as the foreign key (allowing me to check the actor is on the same movie)
JOIN imdb_movies2actors ON imdb_actors.actorid = imdb_movies2actors.actorid
-- Selecting where the writerid are equal and the movieid are NOT equal (Meaning they have wrote, directed but did not act in the same movie)
WHERE imdb_writers.writerid = imdb_movies2writers.writerid AND imdb_movies.movieid <> imdb_movies2actors.movieid; 
