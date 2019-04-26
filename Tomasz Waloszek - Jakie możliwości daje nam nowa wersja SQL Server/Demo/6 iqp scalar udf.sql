-- https://sqlperformance.com/2019/01/sql-performance/scalar-udf-sql-server-2019


ALTER DATABASE AdventureWorks2016 SET COMPATIBILITY_LEVEL = 130;
GO

USE AdventureWorks2016
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO


--SET STATISTICS IO ON 
--SET STATISTICS IO OFF

SET STATISTICS TIME ON
SET STATISTICS TIME OFF

SELECT 
	soh.SalesOrderID,
	soh.OrderDate,
	sod.OrderQty,
	p.ProductID
	,Name
	,Color 
	,Size 
	,[dbo].[ufnGetStock](p.ProductID) AS InventoryQuantity
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = sod.ProductID
GO

--sp_helptext '[ufnGetStock]'
-- subquery

SELECT 
	soh.SalesOrderID,
	soh.OrderDate,
	sod.OrderQty,
	p.ProductID
	,Name
	,Color 
	,Size 
	,(SELECT SUM(pinv.[Quantity]) 
		FROM [Production].[ProductInventory] pinv
		WHERE pinv.[ProductID] = p.ProductID
			AND pinv.[LocationID] = '6') AS InventoryQuantity
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = sod.ProductID
GO



-- old school - create inline TVF
CREATE OR ALTER FUNCTION dbo.tvf_GetStock(@ProductID int)
RETURNS TABLE
AS
RETURN

	SELECT SUM(Quantity) AS InventoryQuantity
	FROM Production.ProductInventory
	WHERE ProductID = @ProductID AND LocationID = 6

GO



SELECT 
	soh.SalesOrderID,
	soh.OrderDate,
	sod.OrderQty,
	p.ProductID
	,Name
	,Color 
	,Size 
	,gets.InventoryQuantity
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = sod.ProductID
CROSS APPLY dbo.tvf_GetStock(p.ProductID) AS gets
GO





ALTER DATABASE AdventureWorks2016 SET COMPATIBILITY_LEVEL = 150;
GO

USE AdventureWorks2016
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

SELECT * FROM sys.database_scoped_configurations WHERE name = 'TSQL_SCALAR_UDF_INLINING'


SELECT 
	soh.SalesOrderID,
	soh.OrderDate,
	sod.OrderQty,
	p.ProductID
	,Name
	,Color 
	,Size 
	,[dbo].[ufnGetStock](p.ProductID) AS InventoryQuantity
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = sod.ProductID
GO

-- HINT to disable
SELECT 
	soh.SalesOrderID,
	soh.OrderDate,
	sod.OrderQty,
	p.ProductID
	,Name
	,Color 
	,Size 
	,[dbo].[ufnGetStock](p.ProductID) AS InventoryQuantity
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = sod.ProductID
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));


-- OPTION to disable
CREATE OR ALTER FUNCTION [dbo].[ufnGetStock](@ProductID [int])
RETURNS [int] 
WITH INLINE = OFF
AS 
-- Returns the stock level for the product. This function is used internally only
BEGIN
    DECLARE @ret int;
    
    SELECT @ret = SUM(p.[Quantity]) 
    FROM [Production].[ProductInventory] p 
    WHERE p.[ProductID] = @ProductID 
        AND p.[LocationID] = '6'; -- Only look at inventory in the misc storage
    
    IF (@ret IS NULL) 
        SET @ret = 0
    
    RETURN @ret
END;
GO


SELECT 
	soh.SalesOrderID,
	soh.OrderDate,
	sod.OrderQty,
	p.ProductID
	,Name
	,Color 
	,Size 
	,[dbo].[ufnGetStock](p.ProductID) AS InventoryQuantity
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = sod.ProductID
GO



SELECT is_inlineable, * FROM sys.sql_modules WHERE object_id = OBJECT_ID('ufnGetStock')




