/*Here we have created Database - DataWarehouse and the three Architectural layers as Schemas namely
bronze, silver and gold*/


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
