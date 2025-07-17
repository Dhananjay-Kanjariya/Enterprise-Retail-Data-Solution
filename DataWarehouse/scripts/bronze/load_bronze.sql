/*
    Stored Procedure: bronze.load_bronze
    Purpose: Load raw data from CSV files into bronze layer tables in the DataWarehouse.
    Source Systems: CRM and ERP
    Key Features:
        - Truncates existing bronze tables
        - Loads data using BULK INSERT from local CSV files
        - Includes TRY-CATCH block for error handling
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    BEGIN TRY
        PRINT '================================================';
        PRINT '         Starting Bronze Layer Load             ';
        PRINT '================================================';

        -----------------------
        -- Load CRM Tables
        -----------------------
        PRINT '------------------------------------------------';
        PRINT '               Loading CRM Tables               ';
        PRINT '------------------------------------------------';

        -- Load bronze.crm_cust_info
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\DataWarehouse\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Load bronze.crm_prd_info
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\DataWarehouse\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Load bronze.crm_sales_details
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\DataWarehouse\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -----------------------
        -- Load ERP Tables
        -----------------------
        PRINT '------------------------------------------------';
        PRINT '               Loading ERP Tables               ';
        PRINT '------------------------------------------------';

        -- Load bronze.erp_loc_a101
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\DataWarehouse\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Load bronze.erp_cust_az12
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\DataWarehouse\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Load bronze.erp_px_cat_g1v2
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\DataWarehouse\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        PRINT '================================================';
        PRINT '         Bronze Layer Load Completed            ';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT '     ERROR OCCURRED DURING BRONZE LOAD          ';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END;
