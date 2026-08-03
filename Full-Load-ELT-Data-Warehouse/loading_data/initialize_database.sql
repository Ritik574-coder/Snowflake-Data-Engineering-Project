/*##################################################################################################
    Snowflake Database Initialization

    Database : RitSkySnow

    Purpose:
        This database contains the RitSky Retail Analytics Data Warehouse.

    Data Architecture:
        Raw
            Contains raw, source-aligned datasets with minimal transformations.
##################################################################################################*/

-- Use the SYSADMIN role.
USE ROLE SYSADMIN;

-- Create the RitSkySnow database if it does not already exist.
CREATE DATABASE IF NOT EXISTS RITSKYSNOW
    COMMENT = 'Contains the RitSky Retail Analytics Data Warehouse.';

-- Set RitSkySnow as the active database.
USE DATABASE RITSKYSNOW;

-- Create the RAW schema if it does not already exist.
CREATE SCHEMA IF NOT EXISTS AIRLINE_SOURCE
    COMMENT = 'Contains raw, source-aligned data with minimal transformations.';

