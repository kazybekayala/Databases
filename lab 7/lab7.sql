-- Part 2: Creating Basic Views
-- Exercise 2.1: Simple View Creation
CREATE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

-- 4 rows. Tom Brown does not appear because his dept_id is NULL. INNER JOIN only returns matching rows from both tables.

-- Exercise 2.2: View with Aggregation
CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT *
FROM dept_statistics
ORDER BY employee_count DESC;

-- Exercise 2.3: View with Multiple Joins
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = p.dept_id
    ) AS team_size
FROM projects p
LEFT JOIN departments d
    ON p.dept_id = d.dept_id;

SELECT * FROM project_overview;

-- Exercise 2.4: View with Filtering
CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
LEFT JOIN departments d
    ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;

-- The view shows only employees with salaries greater than $55,000. It does not show employees with lower or equal salaries.
-- Employees without a department can also appear if their salary is greater than $55,000.

-- Part 3: Modifying and Managing Views
-- Exercise 3.1: Replace a View
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
    END AS salary_grade
FROM employees e
INNER JOIN departments d
    ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

-- Exercise 3.2: Rename a View
ALTER VIEW high_earners
RENAME TO top_performers;

SELECT * FROM top_performers;

-- Exercise 3.3: Drop a View
CREATE VIEW temp_view AS
SELECT *
FROM employees
WHERE salary < 50000;

SELECT * FROM temp_view;

DROP VIEW temp_view;

-- Part 4: Updatable Views
-- Exercise 4.1: Create an Updatable View
CREATE VIEW employee_salaries AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees;

SELECT * FROM employee_salaries;

-- Exercise 4.2: Update Through a View
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT *
FROM employees
WHERE emp_name = 'John Smith';

-- Yes. The underlying employees table was updated because the view is updatable. The change is visible in the original table.

-- Exercise 4.3: Insert Through a View
INSERT INTO employee_salaries
    (emp_id, emp_name, dept_id, salary)
VALUES
    (6, 'Alice Johnson', 102, 58000);

SELECT *
FROM employees
WHERE emp_id = 6;

-- Yes. The insert was successful because employee_salaries is an updatable view.
-- Alice Johnson was added to the underlying employees table.

-- Exercise 4.4: View with CHECK OPTION
CREATE VIEW it_employees AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

INSERT INTO it_employees
    (emp_id, emp_name, dept_id, salary)
VALUES
    (7, 'Bob Wilson', 103, 60000);

-- The insert fails because the row does not satisfy the view condition.
-- The CHECK OPTION prevents inserting rows that are not visible through the view.

-- Part 5: Materialized Views
-- Exercise 5.1: Create a Materialized View
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = d.dept_id
    ) AS total_employees,
    COALESCE(
        (
            SELECT SUM(e.salary)
            FROM employees e
            WHERE e.dept_id = d.dept_id
        ), 0
    ) AS total_salaries,
    (
        SELECT COUNT(*)
        FROM projects p
        WHERE p.dept_id = d.dept_id
    ) AS total_projects,
    COALESCE(
        (
            SELECT SUM(p.budget)
            FROM projects p
            WHERE p.dept_id = d.dept_id
        ), 0
    ) AS total_project_budget
FROM departments d
WITH DATA;

-- Exercise 5.2: Refresh Materialized View
INSERT INTO employees
    (emp_id, emp_name, dept_id, salary)
VALUES
    (8, 'Charlie Brown', 101, 54000);

SELECT *
FROM dept_summary_mv
WHERE dept_id = 101;

REFRESH MATERIALIZED VIEW dept_summary_mv;

SELECT *
FROM dept_summary_mv
WHERE dept_id = 101;

-- Before refresh, the materialized view shows old data.
-- After refresh, it includes Charlie Brown and the updated employee count and total salaries.

-- Exercise 5.3: Concurrent Refresh
CREATE UNIQUE INDEX dept_summary_mv_dept_id_idx
ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

-- CONCURRENTLY allows users to read the materialized view while it is being refreshed. It reduces blocking for other users.

-- Exercise 5.4: Materialized View with NO DATA
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = p.dept_id
    ) AS employee_count
FROM projects p
LEFT JOIN departments d
    ON p.dept_id = d.dept_id
WITH NO DATA;

SELECT * FROM project_stats_mv;

-- PostgreSQL reports that the materialized view has not been populated. We can fix it by refreshing the view:

REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;

-- Part 6: Database Roles
-- Exercise 6.1: Create Basic Roles
CREATE ROLE analyst NOLOGIN;

CREATE ROLE data_viewer
WITH LOGIN PASSWORD 'viewer123';

CREATE USER report_user
WITH PASSWORD 'report456';

SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';

-- Exercise 6.2: Role with Specific Attributes
CREATE ROLE db_creator
WITH LOGIN CREATEDB PASSWORD 'creator789';

CREATE ROLE user_manager
WITH LOGIN CREATEROLE PASSWORD 'manager101';

CREATE ROLE admin_user
WITH LOGIN SUPERUSER PASSWORD 'admin999';

-- Exercise 6.3: Grant Privileges to Roles
GRANT SELECT ON employees, departments, projects
TO analyst;

GRANT ALL PRIVILEGES ON employee_details
TO data_viewer;

GRANT SELECT, INSERT ON employees
TO report_user;

-- Exercise 6.4: Create Group Roles
CREATE ROLE hr_team NOLOGIN;
CREATE ROLE finance_team NOLOGIN;
CREATE ROLE it_team NOLOGIN;

CREATE USER hr_user1
WITH PASSWORD 'hr001';

CREATE USER hr_user2
WITH PASSWORD 'hr002';

CREATE USER finance_user1
WITH PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees
TO hr_team;

GRANT SELECT ON dept_statistics
TO finance_team;

-- Exercise 6.5: Revoke Privileges
REVOKE UPDATE ON employees
FROM hr_team;

REVOKE hr_team FROM hr_user2;

REVOKE ALL PRIVILEGES ON employee_details
FROM data_viewer;

-- Exercise 6.6: Modify Role Attributes
ALTER ROLE analyst
WITH LOGIN PASSWORD 'analyst123';

ALTER ROLE user_manager
WITH SUPERUSER;

ALTER ROLE analyst
PASSWORD NULL;

ALTER ROLE data_viewer
CONNECTION LIMIT 5;

SELECT
    rolname,
    rolcanlogin,
    rolsuper,
    rolcreatedb,
    rolcreaterole,
    rolconnlimit
FROM pg_roles
WHERE rolname IN (
    'analyst',
    'data_viewer',
    'db_creator',
    'user_manager',
    'admin_user'
);

-- Part 7: Advanced Role Management
-- Exercise 7.1: Role Hierarchies
CREATE ROLE read_only NOLOGIN;

GRANT USAGE ON SCHEMA public TO read_only;

GRANT SELECT ON ALL TABLES IN SCHEMA public
TO read_only;

CREATE ROLE junior_analyst
WITH LOGIN PASSWORD 'junior123';

CREATE ROLE senior_analyst
WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees
TO senior_analyst;

-- Exercise 7.2: Object Ownership
CREATE ROLE project_manager
WITH LOGIN PASSWORD 'pm123';

GRANT CREATE ON SCHEMA public
TO project_manager;

ALTER VIEW dept_statistics
OWNER TO project_manager;

ALTER TABLE projects
OWNER TO project_manager;

SELECT
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'public';

-- Exercise 7.3: Reassign and Drop Roles
CREATE ROLE temp_owner
WITH LOGIN;

CREATE TABLE temp_table (
    id INT
);

ALTER TABLE temp_table
OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;

DROP ROLE temp_owner;

-- Exercise 7.4: Row-Level Security with Views
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view
TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT
    emp_id,
    emp_name,
    salary
FROM employees;

GRANT SELECT ON finance_employee_view
TO finance_team;

SELECT * FROM hr_employee_view;

SELECT * FROM finance_employee_view;

-- Part 8: Practical Scenarios
-- Exercise 8.1: Department Dashboard View
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,

    (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = d.dept_id
    ) AS employee_count,

    ROUND(
        (
            SELECT AVG(e.salary)
            FROM employees e
            WHERE e.dept_id = d.dept_id
        ), 2
    ) AS average_salary,

    (
        SELECT COUNT(*)
        FROM projects p
        WHERE p.dept_id = d.dept_id
    ) AS active_projects,

    COALESCE(
        (
            SELECT SUM(p.budget)
            FROM projects p
            WHERE p.dept_id = d.dept_id
        ), 0
    ) AS total_project_budget,

    ROUND(
        COALESCE(
            (
                SELECT SUM(p.budget)
                FROM projects p
                WHERE p.dept_id = d.dept_id
            ), 0
        )::NUMERIC
        /
        NULLIF(
            (
                SELECT COUNT(*)
                FROM employees e
                WHERE e.dept_id = d.dept_id
            ), 0
        ),
        2
    ) AS budget_per_employee

FROM departments d;

SELECT * FROM dept_dashboard;

-- Exercise 8.2: Audit View
ALTER TABLE projects
ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,

    CASE
        WHEN p.budget > 150000
            THEN 'Critical Review Required'

        WHEN p.budget > 100000
            THEN 'Management Approval Needed'

        ELSE 'Standard Process'
    END AS approval_status

FROM projects p
LEFT JOIN departments d
    ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

SELECT * FROM high_budget_projects;

-- Exercise 8.3: Create Access Control System
-- Level 1 - Viewer Role
CREATE ROLE viewer_role NOLOGIN;

GRANT USAGE ON SCHEMA public
TO viewer_role;

GRANT SELECT ON ALL TABLES IN SCHEMA public
TO viewer_role;

-- Level 2 - Entry Role
CREATE ROLE entry_role NOLOGIN;

GRANT viewer_role TO entry_role;

GRANT INSERT ON employees, projects
TO entry_role;

-- Level 3 - Analyst Role
CREATE ROLE analyst_role NOLOGIN;

GRANT entry_role TO analyst_role;

GRANT UPDATE ON employees, projects
TO analyst_role;

-- Level 4 - Manager Role
CREATE ROLE manager_role NOLOGIN;

GRANT analyst_role TO manager_role;

GRANT DELETE ON employees, projects
TO manager_role;

-- Create Users
CREATE USER alice
WITH PASSWORD 'alice123';

CREATE USER bob
WITH PASSWORD 'bob123';

CREATE USER charlie
WITH PASSWORD 'charlie123';

GRANT viewer_role TO alice;

GRANT analyst_role TO bob;

GRANT manager_role TO charlie;
