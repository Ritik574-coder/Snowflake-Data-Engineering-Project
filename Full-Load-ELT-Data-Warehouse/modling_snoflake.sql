/*##################################################################################################
    Snowflake Database Initialization
    Database : RitSkySnow
    Purpose:
        This database contains the RitSky retail data platform.
    Data Architecture:
        Bronze
            Contains raw/source-aligned datasets with minimal transformation.
        Silver
            Contains cleaned, standardized, validated, and transformed datasets.
            Business rules required for data quality and standardization are applied here.
        Gold
            Contains business-ready analytical datasets and data models used for
            reporting, dashboards, and downstream analytics.
    Design:
        Bronze -> Silver -> Gold
##################################################################################################*/
-- using system admint role 
USE ROLE SYSADMIN ; 

-- creating databse named RitSkySnow it not exists 
CREATE DATABASE IF NOT EXISTS RitskySnow 
    COMMENT = 'This databse contain imformation about the ritsky retail data only '; 

-- switch databse to RitSkySnow 
USE DATABASE RitSkySnow ; 

-- creating bronze schema if not exists 
CREATE SCHEMA IF NOT EXISTS Bronze 
    COMMENT = 'Creating bronze schema this schema contain information about only raw data' ;

-- creating bronze schema if not exists 
CREATE SCHEMA IF NOT EXISTS Silver
    COMMENT = 'The silver schema contain and hold info about only cleand and transformed dataset' ;

-- creating bronze schema if not exists 
CREATE SCHEMA IF NOT EXISTS Gold
    COMMENT = 'The Gold schema contain business ready to use data for reporting dashboard etc.. ' ;