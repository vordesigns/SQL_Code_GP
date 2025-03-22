        SELECT  RTRIM(A.USERID) AS UserID ,
        RTRIM(B.USERNAME) AS UserName ,
        RTRIM(C.INTERID) AS CompanyDatabase ,
        RTRIM(C.CMPNYNAM) AS CompanyName ,
        LOGINDAT AS LoginDate ,
        --CONVERT(VARCHAR(1000), DATEPART(HH, LOGINTIM)) + ':'
        --+ CONVERT(VARCHAR(1000), DATEPART(MI, LOGINTIM)) AS LoginTime ,
		RIGHT('0' + CONVERT(VARCHAR(2),DATEPART(HH, LOGINTIM)),2) + ':'+ RIGHT('0' + CONVERT(VARCHAR(2),DATEPART(MI, LOGINTIM)),2) AS LoginTime,
        ISNULL(CONVERT(VARCHAR(1000),E.last_batch),'') AS SQL_LastBatch ,
        CASE WHEN D.session_id IS NULL 
        THEN 'Corrupted Missing DEX_SESSION'
        ELSE CONVERT(VARCHAR(1000),session_id)
        END DEX_SESSION ,
        CASE WHEN CONVERT(VARCHAR(1000),E.SPID) IS NULL 
        THEN 'Corrupted SQL_SESSION'
        ELSE CONVERT(VARCHAR(1000),SPID) 
        END SQL_SESSION ,
        CASE WHEN DATEDIFF(mi, E.last_batch, GETDATE()) > 1
        THEN DATEDIFF(hh, E.last_batch, GETDATE())
        ELSE 0
        END AS 'IdleTime - InHours' ,
        CASE WHEN DATEDIFF(MI, LOGINDAT + LOGINTIM, GETDATE()) > 1
        THEN DATEDIFF(HH, LOGINDAT + LOGINTIM, GETDATE())
        ELSE 0
        END AS 'Logged in for – InHours'
        FROM    DYNAMICS..ACTIVITY A
        LEFT JOIN DYNAMICS..SY01400 B ON A.USERID = B.USERID
        LEFT JOIN DYNAMICS..SY01500 C ON A.CMPNYNAM = C.CMPNYNAM
        LEFT JOIN tempdb..DEX_SESSION D ON A.SQLSESID = D.session_id
        LEFT JOIN master..sysprocesses E ON D.sqlsvr_spid = E.spid
        AND ecid = 0        
        LEFT JOIN master..sysdatabases F ON E.dbid = F.dbid
--
select BCHSOURC, SERIES, CREATDDT, BACHNUMB, BCHCOMNT, GLPOSTDT, BCHSTTUS, 
	CASE BCHSTTUS 
		WHEN 0 THEN 'Available'
		WHEN 1 THEN 'Marked' 
		WHEN 2 THEN 'Available/Delete'
		WHEN 3 THEN 'Marked'
		WHEN 4 THEN 'Marked'
		WHEN 5 THEN 'Marked'
		WHEN 6 THEN 'Marked'
		WHEN 7 THEN 'Posting Interrupted'
		WHEN 8 THEN 'Journal Printing Interrupted'
		WHEN 9 THEN 'Table Updates Interrupted'
		WHEN 10 THEN 'Recurring Batch Error'
		WHEN 11 THEN 'Single Use Error'
		WHEN 15 THEN 'Computer Check Posting Error'
		WHEN 110 THEN 'Checks Printing'
		WHEN 130 THEN 'Remittance Processing '
		ELSE 'UNKNOWN' END As BatchStatus, ERRSTATE
	, NUMOFTRX, MODIFDT
FROM MAX01..SY00500 WHERE BCHSTTUS not in (0,1) ORDER BY BCHSTTUS

--UPDATE MAX01..SY00500 SET MKDTOPST=0, BCHSTTUS=0 where BACHNUMB in ('IVTFR00001550', 'GLTRX083898', 'PMPAY00005118', 'RECVG00007630', 'IVTFR00001559', 'IVTFR00001544')


/**
0	Available
1	Marked 
2	Available
3	Marked
4	Marked 
5	Marked
6	Marked
7	Posting Interrupted
8	Journal Printing Interrupted
9	Table Updates Interrupted
10	Recurring Batch Error
11	Single Use Error
15	Computer Check Posting Error
110	Checks Printing
130	Remittance Processing
**/

 /**
SELECT * FROM DYNAMICS..SY00800 
SELECT * FROM DYNAMICS..SY00801 
SELECT * FROM TEMPDB..DEX_LOCK 
SELECT * FROM TEMPDB..DEX_SESSION
SELECT BCHSTTUS,* FROM MAX01..SY00500 WHERE BCHSTTUS <> 0
**/
/** 
USE DYNAMICS
GO

SELECT 'PRE Activty' AS RecordSource, * FROM DYNAMICS..ACTIVITY
SELECT 'PRE SY00800' AS RecordSource, * FROM DYNAMICS..SY00800 
SELECT 'PRE SY00801' AS RecordSource, * FROM DYNAMICS..SY00801 

SELECT 'PRE DEX_LOCK' AS RecordSource, * FROM TEMPDB..DEX_LOCK 
SELECT 'PRE DEX_SESSION' AS RecordSource, * FROM TEMPDB..DEX_SESSION

exec dbo.up_OrphanCleanup -- <-- This doesn't impact active sessions.

SELECT 'POST Activty' AS RecordSource, * FROM DYNAMICS..ACTIVITY
SELECT 'POST SY00800' AS RecordSource, * FROM DYNAMICS..SY00800 
SELECT 'POST SY00801' AS RecordSource, * FROM DYNAMICS..SY00801 

SELECT 'POST DEX_LOCK' AS RecordSource, * FROM TEMPDB..DEX_LOCK 
SELECT 'POST DEX_SESSION' AS RecordSource, * FROM TEMPDB..DEX_SESSION
**/