-- Laboratory Work #2: Advanced DDL Operations

-- Part 1 and Part 5 database commands must be run while connected to a database other than the database being dropped.
-- Part 2-4 must be run while connected to university_main.

-- PART 1: MULTIPLE DATABASE MANAGEMENT
-- Task 1.1: Database Creation with Parameters

CREATE DATABASE university_main
    WITH
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
    WITH
    TEMPLATE = template0
    CONNECTION LIMIT = 50;

CREATE DATABASE university_test
    WITH
    CONNECTION LIMIT = 10
    IS_TEMPLATE = true;

-- Task 1.2: Tablespace Operations

CREATE TABLESPACE student_data
    LOCATION '/Library/PostgreSQL/18/tablespaces/student_data';

CREATE TABLESPACE course_data
    OWNER postgres
    LOCATION '/Library/PostgreSQL/18/tablespaces/course_data';

CREATE DATABASE university_distributed
    WITH
    TEMPLATE = template0
    TABLESPACE = student_data
    ENCODING = 'LATIN9';

-- PART 2: COMPLEX TABLE CREATION
-- Task 2.1: University Management System

CREATE TABLE students (
    student_id serial PRIMARY KEY,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    phone char(15),
    date_of_birth date,
    enrollment_date date,
    gpa decimal(4,2),
    is_active boolean,
    graduation_year smallint
);

CREATE TABLE professors (
    professor_id serial PRIMARY KEY,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    office_number varchar(20),
    hire_date date,
    salary decimal(15,2),
    is_tenured boolean,
    years_experience integer
);

CREATE TABLE courses (
    course_id serial PRIMARY KEY,
    course_code char(8),
    course_title varchar(100),
    description text,
    credits smallint,
    max_enrollment integer,
    course_fee decimal(10,2),
    is_online boolean,
    created_at timestamp without time zone
);

-- Task 2.2: Time-based and Specialized Tables

CREATE TABLE class_schedule (
    schedule_id serial PRIMARY KEY,
    course_id integer,
    professor_id integer,
    classroom varchar(20),
    class_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration interval
);

CREATE TABLE student_records (
    record_id serial PRIMARY KEY,
    student_id integer,
    course_id integer,
    semester varchar(20),
    year integer,
    grade char(2),
    attendance_percentage decimal(5,1),
    submission_timestamp timestamp with time zone,
    last_updated timestamp with time zone
);

-- PART 3: ADVANCED ALTER TABLE OPERATIONS
-- Task 3.1: Modifying Existing Tables

ALTER TABLE students
    ADD COLUMN middle_name varchar(30);

ALTER TABLE students
    ADD COLUMN student_status varchar(20);

ALTER TABLE students
    ALTER COLUMN phone TYPE varchar(20);

ALTER TABLE students
    ALTER COLUMN student_status SET DEFAULT 'ACTIVE';

ALTER TABLE students
    ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
    ADD COLUMN department_code char(5);

ALTER TABLE professors
    ADD COLUMN research_area text;

ALTER TABLE professors
    ALTER COLUMN years_experience TYPE smallint;

ALTER TABLE professors
    ALTER COLUMN is_tenured SET DEFAULT false;

ALTER TABLE professors
    ADD COLUMN last_promotion_date date;

ALTER TABLE courses
    ADD COLUMN prerequisite_course_id integer;

ALTER TABLE courses
    ADD COLUMN difficulty_level smallint;

ALTER TABLE courses
    ALTER COLUMN course_code TYPE varchar(10);

ALTER TABLE courses
    ALTER COLUMN credits SET DEFAULT 3;

ALTER TABLE courses
    ADD COLUMN lab_required boolean DEFAULT false;

-- Task 3.2: Column Management Operations

ALTER TABLE class_schedule
    ADD COLUMN room_capacity integer;

ALTER TABLE class_schedule
    DROP COLUMN duration;

ALTER TABLE class_schedule
    ADD COLUMN session_type varchar(15);

ALTER TABLE class_schedule
    ALTER COLUMN classroom TYPE varchar(30);

ALTER TABLE class_schedule
    ADD COLUMN equipment_needed text;

ALTER TABLE student_records
    ADD COLUMN extra_credit_points decimal(4,1);

ALTER TABLE student_records
    ALTER COLUMN grade TYPE varchar(5);

ALTER TABLE student_records
    ALTER COLUMN extra_credit_points SET DEFAULT 0.0;

ALTER TABLE student_records
    ADD COLUMN final_exam_date date;

ALTER TABLE student_records
    DROP COLUMN last_updated;

-- PART 4: TABLE RELATIONSHIPS AND MANAGEMENT
-- Task 4.1: Additional Supporting Tables

CREATE TABLE departments (
    department_id serial PRIMARY KEY,
    department_name varchar(100),
    department_code char(5),
    building varchar(50),
    phone varchar(15),
    budget decimal(15,2),
    established_year integer
);

CREATE TABLE library_books (
    book_id serial PRIMARY KEY,
    isbn char(13),
    title varchar(200),
    author varchar(100),
    publisher varchar(100),
    publication_date date,
    price decimal(10,2),
    is_available boolean,
    acquisition_timestamp timestamp without time zone
);

CREATE TABLE student_book_loans (
    loan_id serial PRIMARY KEY,
    student_id integer,
    book_id integer,
    loan_date date,
    due_date date,
    return_date date,
    fine_amount decimal(10,2),
    loan_status varchar(20)
);

-- Task 4.2: Table Modifications for Integration

ALTER TABLE professors
    ADD COLUMN department_id integer;

ALTER TABLE students
    ADD COLUMN advisor_id integer;

ALTER TABLE courses
    ADD COLUMN department_id integer;

CREATE TABLE grade_scale (
    grade_id serial PRIMARY KEY,
    letter_grade char(2),
    min_percentage decimal(4,1),
    max_percentage decimal(4,1),
    gpa_points decimal(4,2)
);

CREATE TABLE semester_calendar (
    semester_id serial PRIMARY KEY,
    semester_name varchar(20),
    academic_year integer,
    start_date date,
    end_date date,
    registration_deadline timestamp with time zone,
    is_current boolean
);

-- PART 5: TABLE DELETION AND CLEANUP
-- Task 5.1: Conditional Table Operations

DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id serial PRIMARY KEY,
    letter_grade char(2),
    min_percentage decimal(4,1),
    max_percentage decimal(4,1),
    gpa_points decimal(4,2),
    description text
);

DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id serial PRIMARY KEY,
    semester_name varchar(20),
    academic_year integer,
    start_date date,
    end_date date,
    registration_deadline timestamp with time zone,
    is_current boolean
);

-- Task 5.2: Database Cleanup

ALTER DATABASE university_test IS_TEMPLATE = false;

DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
    WITH
    TEMPLATE = university_main;
