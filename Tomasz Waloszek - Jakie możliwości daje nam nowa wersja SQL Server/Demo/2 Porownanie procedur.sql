USE WideWorldImporters
GO 

set statistics Time, IO ON 
GO 

-- włącz plany wykonania
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL =  130;
GO 

EXEC dbo.defrecompile 
GO 

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL =  150;

GO 
EXEC dbo.defrecompile 

-- sprawdź Query Store (Top Resource Consuming Queris)

set statistics Time, IO OFF
GO 