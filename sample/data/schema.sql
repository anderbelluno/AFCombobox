PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
  id        INTEGER PRIMARY KEY,
  dept_code TEXT    NOT NULL UNIQUE,
  name      TEXT    NOT NULL
);

CREATE TABLE employees (
  id             INTEGER PRIMARY KEY,
  emp_no         TEXT    NOT NULL UNIQUE,
  first_name     TEXT    NOT NULL,
  last_name      TEXT    NOT NULL,
  email          TEXT,
  department_id  INTEGER NOT NULL REFERENCES departments (id),
  job_title      TEXT,
  hired_date     TEXT,
  active         INTEGER NOT NULL DEFAULT 1
);

INSERT INTO departments (id, dept_code, name) VALUES
  (1, 'HR',  'Human Resources'),
  (2, 'IT',  'Information Technology'),
  (3, 'SAL', 'Sales'),
  (4, 'FIN', 'Finance'),
  (5, 'ENG', 'Engineering');

INSERT INTO employees (id, emp_no, first_name, last_name, email, department_id, job_title, hired_date, active) VALUES
  (1,  'E001', 'Alice',   'Johnson',  'alice.johnson@example.com',   1, 'HR Manager',        '2019-03-15', 1),
  (2,  'E002', 'Bob',     'Smith',    'bob.smith@example.com',       2, 'Software Engineer', '2020-07-01', 1),
  (3,  'E003', 'Carol',   'Davis',    'carol.davis@example.com',     3, 'Sales Rep',         '2018-11-20', 1),
  (4,  'E004', 'David',   'Wilson',   'david.wilson@example.com',    4, 'Accountant',        '2021-01-10', 1),
  (5,  'E005', 'Eva',     'Martinez', 'eva.martinez@example.com',    5, 'QA Engineer',       '2022-05-22', 1),
  (6,  'E006', 'Frank',   'Brown',    'frank.brown@example.com',     2, 'DevOps Engineer',   '2017-09-05', 1),
  (7,  'E007', 'Grace',   'Lee',      'grace.lee@example.com',       3, 'Sales Manager',     '2016-04-18', 1),
  (8,  'E008', 'Henry',   'Taylor',   'henry.taylor@example.com',    4, 'Financial Analyst', '2023-02-14', 1),
  (9,  'E009', 'Irene',   'Clark',    'irene.clark@example.com',     5, 'Backend Developer', '2019-12-01', 1),
  (10, 'E010', 'Jack',    'Moore',    'jack.moore@example.com',      1, 'Recruiter',         '2020-08-30', 1),
  (11, 'E011', 'Karen',   'White',    'karen.white@example.com',     2, 'Tech Lead',         '2015-06-11', 0),
  (12, 'E012', 'Leo',     'Harris',   'leo.harris@example.com',      3, 'Sales Rep',         '2014-10-03', 0);
