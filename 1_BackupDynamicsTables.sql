-- Change Backup names before running
-- --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> Name below
BACKUP DATABASE [DYNAMICS] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\Backup\OtherUser\DYNAMICS_backup_b4_YearEndPatch_20171128.bak' WITH NOFORMAT, INIT,  NAME = N'DYNAMICS-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

-- --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> > Name below
BACKUP DATABASE [MAX01] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\Backup\OtherUser\MAX01_backup_B4YearEndPatch_20171128.bak' WITH NOFORMAT, INIT,  NAME = N'MAX01-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

-- --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> --> > Name below
BACKUP DATABASE [TST02] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.DYNAMICS02\MSSQL\Backup\OtherUser\TST02_backup_B4YearEndPatch_20171128.bak' WITH NOFORMAT, INIT,  NAME = N'TST02-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
