/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL; 

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Checking for id integrity before joining tables
SELECT sls_cust_id from silver.crm_sales_details where sls_cust_id
  not in (SELECT cst_id from silver.crm_cust_info)

SELECT sls_prd_key from silver.crm_sales_details 
WHERE sls_prd_key 
not in (SELECT prd_key from silver.crm_prd_info) 
-- Check for unwanted spaces 
SELECT * from silver.crm_sales_details 
WHERE trim(sls_ord_num)!=sls_ord_num 
OR trim(sls_ord_num)!=sls_ord_num
-- Check for Invalid Dates
-- Expectation: No Invalid Dates

SELECT 
    NULLIF(sls_order_dt, 0) AS sls_order_dt 
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_order_dt) != 8 
    OR sls_order_dt > 20500101 
    OR sls_order_dt < 19000101;

SELECT 
    NULLIF(sls_ship_dt, 0) AS sls_due_dt 
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_ship_dt) != 8 
    OR sls_ship_dt > 20500101 
    OR sls_ship_dt < 19000101;

SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM silver.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- ID integrity
select replace(trim(cid),'NAS','') from bronze.erp_cust_AZ12 where trim(cid) 
in (select trim(cst_key) from bronze.crm_cust_info)
  --Unwanted spaces
  SELECT cid from bronze.erp_cust_AZ12 where trim(cid)!= cid
  SELECT cid from bronze.erp_cust_AZ12 where trim(GEN)!= GEN
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1900-01-01' 
   OR bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
    -- unifying id bronze.erp_loc_A101
SELECT * from silver.crm_cust_info where cst_key not in (
SELECT replace(cid,'-','') from silver.erp_loc_A101);
-- Data Standardization & Consistency
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- ID integrity
select * from bronze.erp_px_cat_G1V2 where cid not in (select cat_id from silver.crm_prd_info)
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;






