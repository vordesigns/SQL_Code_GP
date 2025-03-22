/*
Script can be run whether an upgrade is ongoing or not. If not currently ongoing, will give information regarding previous upgrade. 
If system database is something other than DYNAMICS, change USE DYNAMICS line to reflect.

Revision history:

2020-12-23 Lance Brigham: First script using internal Velosio check update status script and another found online to add elapsed and estimated time remaining 
2020-12-28 Lance Brigham: Added logic to use prior upgrade's average time for calcuating estimated if a company hasn't completed yet to base current upgrade on
*/

USE DYNAMICS

DECLARE @db_verBuild INT
DECLARE @db_verMajor INT
DECLARE @PRODID INT=0 

SELECT @db_verMajor=MAX(db_verMajor) FROM DB_Upgrade WHERE PRODID=@PRODID
SELECT @db_verBuild=MAX(db_verBuild) FROM DB_Upgrade WHERE PRODID=@PRODID AND db_verMajor=@db_verMajor

DECLARE
	@TotalCompanies INT,
	@CompletedCompanies INT,
	@start_time DATETIME,
	@stop_time DATETIME,
	@UpgradeOngoing BIT,
	@MinDurationSecondsCompletedCompany INT,
	@MaxDurationSecondsCompletedCompany INT,
	@AvgDurationSecondsCompletedCompany INT,
	@EstimatedCompletionTime DATETIME,
	@ElapsedTimeSeconds INT

SELECT 
	@TotalCompanies=(SELECT COUNT(*) FROM DB_Upgrade WHERE PRODID=@PRODID AND [db_name] <> DB_NAME()),
	@CompletedCompanies=(SELECT COUNT(*) FROM DB_Upgrade WHERE PRODID=@PRODID AND db_verMajor=@db_verMajor AND db_verBuild=@db_verBuild AND [db_name] <> DB_NAME() AND db_status=0),
	@start_time=MIN(start_time),
	@stop_time=MAX(stop_time),
	@UpgradeOngoing=
		CASE 
			WHEN EXISTS (SELECT 1 FROM DB_Upgrade WHERE PRODID=@PRODID AND (db_verOldMajor<@db_verMajor OR db_verOldBuild<@db_verBuild)) 
				THEN 1 
			ELSE 0 
		END,
	@stop_time=
		CASE @UpgradeOngoing 
			WHEN 1 
				THEN GETDATE() 
			ELSE @stop_time 
		END
FROM DB_Upgrade
WHERE PRODID=@PRODID AND db_verMajor=@db_verMajor AND db_verBuild=@db_verBuild

SELECT 
	@ElapsedTimeSeconds=SUM(DATEDIFF(SECOND,start_time,stop_time))
FROM DB_Upgrade 
WHERE PRODID=@PRODID AND db_verMajor=@db_verMajor AND db_verBuild=@db_verBuild AND db_status=0

SELECT 
	@MinDurationSecondsCompletedCompany=MIN(DATEDIFF(SECOND,start_time,stop_time)),
	@MaxDurationSecondsCompletedCompany=MAX(DATEDIFF(SECOND,start_time,stop_time)), 
	@AvgDurationSecondsCompletedCompany=AVG(DATEDIFF(SECOND,start_time,stop_time))
FROM DB_Upgrade 
WHERE PRODID=@PRODID AND db_verMajor=@db_verMajor AND db_verBuild=@db_verBuild AND [db_name] <> DB_NAME() AND db_status=0

--If @AvgDurationSecondsCompletedCompany is NULL because a company hasn't completed yet, use prior upgrade time to estimate upgrade duration
IF @AvgDurationSecondsCompletedCompany IS NULL
	SELECT 
		@AvgDurationSecondsCompletedCompany=AVG(DATEDIFF(SECOND,start_time,stop_time))
	FROM DB_Upgrade 
	WHERE PRODID=@PRODID AND (db_verMajor<@db_verMajor OR db_verBuild<@db_verBuild) AND [db_name] <> DB_NAME() AND db_status=0
		
--Parse estimated completion time to number of seconds using @AvgDurationSecondsCompletedCompany multiplied by number of companies
SELECT
	@EstimatedCompletionTime=
		CONVERT(VARCHAR,DATEADD(SECOND,@AvgDurationSecondsCompletedCompany*(@TotalCompanies-@CompletedCompanies),@stop_time),120),
	@EstimatedCompletionTime=
		DATEADD(SECOND,ISNULL((SELECT SUM(DATEDIFF(SECOND,GETDATE(),start_time)) FROM DB_Upgrade WHERE PRODID=@PRODID AND db_verMajor=@db_verMajor AND db_verBuild=@db_verBuild AND [db_name] <> DB_NAME() AND db_status<>0),0),@EstimatedCompletionTime),
	@EstimatedCompletionTime=
		CASE WHEN @EstimatedCompletionTime<GETDATE()
			THEN DATEADD(SECOND,3,@EstimatedCompletionTime) 
			ELSE @EstimatedCompletionTime
		END
		
SELECT 
	@TotalCompanies Companies,
	@CompletedCompanies Completed,
	CAST((1.0*@CompletedCompanies)/@TotalCompanies*100 AS INT) PctComplete,
	CONVERT(VARCHAR,@start_time,120) StartTime,
	CASE 
		WHEN @UpgradeOngoing=1
			THEN CONVERT(VARCHAR,DATEDIFF(SECOND, @start_time, @stop_time)/3600)+':'+RIGHT('0'+CONVERT(VARCHAR,DATEDIFF(SECOND, @start_time, @stop_time)%3600/60),2)+':'+RIGHT('0'+CONVERT(VARCHAR,(DATEDIFF(SECOND, @start_time, @stop_time)%60)),2) 
		ELSE
			CONVERT(VARCHAR,@ElapsedTimeSeconds/3600)+':'+RIGHT('0'+CONVERT(VARCHAR,@ElapsedTimeSeconds%3600/60),2)+':'+RIGHT('0'+CONVERT(VARCHAR,(@ElapsedTimeSeconds%60)),2) 
	END Elapsed,
	CASE 
		WHEN @UpgradeOngoing=0 OR @EstimatedCompletionTime IS NULL OR @EstimatedCompletionTime<GETDATE()
			THEN ''
		ELSE
			CONVERT(VARCHAR(5),DATEDIFF(SECOND, @stop_time, @EstimatedCompletionTime)/3600)+':'+RIGHT('0'+CONVERT(VARCHAR(2),DATEDIFF(SECOND, @stop_time, @EstimatedCompletionTime)%3600/60),2)+':'+RIGHT('0'+CONVERT(VARCHAR(2),(DATEDIFF(SECOND, @stop_time, @EstimatedCompletionTime)%60)),2)
	END EstTimeRem,
	CASE 
		WHEN @UpgradeOngoing=0 OR @EstimatedCompletionTime IS NULL OR @EstimatedCompletionTime<GETDATE()		
			THEN ''
		ELSE
			CONVERT(VARCHAR,@EstimatedCompletionTime,120)
	END EstCompletionTime,
	CASE
		WHEN @UpgradeOngoing=0 AND @CompletedCompanies=@TotalCompanies
			THEN (SELECT CONVERT(VARCHAR,MAX(stop_time),120) FROM DB_Upgrade)
		ELSE ''
	END ActualCompletion,
	CASE WHEN @CompletedCompanies>0
		THEN CONVERT(VARCHAR,@MinDurationSecondsCompletedCompany/3600)+':'+RIGHT('0'+CONVERT(VARCHAR,@MinDurationSecondsCompletedCompany%3600/60),2)+':'+RIGHT('0'+CONVERT(VARCHAR,(@MinDurationSecondsCompletedCompany%60)),2) 
		ELSE ''
	END Min,
	CASE WHEN @CompletedCompanies>0
		THEN CONVERT(VARCHAR,@MaxDurationSecondsCompletedCompany/3600)+':'+RIGHT('0'+CONVERT(VARCHAR,@MaxDurationSecondsCompletedCompany%3600/60),2)+':'+RIGHT('0'+CONVERT(VARCHAR,(@MaxDurationSecondsCompletedCompany%60)),2) 
		ELSE ''
	END Max,
	CASE WHEN @CompletedCompanies>0
		THEN CONVERT(VARCHAR,@AvgDurationSecondsCompletedCompany/3600)+':'+RIGHT('0'+CONVERT(VARCHAR,@AvgDurationSecondsCompletedCompany%3600/60),2)+':'+RIGHT('0'+CONVERT(VARCHAR,(@AvgDurationSecondsCompletedCompany%60)),2) 
		ELSE ''
	END Avg

IF OBJECT_ID('tempdb.dbo.#GPDBFileSize') IS NOT NULL DROP TABLE #GPDBFileSize
SELECT A.INTERID,A.CMPANYID,A.CMPNYNAM,C.SizeDataMB,D.SizeLogsMB
INTO #GPDBFileSize
FROM 
	(
		SELECT A.db_name INTERID,ISNULL(CMPANYID,0) CMPANYID,ISNULL(CMPNYNAM,'') CMPNYNAM
		FROM DB_Upgrade A
			LEFT JOIN SY01500 B ON A.db_name=B.INTERID 
		WHERE A.PRODID=0 
	) A
	INNER JOIN sys.databases B ON A.INTERID=B.name
	INNER JOIN (SELECT database_id,SUM(size*8/1024) 'SizeDataMB' FROM sys.master_files WHERE type=0 GROUP BY database_id) C ON B.database_id=C.database_id
	INNER JOIN (SELECT database_id,SUM(size*8/1024) 'SizeLogsMB' FROM sys.master_files WHERE type=1 GROUP BY database_id) D ON B.database_id=D.database_id	

SELECT 
	db_name, 
	CASE WHEN B.CMPANYID IS NOT NULL THEN CAST(B.CMPANYID AS VARCHAR(10)) ELSE '' END ID,
	CASE WHEN B.CMPNYNAM IS NOT NULL THEN RTRIM(B.CMPNYNAM) ELSE '' END CMPNYNAM,
	db_verMajor, 
	db_verMinor,
	db_verBuild,
	CONVERT(VARCHAR(30),start_time,120) StartTime,
	CASE WHEN start_time<>stop_time THEN CONVERT(VARCHAR(30),stop_time,120) ELSE '' END AS StopTime,
	CASE 
		WHEN start_time<>stop_time THEN CONVERT(VARCHAR, stop_time - start_time, 8) 
		ELSE CONVERT(VARCHAR, GETDATE() - start_time, 8) 
	END AS Duration,
	CASE 
		WHEN db_status = 0 THEN '1 - Upgraded' 
		WHEN db_status <> 0 THEN '2 - In Process' 
	END AS Status,
	CASE 
		WHEN db_status = 0 THEN '' 
		ELSE 'Step ' + CAST(db_status as CHAR(2)) + '/59' 
	END AS Progress,
	B.SizeDataMB,
	B.SizeLogsMB
FROM DB_Upgrade A 
	INNER JOIN #GPDBFileSize B ON A.db_name=B.INTERID
WHERE 
	PRODID=@PRODID 
	AND 
	db_verMajor = @db_verMajor
	AND
	db_verBuild = @db_verBuild
UNION ALL
SELECT 
	db_name, 
	CASE WHEN B.CMPANYID IS NOT NULL THEN CAST(B.CMPANYID AS VARCHAR(10)) ELSE '' END,
	CASE WHEN B.CMPNYNAM IS NOT NULL THEN RTRIM(B.CMPNYNAM) ELSE '' END,
	db_verMajor, 
	db_verMinor,
	db_verBuild,
	'' AS StartTime, 
	'' AS StopTime,
	'' AS Duration,
	'3 - Not Upgraded' as Status,
	'',
	B.SizeDataMB,
	B.SizeLogsMB
FROM DB_Upgrade A 
	INNER JOIN #GPDBFileSize B ON A.db_name=B.INTERID
WHERE 
	PRODID=@PRODID 
	AND 
	(
		db_verMajor < @db_verMajor
		OR 
		(
			db_verMajor = @db_verMajor
			AND 
			db_verBuild < @db_verBuild
		)
	)
ORDER BY Status,StartTime,CMPNYNAM



