--Demo 1
-- włącz plna wykonania!!!!
USE [tpch_10]
GO 

SET Statistics time ON;
GO 

ALTER DATABASE [tpch_10] 
    SET COMPATIBILITY_LEVEL = 150;
GO 

ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = ON;


-- ok.10s
SELECT MONTH(l.l_shipdate) as [Month],
		SUM(l.[l_quantity]) as [Total Quantity],
		SUM(l.l_tax) as [Total Tax]
	FROM dbo.lineitem l
	GROUP BY MONTH(l.l_shipdate)
	ORDER BY MONTH(l.l_shipdate)
	OPTION (RECOMPILE);
GO 



ALTER DATABASE [tpch_10] 
    SET COMPATIBILITY_LEVEL = 140;
GO 



-- ok.16s
	SELECT MONTH(l.l_shipdate) as [Month],
		SUM(l.[l_quantity]) as [Total Quantity],
		SUM(l.l_tax) as [Total Tax]
	FROM dbo.lineitem l
	GROUP BY MONTH(l.l_shipdate)
	ORDER BY MONTH(l.l_shipdate)
	OPTION (RECOMPILE);



SET Statistics time OFF;
GO 


ALTER DATABASE [tpch_10] 
    SET COMPATIBILITY_LEVEL = 150;
GO 

