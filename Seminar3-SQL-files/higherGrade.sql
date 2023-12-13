-- Use sql shell and log in to a database and create the following DB
CREATE DATABASE historical;     

-- Navigate to the newly created database and create the following extension
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Create a server "histserver", and link it to the database you want to import the data from
-- in this case as example, {dbname: "SoundGoodMusic", host: "localhost", port: 5432}
--TODO: Adjust the dbname, host and port according to your settings
CREATE SERVER histserver
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (dbname 'SoundGoodMusic', host 'localhost', port '5432');

-- Create a user mapping for the current user of the server, since both databases i.e 
-- "SoundGoodMusic" and "historical" are created in the same server, you need the name of 
-- that server's user and his/her password
--TODO: YOUR OWN USERNAME AND PASSWORD TO THE SERVER
CREATE USER MAPPING FOR current_user
SERVER histserver
OPTIONS (user 'yourUserName', password 'xxxx');        

-- Create a new schema called "historical_schema"
CREATE SCHEMA historical_schema;

-- Import the schema from the previous database via the foriegn server called "histserver"
-- "public" is the name of the schema in "SoundGoodMusic" per default
IMPORT FOREIGN SCHEMA public FROM SERVER histserver 
    INTO historical_schema;

-- Create a new table in the "historical_schema" called "recording"
CREATE TABLE historical_schema.recording (
    record_id SERIAL PRIMARY KEY,
    student_name VARCHAR(255),
    student_last_name VARCHAR(255),
    student_email VARCHAR(255),
    lesson_type VARCHAR(255),
    genre VARCHAR(255),
    instrument_used VARCHAR(255),
    price NUMERIC
);

-- Insert data into recording from the imported schema in historical_schema
INSERT INTO historical_schema.recording (
    student_name,
    student_last_name,
    student_email,
    lesson_type,
    genre,
    instrument_used,
    price
)
SELECT
    HSP.first_name AS student_name,
    HSP.last_name AS student_last_name,
    HSE.email_address AS student_email,
    HSLTE.lesson_type AS lesson_type,
    HSEL.genre AS genre,
    COALESCE(HSIL.instrument_used, HSGL.instrument_used) AS instrument_used,
    HSPM.price AS price
FROM
    historical_schema.student AS HSS
    LEFT JOIN historical_schema.person AS HSP ON HSS.person_id = HSP.person_id
    JOIN historical_schema.email AS HSE ON HSE.person_id = HSP.person_id
    JOIN historical_schema.registration AS HSR ON HSS.student_id = HSR.student_id
    JOIN historical_schema.lesson AS HSL ON HSL.lesson_id = HSR.lesson_id
    JOIN historical_schema.price_management AS HSPM ON HSPM.price_id = HSL.price_id
    JOIN historical_schema.lesson_type_ENUM AS HSLTE ON HSPM.lesson_type_id = HSLTE.lesson_type_id
    LEFT JOIN historical_schema.ensemble_lesson AS HSEL ON HSL.lesson_id = HSEL.lesson_id
    LEFT JOIN historical_schema.group_lesson AS HSGL ON HSL.lesson_id = HSGL.lesson_id
    LEFT JOIN historical_schema.individual_lesson AS HSIL ON HSL.lesson_id = HSIL.lesson_id;


-- Display the records
SELECT
    recording.student_name,
    recording.student_last_name,
    recording.student_email,
    recording.lesson_type,
    recording.price,
    recording.genre,
    recording.instrument_used
   
FROM
    historical_schema.recording recording;