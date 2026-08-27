--##########################################################################################
--######################## CHECKING THE FUNCTIONAL DEPENDENCY ##############################
--##########################################################################################
-- Switch to correct database
USE DATABASE NORMALIZE_DW;

-- Switch to correct schema
USE SCHEMA STAGING;

-- Check whether each city belongs to only one state
-- If a city has multiple states, the functional dependency city → state is violated
SELECT
    city,
    COUNT(DISTINCT state) AS state_count
FROM customers
GROUP BY city
HAVING COUNT(DISTINCT state) > 1;

-- Check whether each state belongs to only one country
-- If a state has multiple countries, the functional dependency state → country is violated
SELECT
    state,
    COUNT(DISTINCT country) AS country_count
FROM customers
GROUP BY state
HAVING COUNT(DISTINCT country) > 1;


--##########################################################################################
--############################## CREATING DDL SCRIPT  ######################################
--##########################################################################################
-- Switch to correct database
USE DATABASE NORMALIZE_DW;
-- Switch to the DIMENSIONS schema
USE SCHEMA DIMENSIONS;


-- Create the country DIMENSIONS table country_id is the surrogate primary key
-- country must be unique and cannot be NULL
CREATE TABLE DIMENSIONS.dim_countries (
    country_id NUMBER AUTOINCREMENT PRIMARY KEY,
    country VARCHAR(60) UNIQUE NOT NULL
);


-- Create the state DIMENSIONS table Each state is linked to its corresponding country
-- country_id acts as a foreign key to the country DIMENSIONS
CREATE TABLE DIMENSIONS.dim_states (
    state_id NUMBER AUTOINCREMENT PRIMARY KEY,
    state VARCHAR(60) UNIQUE NOT NULL,
    country_id INTEGER NOT NULL,

    FOREIGN KEY (country_id)
        REFERENCES dim_countries(country_id)
);


-- Create the city DIMENSIONS table Each city is linked to its corresponding state
-- state_id acts as a foreign key to the state DIMENSIONS
CREATE TABLE DIMENSIONS.dim_cities (
    city_id NUMBER AUTOINCREMENT PRIMARY KEY,
    city VARCHAR(60) UNIQUE NOT NULL,
    state_id INTEGER NOT NULL,

    FOREIGN KEY (state_id)
        REFERENCES dim_states(state_id)
);


-- Create the customer DIMENSIONS table Each customer is linked to a city through city_id
-- customer_id is the primary key email must be unique and cannot be NULL
CREATE TABLE DIMENSIONS.dim_customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(30),
    city_id INTEGER NOT NULL,
    signup_date DATE NOT NULL,

    FOREIGN KEY (city_id)
        REFERENCES dim_cities(city_id)
);

