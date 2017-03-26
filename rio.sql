-- SQL commands from "Introduction to SQLite" on engineeringterminal.com

--Copyright (c) 2017 Viper Science

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


-- In case the database already exists, run the following drop commands.
DROP TABLE IF EXISTS athletes;
DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS favorites;

-- Create the favorites table and insert data
CREATE TABLE favorites(name TEXT, country_code TEXT);
INSERT INTO favorites VALUES ('Michael Phelps','USA');
INSERT INTO favorites VALUES ('Usain Bolt','JAM');
SELECT * FROM favorites;

-- Import data
.mode csv
CREATE TABLE athletes(id integer, name text, nationality text, gender text, dob numeric, height real, weight integer, sport text, gold integer, silver integer, bronze integer);
CREATE TABLE countries(country text, code text, population integer, gdp_per_capita real);
.import athletes.csv athletes
.import countries.csv countries

-- Build indexes
create index athletes_country_index on athletes (nationality);
create index countries_country_index on countries (code);

-- Queries

SELECT * FROM favorites;
SELECT name FROM favorites;

-- Count stuff
SELECT count(*) FROM athletes WHERE gender='female' AND gold>0;
SELECT count(*) FROM athletes WHERE gender='male' AND silver>0;

-- Find who won the most medals?
SELECT name, country, gold+silver+bronze
  FROM athletes, countries
  WHERE athletes.nationality = countries.code
  ORDER BY gold + silver + bronze DESC, name
  LIMIT 10;

-- Joins

-- Performance leaderboard [country, medals per athlete, GDP, athlete BMI]
SELECT country, sum(gold + silver + bronze)/count(athletes.id), gdp_per_capita, avg(weight/height/height)
  FROM athletes, countries
  WHERE athletes.nationality = countries.code
  GROUP BY countries.code
  ORDER BY sum(gold + silver + bronze)/count(athletes.id) desc, countries.country
  LIMIT 10;

-- Virtual Tables

DROP VIEW IF EXISTS most_played_sports;

CREATE VIEW most_played_sports(sport, total_medals) AS
  SELECT sport, (sum(gold) + sum(silver) + sum(bronze))
  FROM athletes
  GROUP BY sport
  HAVING count(athletes.id) > 500;

-- Count total pairs
SELECT count(a_tbl.sport)
  FROM most_played_sports a_tbl, most_played_sports b_tbl
  WHERE a_tbl.total_medals < b_tbl.total_medals;
