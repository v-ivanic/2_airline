DROP TABLE IF EXISTS crew_members;
DROP TABLE IF EXISTS aircrafts;


-- Database structure for crew_members.
-- Crew_id is used as primary key.
-- Real life analogue would be PIN, as (theoretically) there can be
-- more than one person with same name and birth date.
CREATE TABLE crew_members (
	crew_id		int,
	crew_name	varchar(80),
	birth_date	date);

-- Testing data
INSERT INTO crew_members(crew_id, crew_name, birth_date)
	VALUES (1, 'Frank Abagnale', '1948-04-27'); -- the oldest
INSERT INTO crew_members(crew_id, crew_name, birth_date)
	VALUES (2, 'Chesley Sully Sullenberger', '1951-01-23');	 -- second oldest
INSERT INTO crew_members(crew_id, crew_name, birth_date)
	VALUES (3, 'William Whip Whitaker', '1954-12-28');	
INSERT INTO crew_members(crew_id, crew_name, birth_date)
	VALUES (4, 'Pete Maverick Mitchell', '1962-06-03'); -- the youngest


-- Database structure for aircrafts.
-- Primary key is {crew_id, aircraft_name}.
-- It is needed to uniquely specify a row in table.
CREATE TABLE aircrafts (
	crew_id			int,
	aircraft_name	varchar(80));

-- Testing data
INSERT INTO aircrafts(crew_id)
	VALUES (1); -- the least experienced	
INSERT INTO aircrafts(crew_id, aircraft_name)
	VALUES (2, 'Airbus A320');	
INSERT INTO aircrafts(crew_id, aircraft_name)
	VALUES (3, 'MD-80');	
INSERT INTO aircrafts(crew_id, aircraft_name)
	VALUES (4, 'MD-80');  -- the most experienced
INSERT INTO aircrafts(crew_id, aircraft_name)
	VALUES (4, 'Airbus A320');
INSERT INTO aircrafts(crew_id, aircraft_name)
	VALUES (4, 'F-14A Tomcat');


-- Simple queries for testing data
-- check crew_members
SELECT * FROM crew_members;

-- gives names and birth_dates
SELECT crew_name, birth_date
FROM crew_members;

-- check aircrafts
SELECT * FROM aircrafts;

-- gives unique aircrafts
SELECT DISTINCT aircraft_name
FROM aircrafts
WHERE aircraft_name IS NOT NULL;

-- gives all data (id, names, birth_dates and planes) in one table
-- using inner join on crew_id
SELECT crew_members.crew_id, crew_members.crew_name, crew_members.birth_date, aircrafts.aircraft_name
FROM (crew_members
INNER JOIN aircrafts ON crew_members.crew_id=aircrafts.crew_id);


-- Queries from task
-- Query 1: Find name of the oldest crew member: 'Frank Abagnale'
SELECT crew_name
FROM crew_members
WHERE birth_date = (
	SELECT MIN(birth_date)
	FROM crew_members);


-- Query 2: Find name of the n-th crew member (second oldest, fifth oldest and so on): 2nd - 'Chesley Sully Sullenberger'
-- OFFSET controls second oldest (OFFSET 1), fifth oldest (OFFSET 4) and so on
SELECT crew_name
FROM crew_members
WHERE birth_date = (
	SELECT birth_date 
	FROM crew_members
	ORDER BY birth_date ASC
	LIMIT 1 OFFSET 1);


-- Query 3: Find name of the most experienced crew member - that one who knows most aircrafts: 'Pete Maverick Mitchell'
-- using VIEW (with COUNT) for level of experience
DROP VIEW IF EXISTS crew_exp;
CREATE VIEW crew_exp AS
	SELECT crew_id, COUNT(aircraft_name) AS exp_level
	FROM aircrafts
	GROUP BY crew_id;

SELECT crew_name
FROM crew_members
WHERE crew_id = (
	SELECT crew_id
	FROM crew_exp
	WHERE exp_level = (
		SELECT MAX(exp_level)
		FROM crew_exp));

-- drop view when finished with using it
DROP VIEW IF EXISTS crew_exp;


-- Query 4: Find name of the least experienced crew member - that one who knows least aircrafts (counting from zero): 'Frank Abagnale'
-- using VIEW from Query 3:
DROP VIEW IF EXISTS crew_exp;
CREATE VIEW crew_exp AS
	SELECT crew_id, COUNT(aircraft_name) AS exp_level
	FROM aircrafts
	GROUP BY crew_id;

SELECT crew_name
FROM crew_members
WHERE crew_id = (
	SELECT crew_id
	FROM crew_exp
	WHERE exp_level = (
		SELECT MIN(exp_level)
		FROM crew_exp));

-- drop view when finished with using it
DROP VIEW IF EXISTS crew_exp;