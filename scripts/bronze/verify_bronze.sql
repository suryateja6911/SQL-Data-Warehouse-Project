/*
===============================================================================
Script: Verify Bronze Layer
===============================================================================
Script Purpose:
    This script checks the row counts of each table in the 'bronze' database
    after running load_bronze.sql, to confirm all CSV data loaded successfully.
===============================================================================
*/

SELECT COUNT(*) AS row_count FROM bronze.crm_cust_info;
SELECT COUNT(*) AS row_count FROM bronze.crm_prd_info;
SELECT COUNT(*) AS row_count FROM bronze.crm_sales_details;
SELECT COUNT(*) AS row_count FROM bronze.erp_loc_a101;
SELECT COUNT(*) AS row_count FROM bronze.erp_cust_az12;
SELECT COUNT(*) AS row_count FROM bronze.erp_px_cat_g1v2;
