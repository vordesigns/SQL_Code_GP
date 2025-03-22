-- GLOBAL SETTINGS
SET NOCOUNT ON
-- DECLARATIONS
declare @IsEnabled int
	, @ISOleEnabled int;
--LOCAL SETTINGS
	SET @IsEnabled = (SELECT CONVERT(INT, ISNULL(value, value_in_use)) FROM  sys.configurations WHERE  name = 'xp_cmdshell');
	SET @ISOleEnabled = (SELECT CONVERT(INT, ISNULL(value, value_in_use)) FROM  sys.configurations WHERE  name =  'Ole Automation Procedures');
---- IsEnabled ?
if @IsEnabled = 0
	-- NO
	BEGIN
		--PRINT 'xp_cmdshell is disabled, enabling'
		-- update the currently configured value for advanced options.
		-- To allow advanced options to be changed.
		EXEC sp_configure 'show advanced options', 1;
		-- To update the currently configured value for advanced options.
		RECONFIGURE;
		-- To enable the feature.
		EXEC sp_configure 'xp_cmdshell', 1;
		-- To update the currently configured value for this feature.
		RECONFIGURE;
	END
	--ELSE
	-- YES
		--PRINT 'xp_cmdshell is enabled'
--
--PRINT 'Running xp_cmdshell process'
	EXEC xp_cmdshell '"C:\GPUtil\Production_CheckLinks_Reconcile.bat"'
--
-- GET DIRECTORY LISTING
---- ENABLE OLE Automation Procedures NOT NECESSARY (I dont' think it is)
----if @ISOleEnabled = 0
----	BEGIN
----		--PRINT 'OLE Autmation Default is disabled, enabling'
----	EXEC sp_configure 'show advanced options', 1;  
----	RECONFIGURE;  
----	EXEC sp_configure 'Ole Automation Procedures', 1;  
----	RECONFIGURE;  
----	END
----	ELSE 
----		--PRINT 'OLE Automation Default is enabled, continuing'

---- Get Directory listing and send as an email
---- NO MAIL PROFILE
--	EXEC msdb.dbo.sp_send_dbmail
--		-- Below is the primary Recipient
--		@recipients = 'tmarcure@maxxess-systems.com',
--		@importance = 'High', 
--		-- Below are the CC Recipients
--		--@copy_recipients = 'dcervelli@ssgnet.com' ,
--		@subject = 'Maxxess:  Reconciliation Reports Are ready for Review', 
--		@body = 'The Reconcilliation process has completed.  If there are any issues, please contact your support representative',
--		@query = 'SET NOCOUNT ON DECLARE @files table (ID int Identity, FileName varchar(100)) insert into @files execute xp_cmdshell "dir C:\GPReports\ /b" select * from @files where FileName IS NOT NULL SET NOCOUNT OFF',
--		@query_attachment_filename = 'Results.txt',
--		@profile_name ='<TBD>';

------ DISABLE OLE Automation Procedures
----if @ISOleEnabled = 0
----	BEGIN
----		--PRINT 'OLE Automation Default is disabled, disabling'
----		EXEC sp_configure 'show advanced options', 1;  
----		RECONFIGURE;  
----		EXEC sp_configure 'Ole Automation Procedures', 0;  
----		--EXEC sp_configure 'show advanced options', 0;
----		RECONFIGURE;
----	END
----	ELSE
----		--PRINT 'OLE Automation Default is enabled, continuing'

----
-- Reset xp_cmdShell if it should be disabled
if @IsEnabled = 0
	BEGIN
		--PRINT 'xp_cmdshell was disabled, disabling'
		-- To disable the feature.
		EXEC sp_configure 'xp_cmdshell', 0;
		-- To update the currently configured value for this feature.
		RECONFIGURE;
		-- update the currently configured value for advanced options.
		-- To disallow advanced options to be changed.
		EXEC sp_configure 'show advanced options', 0;
		RECONFIGURE;
	END
	--ELSE
		--PRINT 'xp_cmdshell was enabled, ending'
SET NOCOUNT OFF
--PRINT 'Process complete'