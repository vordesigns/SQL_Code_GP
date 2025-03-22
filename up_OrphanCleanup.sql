USE [DYNAMICS]
GO

/****** Object:  StoredProcedure [dbo].[up_OrphanCleanup]    Script Date: 6/11/2024 9:47:18 AM ******/
DROP PROCEDURE [dbo].[up_OrphanCleanup]
GO

/****** Object:  StoredProcedure [dbo].[up_OrphanCleanup]    Script Date: 6/11/2024 9:47:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[up_OrphanCleanup] 

AS

BEGIN
-- =============================================
-- Author:		SSG/tsa
-- Create date: 02/16/2017
-- Description:	Remove orphans from Dynamics GP
-- =============================================
--/**
--SQL server maintains a record of active user sessions in the table SYSPROCESSES from the  MASTER  database, 
--inside sysprocesses there is a column named “login name” and we  base  our  script  on  sysprocesses  to  
--clear  the  ACTIVITY  table from the DYNAMICS database.
--Once ACTIVITY table has  been  cleaned out we are ready to clean 2 tables from the TEMP database  first  we  
--clean  DEX_SESSION and then DEX_LOCK in order to eliminate locks and processes in temp tables.
--The next step is to clean batch activity (SY00800) and resource activity (SY00801) in order to have a valid 
--session clean up.
---- Reeferencces
---- A batch is held in the Posting, Receiving, Busy, Marked, Locked, or Edited status in Microsoft Dynamics GP 
---- (KB 850289)
----		https://mbs.microsoft.com/knowledgebase/KBDisplay.aspx?scid=kb;en-us;850289
---- How to remove all the inactive sessions from the DEX_LOCK table in the TempDB database when you use 
---- Microsoft Dynamics GP together with Microsoft SQL Server 
---- (KB 864411)
----		https://mbs.microsoft.com/knowledgebase/KBDisplay.aspx?scid=kb;en-us;864411
---- How to remove all the inactive sessions from the DEX_SESSION table in the TempDB database when you use 
---- Microsoft Dynamics GP together with Microsoft SQL Server 
----(KB 864413)
----		https://mbs.microsoft.com/knowledgebase/KBDisplay.aspx?scid=kb;en-us;864413
--**/
--/** Delete orphans from Dynamics **/
delete from DYNAMICS..ACTIVITY 
    where USERID not in
        (select loginame from master..sysprocesses) 
delete from tempdb..DEX_SESSION 
    where session_id not in 
        (select SQLSESID from DYNAMICS..ACTIVITY) 
delete from tempdb..DEX_LOCK 
    where session_id not in 
        (select SQLSESID from DYNAMICS..ACTIVITY) 
delete from DYNAMICS..SY00800 
    where USERID not in 
        (select USERID from DYNAMICS..ACTIVITY) 
delete from DYNAMICS..SY00801 
    where USERID not in 
        (select USERID from DYNAMICS..ACTIVITY)
END
GO


