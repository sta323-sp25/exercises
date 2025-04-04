# From command line:
# duckdb 2025-03-28-duckdb/employees.duckdb 

## Exercise 1

SELECT SUM(salary) AS payroll FROM employees;

SELECT dept, ROUND(AVG(salary),2) FROM employees GROUP BY dept;


## Exercise 2

SELECT *, ROUND(salary - avg_salary,2) AS abv_avg
FROM employees LEFT JOIN (
  SELECT dept, ROUND(AVG(salary),2) AS avg_salary 
    FROM employees GROUP BY dept
) USING(dept);

## Exercise 3

