USE MAX01
GO
select top 1000 * from dbo.PM10300 WHERE BACHNUMB in ('PMVVR00000258')
select * from dbo.SY00500  WHERE BACHNUMB in ('PMVVR00000258  ')
--update dbo.SY00500 set MKDTOPST = 0 where BACHNUMB = 'TJM120619MC' - Unmark for posting
--update dbo.SY00500 set BCHSTTUS= 0 WHERE BACHNUMB = 'PMVVR00000258' -- sets to available