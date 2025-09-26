-- e2e_employees_test.sql

-- 1. Drop table for repeatability
DROP TABLE IF EXISTS employees;

-- 2. Create table
CREATE TABLE employees (
                           id         SERIAL PRIMARY KEY,
                           name       VARCHAR(100) NOT NULL,
                           hire_date  DATE DEFAULT CURRENT_DATE,
                           salary     NUMERIC(10,2)
);

-- 3. Insert data
INSERT INTO employees (name, hire_date, salary) VALUES
                                                    ('Alice Smith', '2024-07-10', 85000.00),
                                                    ('Bob Chen',    '2025-01-22', 93000.00),
                                                    ('Carla Diaz',  DEFAULT,      78000.00);
