CREATE DATABASE historical;
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE SERVER histserver
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (dbname 'SoundGoodMusic', host 'localhost', port '5432');
CREATE USER MAPPING FOR current_user
SERVER histserver
OPTIONS (user 'postgres', password 'xxxx');
CREATE SCHEMA historical_schema;
IMPORT FOREIGN SCHEMA public FROM SERVER histserver 
    INTO historical_schema;
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
SELECT
    person.first_name AS student_name,
    person.last_name AS student_last_name,
    email.email_address AS student_email,
    lesson_type_ENUM.lesson_type AS lesson_type,
    ensemble_lesson.genre AS genre,
    COALESCE(individual_lesson.instrument_used, 
        group_lesson.instrument_used) AS instrument_used,
    price_management.price AS price
FROM
    historical_schema.student AS HSS
    LEFT JOIN historical_schema.person AS HSP ON 
        HSS.person_id = HSP.person_id
    JOIN historical_schema.email AS HSE ON 
        HSE.person_id = HSP.person_id
    JOIN historical_schema.registration AS HSR ON 
        HSS.student_id = HSR.student_id
    JOIN historical_schema.lesson AS HSL ON 
        HSL.lesson_id = HSR.lesson_id
    JOIN historical_schema.price_management AS HSPM ON 
        HSPM.price_id = HSL.price_id
    JOIN historical_schema.lesson_type_ENUM AS HSLTE ON 
        HSPM.lesson_type_id = HSLTE.lesson_type_id
    LEFT JOIN historical_schema.ensemble_lesson AS HSEL ON 
        HSL.lesson_id = HSEL.lesson_id
    LEFT JOIN historical_schema.group_lesson AS HSGL ON 
        HSL.lesson_id = HSGL.lesson_id
    LEFT JOIN historical_schema.individual_lesson AS HSIL ON 
        HSL.lesson_id = HSIL.lesson_id;

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