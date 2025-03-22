USE MAX01
GO
--
/**
-- 1.  Make sure that you have a current backup of the company database, 
--		and ask all users to exit Microsoft Dynamics GP. To create the 
--		backup in Microsoft Dynamics GP, follow the appropriate steps 
--		after all users log off from Microsoft Dynamics GP: 
--		On the File menu, click Backup.
--		In the Company Name list, click the company that you want to 
--		back up.
--		In the Select the backup file box, click the yellow folder to 
--		open the location in which you want to put the backup file.
--		
--		Or
--		
--		In the Object Explorer, Expand your databases so you see the 
--		database you want to back up.
--		Right click the Database Name, go to Tasks, and select Backup.
--		Click the add button and select the location and file name you 
--		wish to save your backup to.
--		Click Ok to start the backup.
**/
/**
-- 2.  View the contents of the following tables to verify that 
--		all users are logged off: DYNAMICS..ACTIVITY, DYNAMICS..SY00800, 
--		DYNAMICS..SY00801, TEMPDB..DEX_LOCK, and TEMPDB..DEX_SESSION. 
--		To do this, run the following script.
**/
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
from dbo.SY00500 
WHERE BCHSTTUS <> 0
--
--SELECT * FROM DYNAMICS..ACTIVITY
--SELECT * FROM DYNAMICS..SY00800 
--SELECT * FROM DYNAMICS..SY00801 
--SELECT * FROM TEMPDB..DEX_LOCK 
--SELECT * FROM TEMPDB..DEX_SESSION

/**
-- 3.  If no results are returned, go to 'Step 4'. 
--		Otherwise, clear the stuck records by using any of the 
--		following appropriate scripts.

DELETE DYNAMICS..ACTIVITY 
DELETE DYNAMICS..SY00800 
DELETE DYNAMICS..SY00801 
DELETE TEMPDB..DEX_LOCK 
DELETE TEMPDB..DEX_SESSION
**/
/** 
-- 4.  Run the following script against the company database. 
--		Replace XXX with the batch number or the name of the batch 
--		that you are trying to post or select in Microsoft Dynamics GP.
UPDATE SY00500 SET MKDTOPST=0, BCHSTTUS=0 where BACHNUMB in ('GLTRX079144', PMVVR00000274', PMVVR00000258')
**/

  