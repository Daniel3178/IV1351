CREATE TABLE person(
    person_id serial PRIMARY KEY, 
    first_name VARCHAR(500) NOT NULL,
    last_name VARCHAR(500) NOT NULL,
    person_number NUMERIC(12) NOT NULL, 
    street VARCHAR(500),
    zip VARCHAR(20),
    city VARCHAR(500)
);

CREATE TABLE phone(
    phone_number VARCHAR(200) NOT NULL,
    person_id INT NOT NULL,
    PRIMARY KEY (phone_number, person_id),
    FOREIGN KEY (person_id) REFERENCES person(person_id) ON DELETE CASCADE
);

CREATE TABLE email(
    email_address VARCHAR(200) NOT NULL, 
    person_id INT NOT NULL, 
    PRIMARY KEY (email_address, person_id),
    FOREIGN KEY (person_id) REFERENCES person(person_id) ON DELETE CASCADE
);

CREATE TABLE contact_person( 
    contact_person_id serial PRIMARY KEY,
    first_name VARCHAR(500),
    last_name VARCHAR(500)
);

CREATE TABLE contact_person_phone(
    phone_number VARCHAR(20) NOT NULL,
    contact_person_id INT NOT NULL,
    PRIMARY KEY (phone_number, contact_person_id),
    FOREIGN KEY (contact_person_id) REFERENCES contact_person(contact_person_id) ON DELETE CASCADE
);

CREATE TABLE student(
    student_id serial PRIMARY KEY,
    family_id INT NOT NULL,
    person_id INT REFERENCES person(person_id) ON DELETE CASCADE,
    contact_person_id INT REFERENCES contact_person(contact_person_id)
);

CREATE TABLE instructor(
    instructor_id serial PRIMARY KEY,
    is_able_to_teach_ensemble BOOLEAN,
    person_id INT REFERENCES person(person_id) ON DELETE CASCADE
);

CREATE TABLE instructor_skill(
    instructor_skill_id serial PRIMARY KEY,
    skill VARCHAR(200),
    instructor_id INT REFERENCES instructor(instructor_id) ON DELETE CASCADE
);

CREATE TABLE availability(
    start_time TIME NOT NULL,
    availability_date DATE NOT NULL,
    instructor_id INT NOT NULL,
    PRIMARY KEY (start_time, availability_date, instructor_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id) ON DELETE CASCADE,
    end_time TIME
);

CREATE TABLE renting_system(
    rent_id serial PRIMARY KEY,
    renting_date DATE,
    student_id INT REFERENCES student(student_id) ON DELETE CASCADE
);

CREATE TABLE inventory(
    inventory_id serial NOT NULL PRIMARY KEY,
    instrument_type VARCHAR(500) NOT NULL,
    model VARCHAR(500) ,
    brand VARCHAR(500) ,
    monthly_price MONEY,
    number_of_instrument INT
);

CREATE TABLE instrument(
    instrument_id serial PRIMARY KEY,
    rent_id INT NOT NULL REFERENCES renting_system(rent_id) ON DELETE CASCADE,
    inventory_id INT NOT NULL REFERENCES inventory(inventory_id)
);

CREATE TABLE student_skill(
    student_skill_id serial PRIMARY KEY,
    skill VARCHAR(200),
    student_id INT NOT NULL REFERENCES student(student_id) ON DELETE CASCADE
);

CREATE TABLE skill_level_ENUM(
    skill_level_id serial NOT NULL PRIMARY KEY,
    skill_level VARCHAR(200) NOT NULL
);

CREATE TABLE lesson_type_ENUM(
    lesson_type_id serial NOT NULL PRIMARY KEY,
    lesson_type VARCHAR(200) NOT NULL
);

CREATE TABLE price_management(
    price_id serial NOT NULL PRIMARY KEY, 
    price MONEY,
    start_valid_date DATE,
    end_valid_date DATE,
    skill_level_id INT NOT NULL REFERENCES skill_level_ENUM(skill_level_id) ON DELETE CASCADE,
    lesson_type_id INT NOT NULL REFERENCES lesson_type_ENUM(lesson_type_id) ON DELETE CASCADE
);

CREATE TABLE lesson(
    lesson_id serial NOT NULL PRIMARY KEY,
    instructor_id INT NOT NULL REFERENCES instructor(instructor_id) ON DELETE CASCADE, 
    price_id INT NOT NULL REFERENCES price_management(price_id) ON DELETE CASCADE
);

CREATE TABLE registration(
    registration_id serial NOT NULL PRIMARY KEY,
    registration_date DATE, 
    registration_time TIME,
    student_id INT NOT NULL REFERENCES student(student_id) ON DELETE CASCADE,
    lesson_id INT NOT NULL REFERENCES lesson(lesson_id) ON DELETE CASCADE
);

CREATE TABLE group_lesson(
    group_id serial PRIMARY KEY,
    instrument_used VARCHAR(500) NOT NULL, 
    max_number_of_student INT ,
    min_number_of_student INT ,
    lesson_id INT NOT NULL REFERENCES lesson(lesson_id) ON DELETE CASCADE
);

CREATE TABLE individual_lesson(
    individual_id serial PRIMARY KEY,
    instrument_used VARCHAR(500) NOT NULL,
    lesson_id INT NOT NULL REFERENCES lesson(lesson_id) ON DELETE CASCADE
);

CREATE TABLE ensemble_lesson(
    ensemble_id serial PRIMARY KEY,
    genre VARCHAR(500) NOT NULL, 
    max_number_of_student INT,
    min_number_of_student INT,
    lesson_id INT NOT NULL REFERENCES lesson(lesson_id) ON DELETE CASCADE
);

CREATE TABLE timeslot(
    start_time TIME NOT NULL, 
    timeslot_date DATE NOT NULL, 
    lesson_id INT NOT NULL, 
    end_time TIME ,
    place VARCHAR(50) NOT NULL,
    PRIMARY KEY (start_time, timeslot_date, lesson_id),
    FOREIGN KEY (lesson_id) REFERENCES lesson(lesson_id) ON DELETE CASCADE
);

CREATE TABLE policy_description_ENUM(
    description_id serial NOT NULL PRIMARY KEY,
    description_text VARCHAR(500)
);

CREATE TABLE company_policy(
    policy_id serial NOT NULL PRIMARY KEY,
    selected_value INT,
    start_valid_date DATE NOT NULL,
    end_valid_date DATE NOT NULL,
    description_id INT NOT NULL REFERENCES policy_description_ENUM(description_id) ON DELETE CASCADE
);
