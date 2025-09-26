-- 4. Check: Table has at least one row
DO $$
DECLARE rec RECORD;
BEGIN
SELECT * INTO rec FROM employees;
IF NOT FOUND THEN
    RAISE EXCEPTION 'No employees found!';
END IF;
END $$;

-- 5. Check: At least one employee with salary > 80K
DO $$
DECLARE rec RECORD;
BEGIN
SELECT * INTO rec FROM employees WHERE salary > 80000;
IF NOT FOUND THEN
    RAISE EXCEPTION 'No employees with salary > 80K!';
END IF;
END $$;

-- 6. Check: At least one employee hired after 2025-01-01
DO $$
DECLARE rec RECORD;
BEGIN
SELECT * INTO rec FROM employees WHERE hire_date >= '2025-01-01';
IF NOT FOUND THEN
    RAISE EXCEPTION 'No employees hired after 2025-01-01!';
END IF;
END $$;

-- 7. For debugging: print the data as a reference
SELECT * FROM employees;
SELECT name, salary FROM employees;
SELECT * FROM employees WHERE salary > 80000;
SELECT id, name, salary FROM employees ORDER BY salary DESC;
SELECT name, hire_date FROM employees WHERE hire_date >= '2025-01-01' ORDER BY hire_date;
