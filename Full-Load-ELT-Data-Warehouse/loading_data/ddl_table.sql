-- switch database to RitskySnow 
USE DATABASE RITSKYSNOW ;


--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.AIRCRAFT
--====================================================================================================
CREATE OR REPLACE TABLE AIRLINE_SOURCE.AIRCRAFT(
    aircraft_id         VARCHAR(20),
    tail_number         VARCHAR(20),
    model_id            VARCHAR(20),
    airline_id          VARCHAR(20),
    manufacture_year    NUMBER(4,0),
    status              VARCHAR(90)
) 
COMMENT = 'Stores raw aircraft data directly ingested from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.AIRCRAFT_MAINTENANCE_HISTORY
--====================================================================================================
CREATE OR REPLACE TABLE AIRLINE_SOURCE.AIRCRAFT_MAINTENANCE_HISTORY(
    history_id         VARCHAR(20),
    aircraft_id        VARCHAR(20),
    maintenance_date   VARCHAR(30),
    maintenance_type   VARCHAR(90),
    cost               NUMBER(10,2),
    next_due_date      VARCHAR(30)
)
COMMENT = 'Stores raw aircraft_maintenance_history data directly ingested from the source system without transformation';

-- ====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.AIRCRAFT_MODELS
-- ====================================================================================================
CREATE OR REPLACE TABLE AIRLINE_SOURCE.AIRCRAFT_MODELS(
    model_id          VARCHAR(20),
    manufacturer      VARCHAR(50),
    model_name        VARCHAR(50),
    capacity          NUMBER(5,0),
    range_km          NUMBER(5,0),
    category          VARCHAR(50)
)
COMMENT = 'Store raw aircraft_models data directly ingested from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.AIRLINES
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.AIRLINES(
    airline_id        VARCHAR(20),
    airline_name      VARCHAR(90),
    iata_code         VARCHAR(50),
    country           VARCHAR(50),
    active_flag       BOOLEAN
)
COMMENT = 'Store raw airlines data directly ingest from the source system without transformation';


--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.AIRPORTS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.AIRPORTS(
    airport_id      VARCHAR(100),
    iata_code       VARCHAR(100),
    airport_name    VARCHAR(200),
    city            VARCHAR(100),
    country         VARCHAR(100),
    timezone        VARCHAR(100),
    active_flag     BOOLEAN
)
COMMENT = 'Store raw airports data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.ANCILLARY_SERVICES
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.ANCILLARY_SERVICES(
    service_id      VARCHAR(100),
    booking_id      VARCHAR(100),
    passenger_id    VARCHAR(100),
    service_type    VARCHAR(100),
    amount          NUMBER(5,2),
    status          VARCHAR(100)
)
COMMENT = 'Store raw ancillary_services data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.BAGGAGE
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.BAGGAGE(
    baggage_id      VARCHAR(100),
    ticket_id       VARCHAR(100),
    passenger_id    VARCHAR(100),
    weight_kg       NUMBER(5,2),
    baggage_type    VARCHAR(100),
    status          VARCHAR(100)
)
COMMENT = 'Store raw baggage data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.BOARDING_PASSES
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.BOARDING_PASSES(
    boarding_pass_id    VARCHAR(100),
    ticket_id           VARCHAR(100),
    passenger_id        VARCHAR(100),
    flight_id           VARCHAR(100),
    seat_number         VARCHAR(100),
    boarding_time       VARCHAR(100),
    boarding_group      VARCHAR(100)
)
COMMENT = 'Store raw boarding_passes data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.BOOKINGS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.BOOKINGS(
    booking_id       VARCHAR(100),
    customer_id      VARCHAR(100),
    booking_date     VARCHAR(100),
    flight_id        VARCHAR(100),
    channel          VARCHAR(100),
    booking_status   VARCHAR(100),
    total_amount     NUMBER(10,2),
    currency         VARCHAR(100)
)
COMMENT = 'Store raw bookings data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.CHECK_IN_EVENTS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.CHECK_IN_EVENTS(
    checkin_id       VARCHAR(100),
    ticket_id        VARCHAR(100),
    passenger_id     VARCHAR(100),
    flight_id        VARCHAR(100),
    checkin_time     VARCHAR(100),
    checkin_method   VARCHAR(100)
)
COMMENT = 'Store raw check_in_events data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.CREW_ASSIGNMENTS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.CREW_ASSIGNMENTS(
    assignment_id     VARCHAR(100),
    flight_id         VARCHAR(100),
    crew_id           VARCHAR(100),
    role_on_flight    VARCHAR(100)
)
COMMENT = 'Store raw crew_assignment data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.CREW_MEMBERS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.CREW_MEMBERS(
    crew_id            VARCHAR(100),
    first_name         VARCHAR(100),
    last_name          VARCHAR(100),
    role               VARCHAR(100),
    airline_id         VARCHAR(100),
    hire_date          VARCHAR(100),
    status             VARCHAR(100),
    license_number     VARCHAR(100),
    base_airport_id    VARCHAR(100)
)
COMMENT = 'Store raw crew_members data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.CUSTOMERS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.CUSTOMERS(
    customer_id       VARCHAR(100),
    first_name        VARCHAR(100),
    middle_name       VARCHAR(100),
    last_name         VARCHAR(100),
    email             VARCHAR(100),
    phone             VARCHAR(100),
    date_of_birth     VARCHAR(100),
    gender            VARCHAR(100),
    nationality       VARCHAR(100),
    address           VARCHAR(100),
    city              VARCHAR(100),
    country           VARCHAR(100),
    signup_date       VARCHAR(100),
    active_flag       BOOLEAN
)
COMMENT = 'Store raw customers data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.CUSTOMER_SUPPORT_TICKETS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.CUSTOMER_SUPPORT_TICKETS(
    ticket_id       VARCHAR(100),
    customer_id     VARCHAR(100),
    booking_id      VARCHAR(100),
    issue_type      VARCHAR(100),
    opened_date     VARCHAR(100),
    status          VARCHAR(100),
    priority        VARCHAR(100)
)
COMMENT = 'Store raw customer_support_tickets data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.FEEDBACK
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.FEEDBACK(
    feedback_id       VARCHAR(100),
    customer_id       VARCHAR(100),
    flight_id         VARCHAR(100),
    rating            NUMBER(4, 2),
    comments          VARCHAR(100),
    submitted_date    VARCHAR(100)
)
COMMENT = 'Store raw feedback data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.FLIGHT_CANCELLATIONS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.FLIGHT_CANCELLATIONS(
    cancellation_id        VARCHAR(20),
    flight_id              VARCHAR(20),
    cancellation_reason    VARCHAR(60),
    cancelled_at           VARCHAR(60)
)
COMMENT = 'Store raw cancellations data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.FLIGHT_DELAYS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.FLIGHT_DELAYS(
    delay_id          VARCHAR(20),
    flight_id         VARCHAR(20),
    delay_minutes     NUMBER(5,0),
    delay_reason      VARCHAR(50)
)
COMMENT = 'Store raw flight_delays data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.FLIGHT_ROUTES
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.FLIGHT_ROUTES(
    route_id                  VARCHAR(20),
    origin_airport_id         VARCHAR(20),
    destination_airport_id    VARCHAR(20),
    distance_km               NUMBER(5,0),
    typical_duration_min      NUMBER(5,0)
)
COMMENT = 'Store raw flight_routes data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.FLIGHT_SCHEDULES
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.FLIGHT_SCHEDULES(
    schedule_id                  VARCHAR(50),
    airline_id                   VARCHAR(50),
    route_id                     VARCHAR(50),
    flight_number                VARCHAR(50),
    scheduled_departure_time     VARCHAR(50),
    scheduled_arrival_time       VARCHAR(50),
    days_of_week                 VARCHAR(50),
    aircraft_model_id            VARCHAR(50),
    effective_start_date         VARCHAR(50),
    effective_end_date           VARCHAR(50)
)
COMMENT = 'Store raw flight_schedules data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.FLIGHTS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.FLIGHTS(
    flight_id                    VARCHAR(50),
    schedule_id                  VARCHAR(50),
    flight_date                  VARCHAR(50),
    aircraft_id                  VARCHAR(50),
    airline_id                   VARCHAR(50),
    route_id                     VARCHAR(50),
    scheduled_departure_time     VARCHAR(50),
    scheduled_arrival_time       VARCHAR(50),
    origin_airport_id            VARCHAR(50),
    dest_airport_id              VARCHAR(50),
    status                       VARCHAR(50),
    actual_departure_time        VARCHAR(50),
    actual_arrival_time          VARCHAR(50),
    gate_id                      VARCHAR(50)
)
COMMENT = 'Store raw flights data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.FLIGHT_STATUS_LOGS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.FLIGHT_STATUS_LOGS(
    log_id          VARCHAR(50),
    flight_id       VARCHAR(50),
    status          VARCHAR(50),
    status_time     VARCHAR(50),
    remarks         VARCHAR(50)
)
COMMENT = 'Store raw flight_status_logs data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.FUEL_USAGE
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.FUEL_USAGE(
    fuel_id         VARCHAR(50),
    flight_id       VARCHAR(50),
    aircraft_id     VARCHAR(50),
    fuel_liters     NUMBER(10,2),
    fuel_cost       NUMBER(10,2)
)
COMMENT = 'Store raw fuel_usage data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.GATE_INFORMATION
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.GATE_INFORMATION(
    gate_id         VARCHAR(50),
    airport_id      VARCHAR(50),
    terminal        VARCHAR(50),
    gate_number     NUMBER(4,0),
    gate_type       VARCHAR(50)
)
COMMENT = 'Store raw gate_information data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.LOYALTY_MEMBERS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.LOYALTY_MEMBERS(
    loyalty_id          VARCHAR(100),
    customer_id         VARCHAR(100),
    tier                VARCHAR(100),
    points_balance      NUMBER(10,0),
    enrollment_date     VARCHAR(100),
    status              VARCHAR(100)
)
COMMENT = 'Store raw loyalty_members data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.LOYALTY_TRANSACTIONS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.LOYALTY_TRANSACTIONS(
    transaction_id      VARCHAR(100),
    loyalty_id          VARCHAR(100),
    flight_id           VARCHAR(100),
    points_earned       NUMBER(10,0),
    points_redeemed     NUMBER(10,0),
    transaction_date    VARCHAR(100),
    transaction_type    VARCHAR(100)
)
COMMENT = 'Store raw loyalty_transactions data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.MAINTENANCE_LOGS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.MAINTENANCE_LOGS(
    log_id          VARCHAR(100),
    aircraft_id     VARCHAR(100),
    log_date        VARCHAR(100),
    description     VARCHAR(100),
    technician      VARCHAR(100),
    status          VARCHAR(100)
)
COMMENT = 'Store raw maintenance_logs data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.PASSENGERS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.PASSENGERS(
    passenger_id       VARCHAR(100),
    booking_id         VARCHAR(100),
    first_name         VARCHAR(100),
    middle_name        VARCHAR(100),
    last_name          VARCHAR(100),
    date_of_birth      VARCHAR(100),
    gender             VARCHAR(100),
    passport_number    VARCHAR(100),
    loyalty_id         VARCHAR(100)
)
COMMENT = 'Store raw passengers data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.PAYMENTS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.PAYMENTS(
    payment_id         VARCHAR(100),
    booking_id         VARCHAR(100),
    payment_date       VARCHAR(100),
    amount             NUMBER(10,2),
    payment_method     VARCHAR(100),
    payment_status     VARCHAR(100)
)
COMMENT = 'Store raw payments data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.REFUNDS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.REFUNDS(
    refund_id         VARCHAR(100),
    payment_id        VARCHAR(100),
    booking_id        VARCHAR(100),
    refund_date       VARCHAR(100),
    refund_amount     NUMBER(10,2),
    reason            VARCHAR(100)
)
COMMENT = 'Store raw refunds data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.SEAT_ASSIGNMENTS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.SEAT_ASSIGNMENTS(
    seat_assignment_id    VARCHAR(100),
    flight_id             VARCHAR(100),
    aircraft_id           VARCHAR(100),
    seat_number           VARCHAR(100),
    passenger_id          VARCHAR(100),
    class                 VARCHAR(100)
)
COMMENT = 'Store raw seat_assignments data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.TICKETS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.TICKETS(
    ticket_id         VARCHAR(100),
    passenger_id      VARCHAR(100),
    booking_id        VARCHAR(100),
    flight_id         VARCHAR(100),
    fare_class        VARCHAR(100),
    ticket_price      NUMBER(10,2),
    ticket_status     VARCHAR(100)
)
COMMENT = 'Store raw tickets data directly ingest from the source system without transformation';

--====================================================================================================
-- CREATING DDL FOR THE TABLE : AIRLINE_SOURCE.WEATHER_CONDITIONS
--====================================================================================================
CREATE TABLE IF NOT EXISTS AIRLINE_SOURCE.WEATHER_CONDITIONS(
    weather_id          VARCHAR(100),
    airport_id          VARCHAR(100),
    observation_date    VARCHAR(100),
    condition           VARCHAR(100),
    temperature_c       NUMBER(5,2),
    wind_speed_kmh      NUMBER(5,2),
    visibility_km       NUMBER(5,2)
)
COMMENT = 'Store raw weather_conditions data directly ingest from the source system without transformation';

COMMIT ;