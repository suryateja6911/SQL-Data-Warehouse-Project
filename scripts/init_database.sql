-- =============================================================
-- Create Databases: 'bronze', 'silver', 'gold'
-- =============================================================
-- This script creates 3 new databases: 'bronze', 'silver', and 'gold'.
-- These databases act as the layers of the Medallion Architecture
-- (equivalent to SQL Server's single 'DataWarehouse' database
-- with 'bronze', 'silver', 'gold' schemas inside it).
--
-- WARNING:
--     Running this script will DROP the 'bronze', 'silver', and 'gold'
--     databases if they already exist. All data in these databases will
--     be permanently deleted. Proceed with caution and ensure you have
--     proper backups before running this script.
-- =============================================================

-- Drop and recreate the 'bronze' database
DROP DATABASE IF EXISTS bronze;
CREATE DATABASE bronze;

-- Drop and recreate the 'silver' database
DROP DATABASE IF EXISTS silver;
CREATE DATABASE silver;

-- Drop and recreate the 'gold' database
DROP DATABASE IF EXISTS gold;
CREATE DATABASE gold;
