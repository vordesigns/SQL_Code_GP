use TWO
GO
select *
from IV30300 i
inner join
(select ITEMNMBR,
max(DOCDATE) MaxDate
from IV30300
where DOCTYPE = 4
group by ITEMNMBR) m
on i.ITEMNMBR = m.ITEMNMBR
and i.DOCDATE = m.MaxDate
and i.DOCTYPE = 4
ORDER BY i.ITEMNMBR, i.DOCDATE, i.DOCNUMBR
GO
