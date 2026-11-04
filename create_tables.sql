SELECT VERSION();



use fifa_ranks;
LOAD DATA LOCAL INFILE 'C:/Users/neyma/OneDrive/Documents/CMP 420/shootouts.csv'
INTO TABLE shootouts
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


CREATE TABLE results(
match_date date,
home_team varchar(100),
away_team varchar(100),
home_score int,
away_score int,
tournament varchar(100),
city varchar(100),
country varchar(100),
neautral varchar(100) );

LOAD DATA LOCAL INFILE 'C:/Users/neyma/OneDrive/Documents/CMP 420/results.csv'
INTO TABLE results
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/neyma/OneDrive/Documents/CMP 420/shootouts.csv'
INTO TABLE shootouts
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
