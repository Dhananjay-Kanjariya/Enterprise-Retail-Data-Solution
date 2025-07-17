/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

/*
===============================================================================
Script Name: setup_analytics_gold_tables.sql
===============================================================================
Purpose:
    This script initializes the 'DataWarehouseAnalytics' database for analysis.
    It performs the following operations:
    - Drops and recreates the database if it exists.
    - Creates the required 'gold' schema and tables for analytics.
    - Loads data into these tables from pre-extracted Gold layer CSV files.
    
Usage:
    - Execute this script in Microsoft SQL Server Management Studio (SSMS).
    - Ensure the CSV file paths are accessible from the SQL Server host.
===============================================================================
*/

-- =============================================================================
-- Drop and Recreate Database
-- =============================================================================
USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- =============================================================================
-- Create Schema: gold
-- =============================================================================
CREATE SCHEMA gold;
GO

-- =============================================================================
-- Create Table: gold.dim_customers
-- =============================================================================
CREATE TABLE gold.dim_customers (
    customer_key       INT,
    customer_id        INT,
    customer_number    NVARCHAR(50),
    first_name         NVARCHAR(50),
    last_name          NVARCHAR(50),
    country            NVARCHAR(50),
    marital_status     NVARCHAR(50),
    gender             NVARCHAR(50),
    birthdate          DATE,
    create_date        DATE
);
GO

-- =============================================================================
-- Create Table: gold.dim_products
-- =============================================================================
CREATE TABLE gold.dim_products (
    product_key     INT,
    product_id      INT,
    product_number  NVARCHAR(50),
    product_name    NVARCHAR(50),
    category_id     NVARCHAR(50),
    category        NVARCHAR(50),
    subcategory     NVARCHAR(50),
    maintenance     NVARCHAR(50),
    cost            INT,
    product_line    NVARCHAR(50),
    start_date      DATE
);
GO

-- =============================================================================
-- Create Table: gold.fact_sales
-- =============================================================================
CREATE TABLE gold.fact_sales (
    order_number   NVARCHAR(50),
    product_key    INT,
    customer_key   INT,
    order_date     DATE,
    shipping_date  DATE,
    due_date       DATE,
    sales_amount   INT,
    quantity       TINYINT,
    price          INT
);
GO

-- =============================================================================
-- Load Data into gold.dim_customers
-- =============================================================================
TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\Analytics\datasets\gold.dim_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

-- =============================================================================
-- Load Data into gold.dim_products
-- =============================================================================
TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\Analytics\datasets\gold.dim_products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

-- =============================================================================
-- Load Data into gold.fact_sales
-- =============================================================================
TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM 'C:\Enterprise-Retail-Data-Warehouse-and-Analytics\Analytics\datasets\gold.fact_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO