
--creating the table
create table [DPBICBG].Activity(
Customer_id int)


--alter the table(add only once)
alter table [DPBICBG].Activity
add Name varchar (100),
sport varchar (100)




--insert value into table
insert into [DPBICBG].Activity(Customer_id,Name,sport)

--Rows value
values
('1','Mary-Ann','Tennis'),('2','Owen','basketball'),('3','Connor','football'),('4','David','rowing'),('5','Kevin','Base_ball')
,('6','James','Swimming')
--delete from table(still keeps column structure)
delete from [DPBICBG].Activity
where name = 'connor'


--drop table
drop table [DPBICBG].Activity

--similar to delete but cant use where 
truncate table [DPBICBG].Activity


--update table
update [DPBICBG].Activity
set Name = 'Connor'
where Customer_id = '3'



select *
from
[DPBICBG].Activity
