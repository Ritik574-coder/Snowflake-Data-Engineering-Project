-- Create an internal stage
-- Create an internal stage
USE DATABASE NORMALIZE_DW;
USE SCHEMA STAGING;

CREATE OR REPLACE STAGE staging_stage;

-- Upload raw CSV files
PUT 'file:///home/ritik/Snowflake-Data-Engineering-Project/database-design-normalization/normalization_practice_dataset/raw/*.csv'
    @staging_stage
    AUTO_COMPRESS = TRUE;

-- Upload advanced CSV files
PUT 'file:///home/ritik/Snowflake-Data-Engineering-Project/database-design-normalization/normalization_practice_dataset/advanced/*.csv'
    @staging_stage
    AUTO_COMPRESS = TRUE;