-- sefty check before creating ddl script 
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