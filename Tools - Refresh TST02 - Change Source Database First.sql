USE master;
GO
ALTER DATABASE TST02
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO
DECLARE @BackupFileName varchar(100), @sql nvarchar(max);
------------------------------------------------------------------------
--					   ENTER FILE NAME
                  --
                    --
SET @BackupFileName = 'MAX01_backup_2022_04_26_230001_5476530'+'.bak'
                    --
                  --
--
------------------------------------------------------------------------
SET @sql = 'RESTORE DATABASE [TST02] FROM  DISK = N''C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\Backup\'
SET @sql = @sql+@BackupFileName
SET @sql = @sql+''' WITH  FILE = 1,  MOVE N''GPSMAX01Dat.mdf'' TO N''C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\DATA\GPSTST02Dat.mdf'',  MOVE N''GPSMAX01Log.ldf'' TO N''C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\DATA\GPSTST02Log.ldf'',  NOUNLOAD,  REPLACE,  STATS = 5'
--PRINT @sql
exec sp_executesql  @sql;
ALTER DATABASE TST02
SET MULTI_USER;
GO

