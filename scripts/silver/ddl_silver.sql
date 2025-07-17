/*
    This script creates cleaned and transformed data (silver layer) tables in the 'silver' schema
    of the DataWarehouse database. These tables store curated data from the bronze layer (raw CRM and ERP sources).
*/

USE DataWarehouse;
GO

-- Drop and recreate the CRM customer dimension table
IF OBJECT_ID('silver.crm_customer_dim', 'U') IS NOT NULL
    DROP TABLE silver.crm_customer_dim;
GO

CREATE TABLE silver.crm_customer_dim (
    customer_id        INT,
    customer_key       NVARCHAR(50),
    full_name          NVARCHAR(100),
    marital_status     NVARCHAR(50),
    gender             NVARCHAR(50),
    account_created_on DATE
);
GO

-- Drop and recreate the CRM product dimension table
IF OBJECT_ID('silver.crm_product_dim', 'U') IS NOT NULL
    DROP TABLE silver.crm_product_dim;
GO

CREATE TABLE silver.crm_product_dim (
    product_id       INT,
    product_key      NVARCHAR(50),
    product_name     NVARCHAR(50),
    product_cost     INT,
    product_line     NVARCHAR(50),
    product_start_dt DATETIME,
    product_end_dt   DATETIME
);
GO

-- Drop and recreate the CRM sales fact table
IF OBJECT_ID('silver.crm_sales_fact', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_fact;
GO

CREATE TABLE silver.crm_sales_fact (
    order_number NVARCHAR(50),
    product_key  NVARCHAR(50),
    customer_id  INT,
    order_date   INT,
    ship_date    INT,
    due_date     INT,
    sales_amount INT,
    quantity     INT,
    unit_price   INT
);
GO

-- Drop and recreate the ERP location dimension table
IF OBJECT_ID('silver.erp_location_dim', 'U') IS NOT NULL
    DROP TABLE silver.erp_location_dim;
GO

CREATE TABLE silver.erp_location_dim (
    customer_id NVARCHAR(50),
    country     NVARCHAR(50)
);
GO

-- Drop and recreate the ERP customer demographics dimension table
IF OBJECT_ID('silver.erp_customer_demo_dim', 'U') IS NOT NULL
    DROP TABLE silver.erp_customer_demo_dim;
GO

CREATE TABLE silver.erp_customer_demo_dim (
    customer_id NVARCHAR(50),
    birth_date  DATE,
    gender      NVARCHAR(50)
);
GO

-- Drop and recreate the ERP product category dimension table
IF OBJECT_ID('silver.erp_product_category_dim', 'U') IS NOT NULL
    DROP TABLE silver.erp_product_category_dim;
GO

CREATE TABLE silver.erp_product_category_dim (
    product_id    NVARCHAR(50),
    category      NVARCHAR(50),
    subcategory   NVARCHAR(50),
    maintenance   NVARCHAR(50)
);
GO
