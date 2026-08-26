-- CHECKING THE FUNCTIONAL DEPENDENCY 

SELECT
    city,
    COUNT(DISTINCT state) AS state_count
FROM customers
GROUP BY city
HAVING COUNT(DISTINCT state) > 1;

SELECT
    state,
    COUNT(DISTINCT country) AS country_count
FROM customers
GROUP BY state
HAVING COUNT(DISTINCT country) > 1;
