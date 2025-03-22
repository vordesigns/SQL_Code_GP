/* 
--- 
--- STEP 1:  Go find the latest full backup in C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\Backup\
---
--- STEP 2:  Change <CHANGE ME> below to the name of the backup you want to restore  You will be restoring from a MAX01 database backup
---
---			NOTE:  Sometimes, the script below for restoring the database fails becaused the SQL server can't get exclusive access
---				There aren't any services that I can determine would cause this, it must be a user connection of some sort.
---				TRY AGAIN
---
--- STEP 3:	After you run the databAse restore, un-hilite the database restore, then select the Execute button.
---			The database fixup process will run for TST02
---
--- STEP 4:  CLOSE THIS SCRIPT WITHOUT SAVING
---
-- Steps for restore
------------------------ SELECT FROM JUST BELOW HERE --
USE master;
GO
ALTER DATABASE TST02
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
----
----Set database backup file <CHANGE_ME>
----
USE [master]
---
--- REPLACE <CHANGE ME> --
---
RESTORE DATABASE [TST02] FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\Backup\<CHANGE ME>' WITH  FILE = 1,  MOVE N'GPSMAX01Dat.mdf' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\DATA\GPSTST02Dat.mdf',  MOVE N'GPSMAX01Log.ldf' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\DATA\GPSTST02Log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5
------------------------------------------------------------------------------------------------------------->FILE NAME ABOVE HERE  --
---
GO
ALTER DATABASE TST02
SET MULTI_USER;
GO
------------------------ TO JUST ABOVE HERE --
*/
USE [TST02]
GO
/**
--------------------------------------------------------------------------------------------
After creating new test company or restoring a fresh copy of production over the test; run
	this script which will fix up the database ID, INTERID, etc., and make DYNSA the dbo.
NOTE:  There are special considerations for 
	HR
	Auditing
	Reporting
		
--------------------------------------------------------------------------------------------
https://support.microsoft.com/en-us/help/871973/set-up-a-test-company-that-has-a-copy-of-live-company-data-for-microso
--------------------------------------------------------------------------------------------
Set up a test company that has a copy of live company data for Microsoft Dynamics GP by using 
Microsoft SQL Server
--------------------------------------------------------------------------------------------
SUMMARY
--------------------------------------------------------------------------------------------
To test certain issues, a troubleshooting technique may be to copy the Live Company database 
to a Test Company database.
This article describes how to set up a test company that has a copy of live company data by 
using Microsoft SQL Server.
--------------------------------------------------------------------------------------------
MORE INFORMATION
--------------------------------------------------------------------------------------------
Notes
If you use Record Level Notes 
- in your existing live company and plan to use them in the 
test company, you must run the NoteFix utility. For more information, contact the Microsoft 
Business Solutions System Technical Support team by telephone at (888) 477-7877.

If you are using Human Resources for Microsoft Dynamics GP
- The Attendance Setup information appears to have not been copied over. To open this window, 
click Tools, point to Setup, point to Human Resources, point to Attendance, and then click 
Setup. This table (TAST0130) is copied over, but it contains a field that still references 
the Live Company database. To correct this issue, you can simply re-enter the data in the 
Attendance Setup window in the new Test company database to contain the same information as 
before and Save it. Or, you may choose to update the COMPANYCODE_I field in the TAST0130 
table to change the company code reference to Test database instead (which can be found in 
the INTERID column value for the Test company in the Dynamics..SY01500 table).  

If you are using Fixed Assets for Microsoft Dynamics GP
- The Fixed Assets Company Setup information will not be brought over to the Test Company. 
To correct this issue, open the Fixed Assets Company Setup window in the Live Company and 
note the settings. Open the Fixed Assets Company Setup window in the Test Company and enter 
the same settings as the Live Company. To open the window, use the following:
	Microsoft Dynamics GP 10.0 or a later version:
	Click Microsoft Dynamics GP, point to Tools, point to Setup, point to System, point to 
	Fixed Assets, and then click Company.

If you are using Audit Trails for Microsoft Dynamics GP
- You must delete the audit triggers from the test company using SQL and not from the front-end. 
Audit Trails is just triggers that are copied over and still point to the same live audit 
database. However, do not delete, stop or remove the audit in the Audit Trail Maintenance 
window in the test company, or this will clear out the history in the audit table and/or 
remove the trigger on the live company. Refer to steps outlined in the KB article below to 
remove the audit trail triggers from the test company:
--------------------------------------------------------------------------------------------
2847491 How to stop Audit Trail triggers in the test company from updating the live audit 
database using Audit Trails in Microsoft Dynamics GP
If you are using Analytical Accounting (AA), you must first activate AA in the Test company, 
before the live company database (that has AA active) can be restored to the Test company. 
After the restore is completed, you must then click on the link below to obtain a script to 
run against the Test company database that will update the next available values stored in 
the AAG00102 table (to prevent Duplicate Key errors when keying new transactions).
https://mbs2.microsoft.com/fileexchange/?fileID=a80eb2b7-dbcf-4d5f-a7a2-f64306f65721

	• If you are using Management Reporter 2012, you must stop the Management Reporter 
		services which can be done using either of the following options:

		1.  In the Management Reporter 2012 Configuration Console, on the first page, 
			you’ll see both the Management Reporter 2012 Application Service and Management 
			Reporter 2012 Process Service. Click Stop under these two services to stop them.

		2.  Click on Start, click on Control Panel, click on Administrative Tools, then click 
			to open Services. In the Services window, highlight the Management Reporter 2012 
			Application Service and click on the link to Stop this service. Also, highlight 
			the Management Reporter 2012 Process Service and click the link to Stop this 
			service as well.

Microsoft provides programming examples for illustration only, without warranty either 
expressed or implied. This includes, but is not limited to, the implied warranties of 
merchantability or fitness for a particular purpose. This article assumes that you are 
familiar with the programming language that is being demonstrated and with the tools that 
are used to create and to debug procedures. Microsoft support engineers can help explain 
the functionality of a particular procedure. However, they will not modify these examples 
to provide added functionality or construct procedures to meet your specific requirements.
--------------------------------------------------------------------------------------------
To set up the test company, follow these steps:
--------------------------------------------------------------------------------------------
In Utilities, create a new company database that you can use as the test company. Make sure 
	that you give the database a unique DB/company ID and company name that will designate 
	the database as a test company. For example, you could use a DB/company ID of "TEST" and 
	a company name of "TEST COMPANY."
--------------------------------------------------------------------------------------------
!!SSG 
	Use COMPANY <TEST>
	This will cause a warning that you are using a test company on load.
--------------------------------------------------------------------------------------------
Note Note the path where the database's .mdf and .ldf files are being created. You will need 
	this information for a step later in this article.
--------------------------------------------------------------------------------------------
Log in to the test company. To do this, use the following step.
	Microsoft Dynamics GP 10.0 or later:
	Click Microsoft Dynamics GP, click Tools, click Setup, click System, and then click User 
	Access. 
	In the User Access area, select the user to whom you want to grant access to the test 
	company database. Then, click to select the check box next to the test company name 
	to grant access to the test company database. Repeat this step for all users to whom 
	you want to grant access to the test company database. To do this, use the following 
	step..
	Microsoft Dynamics GP 10.0 and Microsoft Dynamics 2010: Click Microsoft Dynamics GP, 
	click Tools, click Setup, click System, and then click User Access. 
	Make a backup of the live company database. To do this, use one of the following 
	methods, 
	as appropriate for your situation.
--------------------------------------------------------------------------------------------
Method 1
--------------------------------------------------------------------------------------------
If you are using SQL Server Enterprise Manager, follow these steps:
	Click Start, and then click
	Programs.
	Point to Microsoft SQL Server, and then click Enterprise Manager.
	Expand Microsoft SQL Servers, expand
	SQL Server Group, and then expand the instance of SQL Server.
	Expand Databases, right-click the live company database, click All Tasks, and then 
	click Backup Database.
	In the SQL Server Backup window, click
	Add in the Destination section.
	In the Select Backup Destination window, click the ellipsis button next to the File 
	name field.
	In the Backup Device Location window, expand the folders, and then select the location 
	for the backup file.
	Type a name for the backup file. For example, type
	Live.bak.
	Click OK repeatedly until you return to the SQL Server Backup window.
	Click OK to start the backup.
	When the backup has completed successfully, click
	OK.
--------------------------------------------------------------------------------------------
Method 2
--------------------------------------------------------------------------------------------
If you are using SQL Server Management Studio, follow these steps:
Click Start, and then click
Programs.
Point to Microsoft SQL Server, and then click SQL Server Management Studio. The Connect to 
Server window opens.
In the Server name box, type the name of the instance of SQL Server.
In the Authentication list, click
SQL Authentication.
In the User name box, type
sa.
In the Password box, type the password for the sa user, and then click Connect.
In the Object Explorer section, expand Databases.
Right-click the live company database, point to
Tasks, and then click Backup.
In the Destination area, click
Remove, and then click Add.
In the Destination on disk area, click the ellipsis button.
Find the location where you want to create the backup file, type a name for the backup 
file, such as LIVE.bak, and then click OK.
Click OK repeatedly until you return to the Backup Database window.
Click OK to start the backup.
Restore the live company backup file that you created in step 4 into the test company 
database. To do this, use one of the following methods, as appropriate for your situation.
--------------------------------------------------------------------------------------------
Note The logical file name reflects the name of the live database. Do not change the logical 
file name.
To change these locations, click on the Ellipse (…) next to the file location field.
Navigate to the path that you noted in step 1, where the test database was created.
Highlight the respective .mdf file, and then click
OK.
Repeat steps p through r, select the .ldf file, and then click OK.
Click to select the Overwrite existing database check box.
Click OK to return to the Restore Database window
If you are using Microsoft Dynamics GP 10.0 or later, follow these steps to copy the 
security permissions from the live company to the test company:
Log on to Microsoft Dynamics GP as the sa user.
Click Microsoft Dynamics GP, point to
Tools, point to Setup, point to
System, and then click User Access.
Select an appropriate user, and then make sure that the check box for the new test company 
is selected to indicate that access is granted.
--------------------------------------------------------------------------------------------
Note If you receive an error message when you click to select a company, delete the user 
from the Users folder under the new test database in SQL Server Management Studio or in 
Enterprise Manager.
Click Microsoft Dynamics GP, point to
Tools, point to Setup, point to
System, and then click User Security.
In the Security Task Setup window, select the user who you want to have access to the test 
company.
In the Company list, click the live company.
Click Copy, click to select the check box that is next to the test company, and then click 
OK.
--------------------------------------------------------------------------------------------
The user’s permissions in the live company are copied to the test company.
After the live company database has been restored over the top of the test company database, 
the test company contains references that have the same COMPANYID and INTERID information 
that the live company has. To correctly reflect the information for the test company, run the 
following script below against the test company in Query Analyzer or in SQL Server Management 
Studio. This script updates the COMPANYID and INTERID in the test database with the 
information that is listed in the system database SY01500 table for this test company.
--------------------------------------------------------------------------------------------
**/
--
-- Added by TA (SSG) 2020/08/06
delete from TST02.dbo.SVC00010 where INTERID = 'MAX01'
--
if exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SY00100') begin
  declare @Statement varchar(850)
  select @Statement = 'declare @cStatement varchar(255)
declare G_cursor CURSOR for
select case when UPPER(a.COLUMN_NAME) in (''COMPANYID'',''CMPANYID'')
  then ''update ''+a.TABLE_NAME+'' set ''+a.COLUMN_NAME+'' = ''+ cast(b.CMPANYID as char(3)) 
  else ''update ''+a.TABLE_NAME+'' set ''+a.COLUMN_NAME+'' = ''''''+ db_name()+'''''''' end
from INFORMATION_SCHEMA.COLUMNS a, '+rtrim(DBNAME)+'.dbo.SY01500 b
  where UPPER(a.COLUMN_NAME) in (''COMPANYID'',''CMPANYID'',''INTERID'',''DB_NAME'',''DBNAME'')
    and b.INTERID = db_name() and COLUMN_DEFAULT is not null
 and rtrim(a.TABLE_NAME)+''-''+rtrim(a.COLUMN_NAME) <> ''SY00100-DBNAME''
  order by a.TABLE_NAME
set nocount on
OPEN G_cursor
FETCH NEXT FROM G_cursor INTO @cStatement
WHILE (@@FETCH_STATUS <> -1)
begin
  exec (@cStatement)
  FETCH NEXT FROM G_cursor INTO @cStatement
end
close G_cursor
DEALLOCATE G_cursor
set nocount off'
  from SY00100
  exec (@Statement)
end
else begin
  declare @cStatement varchar(255)
  declare G_cursor CURSOR for
  select case when UPPER(a.COLUMN_NAME) in ('COMPANYID','CMPANYID')
    then 'update '+a.TABLE_NAME+' set '+a.COLUMN_NAME+' = '+ cast(b.CMPANYID as char(3)) 
    else 'update '+a.TABLE_NAME+' set '+a.COLUMN_NAME+' = '''+ db_name()+'''' end
  from INFORMATION_SCHEMA.COLUMNS a, DYNAMICS.dbo.SY01500 b
    where UPPER(a.COLUMN_NAME) in ('COMPANYID','CMPANYID','INTERID','DB_NAME','DBNAME')
      and b.INTERID = db_name() and COLUMN_DEFAULT is not null
    order by a.TABLE_NAME
  set nocount on
  OPEN G_cursor
  FETCH NEXT FROM G_cursor INTO @cStatement
  WHILE (@@FETCH_STATUS <> -1)
  begin
    exec (@cStatement)
    FETCH NEXT FROM G_cursor INTO @cStatement
  end
  close G_cursor
  DEALLOCATE G_cursor
  set nocount off
end
GO
/**
Note If this script fails with a duplicate key error, you must manually change the INTERID 
and COMPANYID columns in the table on which you are receiving the primary key error in the 
test company.
--------------------------------------------------------------------------------------------
For example: A primary key constraint error on "PKRVLPD033." To properly perform a search 
for the table, the prefix, PK, refers to Primary Key and is not part of the table name. In 
this example, the table that you want to verify is "RVLPD033" for that database.
--------------------------------------------------------------------------------------------
Note  If you are using Human Resources, you must also change the COMPANYCODE_I value in the 
TAST0130 table. See the NOTES section at the top of this article for more information. 
Verify that the database owner of the test database is DYNSA. To do this, run the following 
script against the test company in Query Analyzer or in SQL Server Management Studio:
--------------------------------------------------------------------------------------------
**/
EXEC sp_changedbowner 'DYNSA'
GO
/**
--------------------------------------------------------------------------------------------
If you use the drilldown functionality in the SQL Server Reporting Services or Excel 
integrated reports you need to do the following to update your server links so the 
drilldowns work after the database change:
--------------------------------------------------------------------------------------------
Ensure that everyone has logged out of Microsoft Dynamics GP and close all instances of SQL 
Server Management Studio
On a machine where Dynamics GP is installed click on Start, then point to All Programs. 
Click on Microsoft Dynamics, then GP 2010 and click on Database Maintenance
When the utility opens select or enter the SQL Server instance where the Dynamics GP 
databases are stored. If you are logged in as a domain account with rights to this SQL Server 
instance you can select that option. Otherwise select SQL Authentication and enter an 
appropriate user name and password. Then click Next >>
Select Mark All to choose each of the Dynamics GP databases and click Next >>
Select the Microsoft Dynamics GP product, then click Next >>
Select 'Functions and Stored Procedures' and 'Views', then click Next >>
Review the confirmation window, then click Next >> to begin the process.
--------------------------------------------------------------------------------------------
The test company should now have a copy of the live company data and be ready for use.
--------------------------------------------------------------------------------------------
**/
