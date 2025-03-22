Use DYNAMICS 
Select * from SY00800 
Select * from SY00801 
Select * from ACTIVITY

Use TEMPDB 
Select * from DEX_LOCK 
Select * from DEX_SESSION

--/** GP Cleanup **/
--Use DYNAMICS 
--Delete SY00800 
--Delete SY00801 
--Delete ACTIVITY

--Use TEMPDB 
--Delete DEX_LOCK 
--Delete DEX_SESSION

Use DYNAMICS
exec up_OrphanCleanup
