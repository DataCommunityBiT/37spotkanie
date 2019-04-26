USE WideWorldImporters 
GO 

select 
	qsp.plan_id, 
	qsp.compatibility_level,
	AVG(qsrs.avg_duration)/1000 AS avg_duration_ms,
	AVG(qsrs.avg_logical_io_reads) AS avg_logical_IO

From sys.query_store_plan AS qsp
INNER JOIN sys.query_store_runtime_stats AS qsrs
ON qsp.plan_id = qsrs.plan_id
AND qsp.query_id =99599 -- wstawić swój plan ID
Group by qsp.plan_id, qsp.compatibility_level
GO 