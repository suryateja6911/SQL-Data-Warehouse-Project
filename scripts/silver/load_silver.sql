/*
===============================================================================
Script: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This script performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' database tables from the 'bronze' database.
    Actions performed:
        - Truncates Silver tables before loading.
        - Cleanses, standardizes, and transforms raw Bronze data before
          inserting it into Silver tables.

Note on implementation:
    This is implemented as a plain script rather than a stored procedure.
    Although MySQL does allow stored procedures here (unlike the Bronze
    load, which uses LOAD DATA and cannot run inside a procedure), a plain
    script was chosen for simplicity, easier debugging, and clearer error
    visibility while building out the transformation logic.

MySQL-specific adjustments made vs. the original SQL Server version:
    1. Column name correction:
       Bronze stores the raw source column as 'cst_material_status' (a typo
       inherited from the source system). Silver corrects this to the
       proper 'cst_marital_status' as part of the cleansing process.

    2. Zero-date handling:
       MySQL's LOAD DATA INFILE converts blank date fields into the
       placeholder '0000-00-00' during the Bronze load (unlike SQL Server's
       BULK INSERT, which loads blank dates as NULL). Strict SQL mode
       blocks MySQL from even reading/comparing these zero-dates, so
       NO_ZERO_DATE and STRICT_TRANS_TABLES are relaxed for this session
       before converting them into proper NULL values below.

    3. Function equivalents used throughout:
       LEN() -> CHAR_LENGTH(), ISNULL() -> IFNULL(),
       GETDATE() -> NOW() / CURDATE(), CAST(x AS VARCHAR) -> CAST(x AS CHAR),
       date arithmetic (date - 1) -> (date - INTERVAL 1 DAY),
       integer YYYYMMDD dates -> STR_TO_DATE(CAST(x AS CHAR), '%Y%m%d').

    4. Window functions (ROW_NUMBER, LEAD) are supported natively in
       MySQL 8.0+ with no syntax changes required.

Parameters:
    None.

Usage Example:
    Run this script directly in MySQL Workbench (select all -> execute).
===============================================================================
*/

-- ================================================
-- Loading Silver Layer (Bronze -> Silver)
-- ================================================

-- Some source records contain '0000-00-00' placeholder dates (a result of
-- how MySQL's LOAD DATA INFILE handles blank date fields, unlike SQL
-- Server). Strict mode blocks these from being read/compared, so we
-- relax it for this session before cleaning them into NULLs below.
SET SESSION sql_mode = (SELECT REPLACE(@@sql_mode, 'NO_ZERO_DATE', ''));
SET SESSION sql_mode = (SELECT REPLACE(@@sql_mode, 'STRICT_TRANS_TABLES', ''));

-- ------------------------------------------------
-- Loading CRM Tables
-- ------------------------------------------------

-- Truncating & Inserting: silver.crm_cust_info
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    CASE
        WHEN CAST(cst_create_date AS CHAR) = '0000-00-00' THEN NULL
        ELSE cst_create_date
    END AS cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;

-- Truncating & Inserting: silver.crm_prd_info
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, CHAR_LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost, 0) AS prd_cost,
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
        LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL 1 DAY
        AS DATE
    ) AS prd_end_dt
FROM bronze.crm_prd_info;

-- Truncating & Inserting: silver.crm_sales_details
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE
        WHEN sls_order_dt = 0 OR CHAR_LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
    END AS sls_order_dt,
    CASE
        WHEN sls_ship_dt = 0 OR CHAR_LENGTH(sls_ship_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
    END AS sls_ship_dt,
    CASE
        WHEN sls_due_dt = 0 OR CHAR_LENGTH(sls_due_dt) != 8 THEN NULL
        ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
    END AS sls_due_dt,
    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;

-- ------------------------------------------------
-- Loading ERP Tables
-- ------------------------------------------------

-- Truncating & Inserting: silver.erp_cust_az12
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, CHAR_LENGTH(cid))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > CURDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;

-- Truncating & Inserting: silver.erp_loc_a101
TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;

-- Truncating & Inserting: silver.erp_px_cat_g1v2
TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;

-- ================================================
-- Loading Silver Layer is Completed
-- ================================================

SELECT COUNT(*) FROM silver.crm_cust_info;
SELECT COUNT(*) FROM silver.crm_prd_info;
SELECT COUNT(*) FROM silver.crm_sales_details;
SELECT COUNT(*) FROM silver.erp_loc_a101;
SELECT COUNT(*) FROM silver.erp_cust_az12;
SELECT COUNT(*) FROM silver.erp_px_cat_g1v2;
