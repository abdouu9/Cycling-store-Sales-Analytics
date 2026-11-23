
/*
===============================================================================
                            BRONZE LAYER - DATA INGESTION
===============================================================================

Description:
    This script initializes and loads the Bronze Layer of the Data Warehouse.
    It creates the necessary tables to store raw data extracted from CRM and
    ERP source systems, preserving the original structure of the source data.

Main Operations:
    1. Table Initialization:
       - Drops existing Bronze tables if they already exist.
       - Creates six tables corresponding to CRM and ERP source datasets.

    2. Data Loading:
       - Creates a stored procedure (bronze.bronze_load) to automate data ingestion.
       - Truncates existing table data before each load.
       - Uses BULK INSERT to load CSV files into their respective Bronze tables.
       - Skips header rows and uses comma-separated fields.

    3. Execution Monitoring:
       - Tracks the execution time of each table load.
       - Calculates and displays the total execution time.
       - Implements TRY...CATCH error handling to capture and display errors.

Source Systems:
    - CRM (Customer Relationship Management):
        * crm_cust_info
        * crm_prd_info
        * crm_sales_details

    - ERP (Enterprise Resource Planning):
        * erp_cust_AZ12
        * erp_loc_A101
        * erp_px_cat_G1V2

Notes:
    - The Bronze Layer stores raw data before any transformation or cleaning.
    - Source CSV file paths must be accessible to the SQL Server service account.
    - The script is designed to be re-executed, rebuilding the tables and
      reloading the source data.

===============================================================================
*/

IF OBJECT_ID ('bronze.crm_cust_info','U') is not null
	Drop table bronze.crm_cust_info;
Create table bronze.crm_cust_info (
cst_id INT,
cst_key nvarchar(50),
cst_first_name nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(50),
cst_gndr nvarchar(50),
cst_create_date date
);
IF OBJECT_ID ('bronze.crm_prd_info','U') is not null
	Drop table bronze.crm_prd_info;
Create table bronze.crm_prd_info (
prd_id INT,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost INT,
prd_line nvarchar(50),
prd_start datetime,
prd_end_dt datetime
);
IF OBJECT_ID ('bronze.crm_sales_details','U') is not null
	Drop table bronze.crm_sales_details;
Create table bronze.crm_sales_details (
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT ,
sls_price INT
);
IF OBJECT_ID ('bronze.erp_cust_AZ12','U') is not null
	Drop table bronze.erp_cust_AZ12;
Create table bronze.erp_cust_AZ12 (
CID nvarchar(50),
BDATE Date,
GEN nvarchar(50)
);
IF OBJECT_ID ('bronze.erp_loc_A101','U') is not null
	Drop table bronze.erp_loc_A101;
Create table bronze.erp_loc_A101 (
cid nvarchar(50),
cntry nvarchar(50)
);
IF OBJECT_ID ('bronze.erp_px_cat_G1V2','U') is not null
	Drop table bronze.erp_px_cat_G1V2;
Create table bronze.erp_px_cat_G1V2 (
cid nvarchar(50),
cat nvarchar(50),
sub_cat nvarchar(50) ,
maintenance nvarchar(50)
);


CREATE OR ALTER PROCEDURE bronze.bronze_load AS
BEGIN
    DECLARE @StartTime DATETIME2;
    DECLARE @EndTime DATETIME2;
    DECLARE @TableStartTime DATETIME2;
    DECLARE @TableEndTime DATETIME2;

    SET @StartTime = SYSDATETIME();

    BEGIN TRY

        PRINT '================================================';
        PRINT 'Starting Bronze Layer Data Load';
        PRINT '================================================';

        -- CRM CUSTOMER INFO
        SET @TableStartTime = SYSDATETIME();

        PRINT 'Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT 'Loading Data into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Data\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @TableEndTime = SYSDATETIME();

        
        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- CRM PRODUCT INFO
        SET @TableStartTime = SYSDATETIME();

        PRINT 'Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT 'Loading Data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Data\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @TableEndTime = SYSDATETIME();

        
        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- CRM SALES DETAILS
        SET @TableStartTime = SYSDATETIME();

        PRINT 'Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT 'Loading Data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Data\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @TableEndTime = SYSDATETIME();

        
        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- ERP CUSTOMER
        SET @TableStartTime = SYSDATETIME();

        PRINT 'Truncating Table: bronze.erp_cust_AZ12';
        TRUNCATE TABLE bronze.erp_cust_AZ12;

        PRINT 'Loading Data into: bronze.erp_cust_AZ12';
        BULK INSERT bronze.erp_cust_AZ12
        FROM 'C:\Data\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @TableEndTime = SYSDATETIME();
        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- ERP LOCATION
        SET @TableStartTime = SYSDATETIME();

        PRINT 'Truncating Table: bronze.erp_loc_A101';
        TRUNCATE TABLE bronze.erp_loc_A101;

        PRINT 'Loading Data into: bronze.erp_loc_A101';
        BULK INSERT bronze.erp_loc_A101
        FROM 'C:\Data\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @TableEndTime = SYSDATETIME();

        
        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        -- ERP PRODUCT CATEGORY
        SET @TableStartTime = SYSDATETIME();

        PRINT 'Truncating Table: bronze.erp_px_cat_G1V2';
        TRUNCATE TABLE bronze.erp_px_cat_G1V2;

        PRINT 'Loading Data into: bronze.erp_px_cat_G1V2';
        BULK INSERT bronze.erp_px_cat_G1V2
        FROM 'C:\Data\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @TableEndTime = SYSDATETIME();

        
        PRINT 'Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @TableStartTime, @TableEndTime) / 1000.0 AS VARCHAR) + ' seconds';


        SET @EndTime = SYSDATETIME();

        PRINT '================================================';
        PRINT 'Bronze Layer Data Load Completed Successfully';
        PRINT 'Total Load Duration: ' +
            CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0 AS VARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY

    BEGIN CATCH

        SET @EndTime = SYSDATETIME();

        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING BRONZE LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'Total Elapsed Time: ' +
            CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) / 1000.0 AS VARCHAR) + ' seconds';
        PRINT '================================================';

    END CATCH

END;
GO

EXEC bronze.bronze_load;

