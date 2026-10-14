-- Laboratory Work 5

DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS products_fk CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS employees_dept CASCADE;
DROP TABLE IF EXISTS student_courses CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS course_enrollments CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS customers_not_null CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS products_catalog CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

-- PART 1: CHECK CONSTRAINTS
-- Task 1.1: age 18-65; salary > 0.
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CONSTRAINT valid_employee_age CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CONSTRAINT positive_employee_salary CHECK (salary > 0)
);

-- Task 1.2: named CHECK for valid discounted prices.
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- Task 1.3: guest count and date-order constraints.
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,
    CONSTRAINT valid_guest_count CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT valid_booking_dates CHECK (check_out_date > check_in_date)
);

-- Task 1.4: two valid rows per table.
INSERT INTO employees VALUES
    (1, 'Amina', 'Sadykova', 20, 250000),
    (2, 'Daniel', 'Lee', 35, 420000);
INSERT INTO products_catalog VALUES
    (1, 'Keyboard', 100, 80),
    (2, 'Mouse', 50, 35);
INSERT INTO bookings VALUES
    (1, DATE '2026-11-01', DATE '2026-11-05', 2),
    (2, DATE '2026-12-10', DATE '2026-12-12', 4);

-- PART 2: NOT NULL
-- Task 2.1: phone is nullable; other listed columns are NOT NULL.
CREATE TABLE customers_not_null (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);
INSERT INTO customers_not_null VALUES
    (1, 'aida@example.com', NULL, DATE '2026-01-15'),
    (2, 'tim@example.com', '+77001234567', DATE '2026-02-10');

-- Task 2.2: combined NOT NULL and CHECK constraints.
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);
INSERT INTO inventory VALUES
    (1, 'Notebook', 25, 2.50, TIMESTAMP '2026-10-01 10:00:00'),
    (2, 'Pen', 100, 0.80, TIMESTAMP '2026-10-02 11:30:00');

-- Task 2.3: NULL is allowed in the nullable phone column.
INSERT INTO customers_not_null (customer_id, email, phone, registration_date)
VALUES (3, 'phone-unknown@example.com', NULL, CURRENT_DATE);

-- PART 3: UNIQUE
-- Tasks 3.1 and 3.3: named single-column UNIQUE constraints.
CREATE TABLE users (
    user_id INTEGER,
    username TEXT CONSTRAINT unique_username UNIQUE,
    email TEXT CONSTRAINT unique_email UNIQUE,
    created_at TIMESTAMP
);
INSERT INTO users VALUES
    (1, 'aida_k', 'aida.k@example.com', TIMESTAMP '2026-09-01 09:00:00'),
    (2, 'tim_lee', 'tim.lee@example.com', TIMESTAMP '2026-09-02 10:00:00');

-- Task 3.2: combination must be unique.
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_course_semester
        UNIQUE (student_id, course_code, semester)
);
INSERT INTO course_enrollments VALUES
    (1, 101, 'DB101', 'Fall 2026'),
    (2, 101, 'CS102', 'Fall 2026'),
    (3, 101, 'DB101', 'Spring 2027');

-- PART 4: PRIMARY KEY
-- Task 4.1: PRIMARY KEY is unique and NOT NULL.
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);
INSERT INTO departments VALUES
    (1, 'IT', 'Almaty'),
    (2, 'Sales', 'Astana'),
    (3, 'HR', 'Shymkent');

-- Task 4.2: composite primary key.
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO student_courses VALUES
    (101, 10, DATE '2026-09-01', 'A'),
    (101, 11, DATE '2026-09-02', 'B'),
    (102, 10, DATE '2026-09-01', 'A');

-- Task 4.3: comparison exercise.
-- PRIMARY KEY uniquely identifies each row and cannot contain NULL. UNIQUE prevents duplicate values/combinations.
-- PostgreSQL normally permits multiple NULLs in a UNIQUE constraint because NULLs are not equal by default.
-- Use a single-column key when one column identifies a row. Use a composite key when the combination
-- identifies a row, e.g. student_id plus course_id. A table has one PRIMARY KEY constraint but may have many
-- UNIQUE constraints because it has one chosen row identifier and many other values/combinations that must be unique.

-- PART 5: FOREIGN KEY
-- Task 5.1: employee department must exist in departments.
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);
INSERT INTO employees_dept VALUES
    (1, 'Amina', 1, DATE '2025-01-10'),
    (2, 'Tim', 2, DATE '2025-03-15'),
    (3, 'Dana', 1, DATE '2026-02-01');

-- Task 5.2: library schema with multiple foreign keys.
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);
CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);
INSERT INTO authors VALUES
    (1, 'Chinua Achebe', 'Nigeria'),
    (2, 'Jane Austen', 'England'),
    (3, 'Mukhtar Auezov', 'Kazakhstan'),
    (4, 'George Orwell', 'England'),
    (5, 'Jules Verne', 'France');
INSERT INTO publishers VALUES
    (1, 'World Classics', 'London'),
    (2, 'Steppe Press', 'Almaty'),
    (3, 'North Star Books', 'Paris'),
    (4, 'Modern Library', 'New York'),
    (5, 'Readers House', 'Astana');
INSERT INTO books VALUES
    (1, 'Things Fall Apart', 1, 1, 1958, '9780000000001'),
    (2, 'Pride and Prejudice', 2, 4, 1813, '9780000000002'),
    (3, 'The Path of Abai', 3, 2, 1942, '9780000000003'),
    (4, 'Animal Farm', 4, 4, 1945, '9780000000004'),
    (5, 'Journey to the Center of the Earth', 5, 3, 1864, '9780000000005');

-- Task 5.3: RESTRICT and CASCADE.
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);
CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);
INSERT INTO categories VALUES (1, 'Electronics'), (2, 'Stationery');
INSERT INTO products_fk VALUES
    (1, 'Headphones', 1), (2, 'USB Cable', 1), (3, 'Notebook', 2);
INSERT INTO orders VALUES (1, DATE '2026-10-01'), (2, DATE '2026-10-02');
INSERT INTO order_items VALUES
    (1, 1, 1, 2), (2, 1, 2, 1), (3, 2, 3, 5);

DELETE FROM orders WHERE order_id = 1;

SELECT * FROM order_items WHERE order_id = 1;

-- PART 6: PRACTICAL E-COMMERCE DATABASE
-- Task 6.1: ON DELETE RESTRICT protects referenced customers/products.
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);
CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL
        REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL
        REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);
INSERT INTO customers VALUES
    (1, 'Amina Sadykova', 'amina@example.com', '+77010000001', DATE '2026-01-10'),
    (2, 'Tim Lee', 'tim@example.com', '+77010000002', DATE '2026-01-15'),
    (3, 'Dana Kim', 'dana@example.com', NULL, DATE '2026-02-01'),
    (4, 'Alex Brown', 'alex@example.com', '+77010000004', DATE '2026-02-10'),
    (5, 'Sara White', 'sara@example.com', '+77010000005', DATE '2026-03-05');
INSERT INTO products VALUES
    (1, 'Laptop', 'Work laptop', 750000, 10),
    (2, 'Mouse', 'Wireless mouse', 12000, 50),
    (3, 'Keyboard', 'Mechanical keyboard', 35000, 25),
    (4, 'Monitor', '27-inch monitor', 145000, 12),
    (5, 'USB Drive', '64 GB USB drive', 6000, 100);

SELECT COUNT(*) AS customer_count FROM customers;
SELECT COUNT(*) AS product_count FROM products;
SELECT COUNT(*) AS order_count FROM orders;
SELECT COUNT(*) AS order_detail_count FROM order_details;

SELECT * FROM products WHERE price < 0 OR stock_quantity < 0;
SELECT * FROM order_details WHERE quantity <= 0;
