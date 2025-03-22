select * FROM DYNAMICS.dbo.ACTIVITY
--DELETE FROM DYNAMICS.dbo.ACTIVITY
WHERE USERID in (
	Select USERID from DYNAMICS.dbo.ACTIVITY
	)
exec DYNAMICS.dbo.up_OrphanCleanup

select * FROM DYNAMICS.dbo.ACTIVITY
--DELETE FROM DYNAMICS.dbo.ACTIVITY
WHERE USERID in ('MaxxShip', 'dbenvin' )
exec DYNAMICS.dbo.up_OrphanCleanup
