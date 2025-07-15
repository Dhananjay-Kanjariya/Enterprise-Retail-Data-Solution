/*
    This script creates the database 'DataWarehouse' along with three schemas 
    representing the architectural layers of a modern data warehouse: 
    bronze (raw data), silver (cleansed data), and gold (aggregated or business-ready data).
*/

USE master;

-- Create the DataWarehouse database
CREATE DATABASE DataWarehouse;


USE DataWarehouse;
GO

-- Create schemas representing different layers of the data warehouse architecture
CREATE SCHEMA bronze;  
GO

CREATE SCHEMA silver;  
GO

CREATE SCHEMA gold;    
