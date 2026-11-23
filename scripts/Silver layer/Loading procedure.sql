/*
===============================================================================
Script: Silver Layer - Table Creation and Data Loading
===============================================================================

Purpose:
    This script creates and loads the Silver Layer tables of the data warehouse.
    It transforms raw data from the Bronze Layer into clean, standardized,
    and structured datasets ready for analytical use.

-------------------------------------------------------------------------------
Silver Layer Tables:
-------------------------------------------------------------------------------
    CRM:
        - silver.crm_cust_info
        - silver.crm_prd_info
        - silver.crm_sales_details

    ERP:
        - silver.erp_cust_AZ12
        - silver.erp_loc_A101
        - silver.erp_px_cat_G1V2

-------------------------------------------------------------------------------
Data Transformation and Cleansing:
-------------------------------------------------------------------------------
    1. Customer Information:
        - Remove leading and trailing spaces.
        - Remove duplicate customer records using ROW_NUMBER().
        - Retain the latest record based on creation date.
        - Exclude records with missing customer IDs or names.
        - Standardize marital status and gender values.

    2. Product Information:
        - Extract and reorganize product and category keys.
        - Replace NULL product costs with zero.
        - Standardize product line descriptions.
        - Calculate product end dates using LEAD().

    3. Sales Details:
        - Convert integer date values into DATE format.
        - Handle invalid and missing dates.
        - Recalculate incorrect or missing sales amounts.
        - Correct invalid product prices.
        - Prevent division by zero using NULLIF().

    4. ERP Customer Information:
        - Standardize customer IDs.
        - Handle invalid birth dates.
        - Standardize gender values.

    5. ERP Location:
        - Standardize customer IDs.
        - Normalize country names.
        - Handle missing country values.

    6. ERP Product Categories:
        - Remove leading and trailing spaces.
        - Standardize maintenance values into binary indicators.

-------------------------------------------------------------------------------
Stored Procedure: silver.silver_load
-------------------------------------------------------------------------------
    - Truncate existing Silver Layer tables before reloading.
    - Load transformed data from the Bronze Layer.
    - Execute all loading operations within a transaction.
    - Use TRY...CATCH for error handling.
    - Use XACT_ABORT ON to handle transaction failures.
    - Display execution messages and loading durations for each table.
    - Monitor total execution time.
    - Roll back the transaction if an error occurs.

-------------------------------------------------------------------------------
Technical Details:
-------------------------------------------------------------------------------
    SQL Server | T-SQL | Stored Procedures | Data Cleansing
    Data Transformation | Window Functions | Transactions
    Error Handling | Execution Time Monitoring

===============================================================================
*/

IF OBJECT_ID ('silver.crm_cust_info','U') is not null
	Drop table silver.crm_cust_info;
Create table silver.crm_cust_info (
cst_id INT,
cst_key nvarchar(50),
cst_first_name nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(50),
cst_gndr nvarchar(50),
cst_create_date date,
create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.crm_prd_info','U') is not null
	Drop table silver.crm_prd_info;
Create table silver.crm_prd_info (
prd_id INT,
cat_id nvarchar(50),
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost INT,
prd_line nvarchar(50),
prd_start_dt date,
prd_end_dt date,
create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.crm_sales_details','U') is not null
	Drop table silver.crm_sales_details;
Create table silver.crm_sales_details (
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT ,
sls_price INT ,
create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.erp_cust_AZ12','U') is not null
	Drop table silver.erp_cust_AZ12;
Create table silver.erp_cust_AZ12 (
CID nvarchar(50),
BDATE Date,
GEN nvarchar(50) ,
create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.erp_loc_A101','U') is not null
	Drop table silver.erp_loc_A101;
Create table silver.erp_loc_A101 (
cid nvarchar(50),
cntry nvarchar(50),
create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.erp_px_cat_G1V2','U') is not null
	Drop table silver.erp_px_cat_G1V2;
Create table silver.erp_px_cat_G1V2 (
cid nvarchar(50),
cat nvarchar(50),
sub_cat nvarchar(50) ,
maintenance nvarchar(50),
create_date datetime2 default getdate()
);



CREATE OR ALTER PROCEDURE silver.silver_load AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @StartTime DATETIME2;
    DECLARE @EndTime DATETIME2;
    DECLARE @TableStartTime DATETIME2;
    DECLARE @TableEndTime DATETIME2;

    SET @StartTime = SYSDATETIME();

    BEGIN TRY

        BEGIN TRANSACTION;

        PRINT '================================================';
        PRINT 'Starting Silver Layer Data Load';
        PRINT '================================================';


        -- CRM CUSTOMER INFO
        SET @TableStartTime = SYSDATETIME();

        PRINT '------------------------------------------------';
        PRINT 'Truncating Table: silver.crm_cust_info';

        TRUNCATE TABLE silver.crm_cust_info;

        PRINT 'Loading Data into: silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_first_name,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_first_name),
            TRIM(cst_lastname),
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS rn
            FROM bronze.crm_cust_info
        ) t
        WHERE rn = 1
          AND cst_id IS NOT NULL
          AND cst_first_name IS NOT NULL
          AND cst_lastname IS NOT NULL;

        SET @TableEndTime = SYSDATETIME();

        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- CRM PRODUCT INFO
        SET @TableStartTime = SYSDATETIME();

        PRINT '------------------------------------------------';
        PRINT 'Truncating Table: silver.crm_prd_info';

        TRUNCATE TABLE silver.crm_prd_info;

        PRINT 'Loading Data into: silver.crm_prd_info';

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
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ) - 1 AS DATE
            ) AS prd_end_dt
        FROM bronze.crm_prd_info;

        SET @TableEndTime = SYSDATETIME();

        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- CRM SALES DETAILS
        SET @TableStartTime = SYSDATETIME();

        PRINT '------------------------------------------------';
        PRINT 'Truncating Table: silver.crm_sales_details';

        TRUNCATE TABLE silver.crm_sales_details;

        PRINT 'Loading Data into: silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_price,
            sls_quantity
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,

            CASE
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,

            CASE
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,

            CASE
                WHEN sls_sales IS NULL
                  OR sls_sales <= 0
                  OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price,

            sls_quantity

        FROM bronze.crm_sales_details;

        SET @TableEndTime = SYSDATETIME();

        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- ERP CUSTOMER
        SET @TableStartTime = SYSDATETIME();

        PRINT '------------------------------------------------';
        PRINT 'Truncating Table: silver.erp_cust_AZ12';

        TRUNCATE TABLE silver.erp_cust_AZ12;

        PRINT 'Loading Data into: silver.erp_cust_AZ12';

        INSERT INTO silver.erp_cust_AZ12 (
            cid,
            BDATE,
            GEN
        )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%' THEN REPLACE(TRIM(cid), 'NAS', '')
                ELSE cid
            END AS cid,

            CASE
                WHEN bdate <= '1900/01/01' OR bdate >= GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,

            CASE
                WHEN UPPER(TRIM(gen)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(gen)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END AS gen

        FROM bronze.erp_cust_AZ12;

        SET @TableEndTime = SYSDATETIME();

        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- ERP LOCATION
        SET @TableStartTime = SYSDATETIME();

        PRINT '------------------------------------------------';
        PRINT 'Truncating Table: silver.erp_loc_A101';

        TRUNCATE TABLE silver.erp_loc_A101;

        PRINT 'Loading Data into: silver.erp_loc_A101';

        INSERT INTO silver.erp_loc_A101 (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', '') AS cid,

            CASE
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry

        FROM bronze.erp_loc_A101;

        SET @TableEndTime = SYSDATETIME();

        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- ERP PRODUCT CATEGORY
        SET @TableStartTime = SYSDATETIME();

        PRINT '------------------------------------------------';
        PRINT 'Truncating Table: silver.erp_px_cat_G1V2';

        TRUNCATE TABLE silver.erp_px_cat_G1V2;

        PRINT 'Loading Data into: silver.erp_px_cat_G1V2';

        INSERT INTO silver.erp_px_cat_G1V2 (
            cid,
            cat,
            sub_cat,
            maintenance
        )
        SELECT
            TRIM(cid) AS cid,
            TRIM(cat) AS cat,
            TRIM(sub_cat) AS sub_cat,

            CASE
                WHEN maintenance = 'Yes' THEN 1
                ELSE 0
            END AS maintenance

        FROM bronze.erp_px_cat_G1V2;

        SET @TableEndTime = SYSDATETIME();

        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- COMMIT TRANSACTION
        COMMIT TRANSACTION;

        SET @EndTime = SYSDATETIME();

        PRINT '================================================';
        PRINT 'Silver Layer Data Load Completed Successfully';
        PRINT 'Total Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0 AS VARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @EndTime = SYSDATETIME();

        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING SILVER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'Total Elapsed Time: ' +
            CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0 AS VARCHAR) + ' seconds';
        PRINT '================================================';

        THROW;

    END CATCH

END;
GO

-- Execute Silver Layer Load
EXEC silver.silver_load;

