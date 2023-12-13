--TASK-1 SEMINAR-3
SELECT
    TO_CHAR(T.timeslot_date, 'Mon') AS month,
    COUNT(IL.lesson_id) AS individual_lesson,
    COUNT(GL.lesson_id) AS group_lesson,
    COUNT(EL.lesson_id) AS ensemble_lesson,
    COUNT(IL.lesson_id) + COUNT(GL.lesson_id) 
        + COUNT(EL.lesson_id) AS total,
    EXTRACT(YEAR FROM CURRENT_DATE) AS current_year
FROM
    timeslot AS T
JOIN lesson ON 
    T.lesson_id = lesson.lesson_id
LEFT JOIN individual_lesson AS IL ON 
    IL.lesson_id = lesson.lesson_id
LEFT JOIN group_lesson AS GL ON 
    GL.lesson_id = lesson.lesson_id
LEFT JOIN ensemble_lesson AS EL ON 
    EL.lesson_id = lesson.lesson_id
WHERE 
    EXTRACT(YEAR FROM T.timeslot_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    TO_CHAR(T.timeslot_date, 'Mon')
ORDER BY
    CASE TO_CHAR(T.timeslot_date, 'Mon')
        WHEN 'Jan' THEN 1
        WHEN 'Feb' THEN 2
        WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4
        WHEN 'May' THEN 5
        WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7
        WHEN 'Aug' THEN 8
        WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10
        WHEN 'Nov' THEN 11
        WHEN 'Dec' THEN 12
    END;

----------------------------------------------------------------
--TASK-2 SEMINAR-3
WITH family_counts AS (
    SELECT family_id, COUNT(*) AS sibling_count
    FROM student
    GROUP BY family_id
    HAVING COUNT(*) IN (1, 2, 3)
)

SELECT 
    sibling_count-1 AS no_of_siblings,
    SUM(CASE WHEN sibling_count = 1 THEN 1 ELSE 0 END) +
    SUM(CASE WHEN sibling_count = 2 THEN 1 ELSE 0 END) * 2 +
    SUM(CASE WHEN sibling_count = 3 THEN 1 ELSE 0 END) * 3 
        AS number_of_students
FROM family_counts
GROUP BY sibling_count
ORDER BY sibling_count; 

------------------------------------------------------------------
--TASK-3 SEMINAR-3 
WITH lesson_count AS (
    SELECT
        I.instructor_id,
        COUNT(*) AS given_lesson_count
    FROM
        timeslot AS TS
    JOIN lesson ON 
        TS.lesson_id = lesson.lesson_id
    JOIN instructor AS I ON 
        lesson.instructor_id = I.instructor_id
    WHERE
        TS.timeslot_date >= DATE_TRUNC('MONTH', 
            CURRENT_DATE - INTERVAL '1 month')
        AND TS.timeslot_date < DATE_TRUNC('MONTH', CURRENT_DATE)
    GROUP BY
        I.instructor_id
)

SELECT
    I.instructor_id,
    P.first_name,
    P.last_name,
    LC.given_lesson_count
FROM
    instructor AS I
JOIN person AS P ON 
    I.person_id = P.person_id
JOIN lesson_count AS LC ON 
    I.instructor_id = LC.instructor_id;

----------------------------------------------------------------
--TASK-4 SEMINAR-3 
CREATE VIEW my_ensemble_count_view AS
SELECT
    ensemble_lesson.max_number_of_student AS max,
    ensemble_lesson.min_number_of_student AS min,
    ensemble_lesson.genre AS genre,
    TO_CHAR(timeslot.timeslot_date, 'Dy') AS day_of_week,
    COUNT(*) AS number_of_students
FROM
    lesson AS L
JOIN
    ensemble_lesson ON L.lesson_id = ensemble_lesson.lesson_id
JOIN
    registration AS R ON R.lesson_id = L.lesson_id
JOIN
    timeslot ON timeslot.lesson_id = R.lesson_id
WHERE 
    timeslot.timeslot_date >= CURRENT_DATE
    AND timeslot.timeslot_date < CURRENT_DATE + INTERVAL '1 week'
GROUP BY
    L.lesson_id, day_of_week, max, min, genre; 
--the query to be called:
SELECT 
    day_of_week,
    genre,
    CASE 
        WHEN number_of_students >= max THEN 'No Seat' 
        WHEN number_of_students < max 
            AND number_of_students >= max-2 THEN '1 or 2 seats'
        ELSE 'many seats'
    END AS number_of_free_seats,
    number_of_students 
FROM my_ensemble_count_view;


----------------------------------------------------------------
--TASK-4 SEMINAR-3 - CLARIFICATION 
CREATE VIEW my_ensemble_count_view_clarified AS     
SELECT
    L.lesson_id AS lesson_id,     --ADDED FOR CLARIFICATION
    ensemble_lesson.max_number_of_student AS max,
    ensemble_lesson.min_number_of_student AS min,
    ensemble_lesson.genre AS genre,
    TO_CHAR(timeslot.timeslot_date, 'Dy') AS day_of_week,
    COUNT(*) AS number_of_students
FROM
    lesson AS L
JOIN
    ensemble_lesson ON L.lesson_id = ensemble_lesson.lesson_id
JOIN
    registration AS R ON R.lesson_id = L.lesson_id
JOIN
    timeslot ON timeslot.lesson_id = R.lesson_id
WHERE 
    timeslot.timeslot_date >= CURRENT_DATE
    AND timeslot.timeslot_date < CURRENT_DATE + INTERVAL '1 week'
GROUP BY
    L.lesson_id, day_of_week, max, min, genre;  
--the query to be called:
SELECT 
    max,            --ADDED FOR CLARIFIACTION
    min,            --ADDED FOR CLARIFICATION
    lesson_id,       --ADDED FOR CLARIFICATION
    day_of_week,
    genre,
    CASE 
        WHEN number_of_students >= max THEN 'No Seat' 
        WHEN number_of_students < max 
            AND number_of_students >= max-2 THEN '1 or 2 seats'
        ELSE 'many seats'
    END AS number_of_free_seats,
    number_of_students 
FROM my_ensemble_count_view_clarified; 

----------------------------------------------------------------