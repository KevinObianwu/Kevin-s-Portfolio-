
--creating view
create view [DPBICBG].Activity_Excel_Join as

(select *
from
[DPBICBG].Activity)


--alter view
alter view [DPBICBG].Activity_Excel_Join as

(select *
from
[DPBICBG].Activity as ACT


--joining the tables
left join [DPBICBG].[excel_Test] as Excel
on ACT.Customer_id = Excel.ID)

--delete view
delete [DPBICBG].Activity_Excel_Join

--drop table
drop view [DPBICBG].Activity_Excel_Join

--Run view
select * from [DPBICBG].Activity_Excel_Join