-- sefty check before running ddl script 
DECLARE
    WRONG_DATABASE EXCEPTION (
        -20001,
        'Wrong database context. Expected RITSKYSNOW.'
    );
BEGIN
    IF (CURRENT_DATABASE() <> 'RITSKYSNOW') THEN
        RAISE WRONG_DATABASE;
    END IF;
END;

-- switch database to RitskySnow 
USE DATABASE RITSKYSNOW ;


CREAT OR REPLACE TABLE aircraft(
    aircraft_id      VARCHAR(100),   
    tail_number      VARCHAR(100), 
    model_id         VARCHAR(100),       
    airline_id       VARCHAR(100),   
    manufacture_year INT         ,    
    status           VARCHAR(100)
) ;
           
