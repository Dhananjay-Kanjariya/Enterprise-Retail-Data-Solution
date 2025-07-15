USE master;

--Creating the database named DataWarehouse
CREATE DATABASE DataWarehouse;

USE DataWarehouse;
GO

--Creating Schemas for the database - DataWarehouse
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold
