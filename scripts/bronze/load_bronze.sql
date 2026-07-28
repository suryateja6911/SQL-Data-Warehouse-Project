/*
===============================================================================
Script: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This script loads data into the 'bronze' database from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses `LOAD DATA LOCAL INFILE` to load data from CSV files into bronze tables.

Note:
    This is implemented as a plain script rather than a stored procedure,
    since MySQL does not allow `LOAD DATA` statements inside stored
    procedures or functions (unlike SQL Server's `BULK INSERT`).

Important fix — line endings:
    The source CSV files use Windows-style line endings (\r\n), not plain
    Unix-style (\n). Using LINES TERMINATED BY '\n' loads correctly for
    most columns, but leaves a hidden trailing carriage-return character
    (\r) attached to the LAST column of every row. This silently broke
    string comparisons in the Silver layer (e.g. every 'gen' value in
    erp_cust_az12 fell through to 'n/a' because "M\r" never matched 'M',
    even after TRIM(), since TRIM() does not remove \r).
    Fix: use LINES TERMINATED BY '\r\n' for all tables below.

Usage Example:
    Run this script directly in MySQL Workbench (select all -> execute),
    or via command line:
        mysql -u root -p --local-infile=1 < load_bronze.sql
===============================================================================
*/

-- ================================================
-- Loading Bronze Layer
-- ================================================

-- ------------------------------------------------
-- Loading CRM Tables
-- ------------------------------------------------

-- Truncating & Inserting: bronze.crm_cust_info
TRUNCATE TABLE bronze.crm_cust_info;
LOAD DATA LOCAL INFILE 'C:/Users/Phani/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Truncating & Inserting: bronze.crm_prd_info
TRUNCATE TABLE bronze.crm_prd_info;
LOAD DATA LOCAL INFILE 'C:/Users/Phani/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Truncating & Inserting: bronze.crm_sales_details
TRUNCATE TABLE bronze.crm_sales_details;
LOAD DATA LOCAL INFILE 'C:/Users/Phani/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ------------------------------------------------
-- Loading ERP Tables
-- ------------------------------------------------

-- Truncating & Inserting: bronze.erp_loc_a101
TRUNCATE TABLE bronze.erp_loc_a101;
LOAD DATA LOCAL INFILE 'C:/Users/Phani/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Truncating & Inserting: bronze.erp_cust_az12
TRUNCATE TABLE bronze.erp_cust_az12;
LOAD DATA LOCAL INFILE 'C:/Users/Phani/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Truncating & Inserting: bronze.erp_px_cat_g1v2
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE 'C:/Users/Phani/Downloads/sql-data-warehouse-project/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ================================================
-- Loading Bronze Layer is Completed
-- ================================================
