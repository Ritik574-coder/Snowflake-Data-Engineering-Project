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


--==========================================================================================
CREATE TABLE dimension.dim_countries (
  country_id   NUMBER AUTOINCREMENT PRIMARY KEY,
  country      VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE dimension.dim_states (
  state_id     NUMBER AUTOINCREMENT PRIMARY KEY,
  state        VARCHAR(60) UNIQUE NOT NULL,
  country_id   INTEGER NOT NULL,

  FOREIGN KEY (country_id) REFERENCES dim_countries(country_id)
);

CREATE TABLE dimension.dim_cities (
  city_id      NUMBER AUTOINCREMENT PRIMARY KEY,
  city         VARCHAR(60) UNIQUE NOT NULL,
  state_id     INTEGER NOT NULL,

  FOREIGN KEY (state_id) REFERENCES dim_states(state_id)
);

CREATE TABLE dimension.dim_customers (
  customer_id    VARCHAR(10) PRIMARY KEY,
  customer_name  VARCHAR(120) NOT NULL,
  email          VARCHAR(150) UNIQUE NOT NULL,
  phone          VARCHAR(30),
  city_id        INTEGER NOT NULL,
  signup_date    DATE NOT NULL,

  FOREIGN KEY (city_id) REFERENCES dim_cities(city_id)
);