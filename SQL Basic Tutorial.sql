-- select all
select *
from wntx.rnm_jobs_espb_detail_view



--select
select gang_name,activity_type,area,region
from wntx.rnm_jobs_espb_detail_view


-- where clause
select gang_name,activity_type,area,region
from wntx.rnm_jobs_espb_detail_view
--where gang_name = 'LEWIS TYLER' and area = 'South London Area 4'
--where gang_name in('LEWIS TYLER','REECE NELSON','MARK SEYMOUR','WILL FERGUSON')
--where gang_name like 'l%' 


--case statement 1
select gang_name,activity_type,area,region,
case 
when activity_type = 'AL' then 'Active'
when activity_type = 'VS' then' Visible'
Else activity_type
end as leaks 
from wntx.rnm_jobs_espb_detail_view

--case statement with date
select gang_name,activity_type,area,region,created_date,completed_date,

case 
	when created_date <= '2021-12-31' then 'Old'
    when created_date >'2021' then 'Current'
	else 'Unknown'
	end as Status
from wntx.rnm_jobs_espb_detail_view


--agreegate functions
select SUM(flag_complete)as Total,count(flag_complete) count
from wntx.rnm_jobs_espb_detail_view



--group by 
select gang_name,activity_type,area,region,created_date,completed_date,
flag_complete,SUM(flag_complete)as Total, count(flag_complete) count

from wntx.rnm_jobs_espb_detail_view
group by gang_name,activity_type,area,region,created_date,completed_date,flag_complete
order by  created_date asc







--CTE
--select all
with select_all as(
select *
from wntx.rnm_jobs_espb_detail_view),

--select
sel as(
select gang_name,activity_type,area,region
from wntx.rnm_jobs_espb_detail_view
),

--where clause
where_clause as(
select gang_name,activity_type,area,region
from wntx.rnm_jobs_espb_detail_view
where gang_name = 'LEWIS TYLER' and area = 'South London Area 4'),

--case statement 1
case_statement1 as(
select gang_name,activity_type,area,region,
case 
when activity_type = 'AL' then 'Active'
when activity_type = 'VS' then' Visible'
Else activity_type
end as leaks 
from wntx.rnm_jobs_espb_detail_view),

--case statement with date

case_statement_with_date as(
select gang_name,activity_type,area,region,created_date,completed_date,
case 
	when created_date <= '2021-12-31' then 'Old'
    when created_date >'2021' then 'Current'
	else 'Unknown'
	end as Status
from wntx.rnm_jobs_espb_detail_view),

--agreegate functions
agreegate_functions as(
select SUM(flag_complete)as Total,count(flag_complete) count
from wntx.rnm_jobs_espb_detail_view),

--group by 
group_by  as(
select gang_name,activity_type,area,region,created_date,completed_date,
flag_complete,SUM(flag_complete)as Total, count(flag_complete) count
from wntx.rnm_jobs_espb_detail_view
group by gang_name,activity_type,area,region,created_date,completed_date,flag_complete)


select *
from sel






--Joins

select *
from wntx.rnm_jobs_espb_detail_view A
inner join [wntx].[rnm_waiting_times_view] B

on A.operation_number_key = B.opr_operation_number_key


--union and union all

select gang_name,operation_number_key
from wntx.rnm_jobs_espb_detail_view
--where gang_name is not null
union 

select gang_name,opr_operation_number_key
from [wntx].[rnm_waiting_times_view] 
--where gang_name is not null
order by gang_name desc