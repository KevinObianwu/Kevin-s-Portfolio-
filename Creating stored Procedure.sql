
--creating stored procedure
create procedure[DPBICBG]. Games as 
select *
from [DPBICBG].[excel_Test]


--alter stored procedure
alter procedure [DPBICBG]. Games as 
select *
from [DPBICBG].[excel_Test]
where Region = 'united kingdom'

--drop procedure

drop procedure  [DPBICBG].Games


--execute procedure
execute [DPBICBG].Games