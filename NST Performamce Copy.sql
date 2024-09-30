/*SCRIPT NAME:                    [NST_Performance]
    LAST MODIFIED DATE:           29/12/2022
    LAST MODIFIED BY:             Kevin Obianwu
	TABLE CREATED FOR:			  Business Insights Team
    CHANGE REF NO:                00
    SOURCE TABLES & ALIASES:      cbg_cdm_output_operations, [dbo].[people_table_availability_data]

    CHANGE LOG      00  MD          Created File

notes:
1) Data is pulled in preperation for reporting on performance of NSTs for a period of time
2) Unions 11 different data translations

*/

declare 
	@startdate date = '2023-04-01' /*getdate()- 31*/ --DATEadd(wk,-13,getdate())
	, @enddate date  = '2023-04-30' /*getdate()*/
	, @region varchar(100) = '%west%'
	, @job varchar(100) = '%NST%'
	,@startwork date = getdate() - 30 -- declare @startwork date
	


/*a To be replaced with the monthly people data which will include manager names*/
; with NST_TV as
(select distinct opr_operation_number_employee_key,EM.Line_Manager_Name
	,SUBSTRING(opr_operation_number_employee_text, CHARINDEX(' ', opr_operation_number_employee_text) + 1, LEN(opr_operation_number_employee_text) - CHARINDEX(' ', opr_operation_number_employee_text)) + ' ' + SUBSTRING(opr_operation_number_employee_text, 1, CHARINDEX(' ', opr_operation_number_employee_text) - 1) as NST
	,opr_operation_number_work_centre_text

	from cbg_cdm_output_operations as OP
	left join cbg_monthly_employee_list_BIT_update EM
	ON OP.opr_operation_number_employee_key = em.Emp_No

where opr_operation_number_work_centre_text like @job and opr_operation_number_work_centre_text like @region
	and operation_created_datetime > @startwork
	),
--------------------------------------------------------------
/*b 8.25 is the working hours for an NST*/Complete_Jobs as
(select 
	opr_operation_number_employee_key
	, opr_operation_number_work_centre_text
	,sum(case when opr_operation_number_op_latest_usr_status_text LIKE '%COMP%' then 8.25 else 0 END) as COMP_Hours
	,sum(case when opr_operation_number_op_latest_usr_status_text LIKE '%UNCO%' then 8.25 else 0 END) as UNCO_Hours
from cbg_cdm_output_operations
where operation_created_datetime between @startdate and  @enddate
	and opr_operation_number_work_centre_text like @job
	and opr_operation_number_work_centre_text like @region
group by opr_operation_number_employee_key , opr_operation_number_work_centre_text
	),
--------------------------------------------------------------
/*e*/absencetotal as(
select pe_employee_key,
	sum(core4) as core
	,sum(overtime4) as overtime
	,sum(bankedhours4) as bankedhours
	,sum(business4) as business
	,sum(CRP4) as CRP
	,sum(project4) as project
	,sum(personal4) as personal
from (
select pe_employee_key
,pe_calendar_day
	,sum(core3) as core4
	,sum(overtime3) as overtime4
	,sum(bankedhours3) as bankedhours4
	,sum(business3) as business4
	,sum(project3) as project4
	,sum(case when CRP3 > (case when (core3 - (personal3 + business3 + project3)) < 0 then 0 else (core3 - (personal3 + business3 + project3)) end ) then core3 - (personal3 + business3) else CRP3 end) as CRP4
	,sum(personal3) as personal4
from(
select pe_employee_key
,pe_calendar_day
	,sum(CRP2) as CRP3
	,sum(core2) as core3
	,sum(overtime2) as overtime3
	,sum(bankedhours2) as bankedhours3
	,sum(personal2) as personal3
	,sum(project2) as project3
	,sum(case when Business2 + project2 > (case when core2 - Personal2 < 0  then 0 else core2 - Personal2 end) then core2 - Personal2 else Business2 + project2 end) as business3
from (
select pe_employee_key
	,pe_calendar_day
	,sum(CRP1) as CRP2
	,sum(core1) as core2
	,sum(overtime1) as overtime2
	,sum(bankedhours1) as bankedhours2
	,sum(business1) as business2
	,sum(case when Personal1 > core1 then core1 else Personal1 end) as Personal2
	,sum(project1) as project2
from (
select pe_employee_key, pe_calendar_day, sum(hoursadj) total_hours
	,sum(case when Absence_Reason = 'Banked Hours' then hoursadj else 0 end) as bankedhours1
	,sum(case when Absence_Reason = 'Project' then hoursadj else 0 end) as project1
	,sum(case when Absence_Reason = 'Core Hours'  then hoursadj else 0 end) as core1
	,sum(case when Absence_Reason = 'CRP' then hoursadj else 0 end) as CRP1
	,sum(case when Absence_Reason = 'Overtime' then hoursadj else 0 end) as overtime1
	,sum(case when Absence_Reason = 'Business'  then hoursadj else 0 end) as business1
	,sum(case when Absence_Reason = 'Personal'  then hoursadj else 0 end) as personal1
from (
select pe_calendar_day, pe_employee_key, hoursadj 
,case when type_text in
	('Absence without leave'
	/*,'Authorised Appointment'*/
	,'C19 - WFH'
	,'C19 - WFH High Risk'
	,'C19 Dependant Leave(Paid)'
	,'Career Break'
	,'Dependants Leave (Paid)'
	,'Dependants Leave (Unpaid)'
	,'Jury Service'
	,'Parental Bereavement'
	,'Parental Leave (Paid)'
	,'Parental Leave (Unpaid)'
	,'Paternity Leave'
	,'Phased Return'
	/*,'Restricted Duties'*/
	,'Sick Leave'
	,'Special Leave (Paid)'
	,'Special Leave (Unpaid)'
	/*,'Time Off In Lieu'*/
	,'Study/Exam Leave'
	,'Unplanned Absence'
	,'Planned Absence'
	,'Annual Leave')
	then 'Personal' 
when type_text = 'Core Hours' then 'Core Hours'
when type_text = 'Project Work' then 'Project'
when type_text = 'Banked Hours' then 'Banked Hours'
when type_text = 'Compulsory Rest Period' then 'CRP'
when type_text = 'Overtime Hours' then 'Overtime'
else 'Business' end  as Absence_Reason
from (
select pe_calendar_day, pe_employee_key, hours, type_text , pe_work_centre_zemploy_workcenter_key,
	sum(case when pe_calendar_day IN 
	('2022-01-03'
,'2022-04-15'
,'2022-04-18'
,'2022-05-02'
,'2022-06-02'
,'2022-06-03'
,'2022-08-29'
,'2022-09-19'
,'2022-12-26'
,'2022-12-27'
,'2023-01-02'
,'2023-04-07'
,'2023-04-10'
,'2023-05-01'
,'2023-05-08'
,'2023-05-29'
,'2023-08-28'
,'2023-12-25'
,'2023-12-26'
,'2024-01-01'
,'2024-03-29'
,'2024-04-01'
,'2024-05-06'
,'2024-05-27'
,'2024-08-26'
,'2024-12-25'
,'2024-12-26'
,'2025-01-01'
,'2025-04-18'
,'2025-04-21'
,'2025-05-05'
,'2025-05-26'
,'2025-08-25'
,'2025-12-25'
,'2025-12-26') /*Bank Holiday dates*/ and type_text LIKE '%core%' then 0 else hours END) as hoursadj 
from [dbo].[people_table_availability_data]
where pe_work_centre_zemploy_workcenter_text like '%NST%'
	and pe_work_centre_zemploy_workcenter_text like '%west%'
	and pe_calendar_day between '2022-11-01' and  '2022-11-30'
group by pe_calendar_day, pe_employee_key, hours, type_text , pe_work_centre_zemploy_workcenter_key) c 
	) d
group by pe_employee_Key, pe_calendar_day
	) a1 group by pe_employee_Key, pe_calendar_day
)a2 group by pe_employee_key
,pe_calendar_day) a3 group by pe_employee_key
,pe_calendar_day) a4 group by pe_employee_key)
,
--------------------------------------------------------------
/*h*/ spanner_time_adj as (
select pe_employee_key
	,case when (AdjustedSpannerTimeAct = 0 or AdjustedPlannedSpannerTime1 = 0) then 0 else (AdjustedPlannedSpannerTime1/ AdjustedSpannerTimeAct) end as SpannerEfficiency
from 
(select
	pe_employee_key
	,sum(case when AdjustedPlannedSpannerTime > 9 then 9 else AdjustedPlannedSpannerTime end) as AdjustedPlannedSpannerTime1
	,sum(AdjustedSpannerTimeAct) as AdjustedSpannerTimeAct
	from (
	select
	pe_employee_key
	,pe_work_centre_zemploy_workcenter_text
	,pe_actual_spanner_time
	,pe_planned_work_for_efficiency
	,case when pe_actual_spanner_time > 0  and (pe_planned_work_for_efficiency is null or pe_planned_work_for_efficiency = 0) then pe_actual_spanner_time 
	when pe_planned_work_for_efficiency > 0 and (pe_actual_spanner_time is null or pe_actual_spanner_time = 0) then 0
	else pe_planned_work_for_efficiency 
	end as AdjustedPlannedSpannerTime
	,case when pe_actual_spanner_time > 9 then 9 else pe_actual_spanner_time  end as AdjustedSpannerTimeAct
	from [dbo].[people_table_work_time_data]
	where pe_work_centre_zemploy_workcenter_text like @job
	and pe_work_centre_zemploy_workcenter_text like @region
	and pe_calendar_day between @startdate and  @enddate
	) f
	group by pe_employee_key
	) g 
	) ,
--------------------------------------------------------------
/*i*/Uncomplete_jobs as
	(select 
	opr_operation_number_employee_key
	,sum(case when opr_operation_number_op_latest_usr_status_text LIKE '%UNCO%' then 1 else  0 end) as UNCO
	,sum(case when opr_operation_number_op_latest_usr_status_text LIKE '%COMP%' then 1 else  0 end) as COMP
	,sum(case when opr_actual_operation_type_key LIKE '%CASTO%' then 1 else  0 end) as ASTO
	,sum(case when opr_actual_operation_type_key  like '%ABORT' then 1 else 0 end) as Aborts
	from cbg_cdm_output_operations 
	where operation_created_datetime between @startdate and  @enddate
	and opr_operation_number_work_centre_text like @job
	and opr_operation_number_work_centre_text like @region
	group by opr_operation_number_employee_key
	),
--------------------------------------------------------------
/*k*/ timings as (
	select opr_operation_number_employee_key
	,SUM(DATEDIFF(MINUTE,CAST(opr_op_dispatch_date AS DATETIME) + CAST(opr_operation_first_time_in_progress_time_key AS DATETIME) ,CAST(opr_operation_actual_end_date AS DATETIME) + CAST(opr_operation_actual_end_time AS DATETIME)))/(count(opr_operation_number_key)*60) as avg_task_time_hours
	,count(opr_operation_number_key) operations
		from (select *
	from cbg_cdm_output_operations 
where opr_op_dispatch_date is not null 
and opr_operation_number_work_centre_text like @job 
and opr_operation_number_work_centre_text like @region
and opr_op_dispatch_date between @startdate and  @enddate
and opr_operation_number_employee_key is not null
and opr_operation_first_time_in_progress_time_key is not null
and opr_operation_actual_end_time is not null ) j
group by opr_operation_number_employee_key
),
--------------------------------------------------------------
/*n*/first_job_start as (
select 
opr_operation_number_employee_key
, convert(varchar(5),DATEADD(MINUTE,SUM(DATEDIFF(MINUTE,0, CAST(opr_operation_first_time_in_progress_time_key AS DATETIME))) / (count(rn)),0),108) as avg_start_first_task
from (
select * from	
 (	
    select	
	opr_operation_number_employee_key,
opr_operation_number_employee_text,
opr_op_dispatch_date,
opr_completion_date,
opr_operation_first_time_in_progress_time_key,
opr_operation_actual_end_time,

        row_number() over(partition by opr_op_dispatch_date, opr_operation_number_employee_text order by opr_operation_first_time_in_progress_time_key asc) as rn
		

FROM DBO.cbg_cdm_input_operations
where opr_op_dispatch_date is not null
and opr_operation_number_work_centre_text like @job 
and opr_operation_number_work_centre_text like @region
and opr_op_dispatch_date between @startdate and  @enddate
	
) l
where rn = 1	) m
group by opr_operation_number_employee_key)
,
--------------------------------------------------------------
/*q*/last_job_start as (
Select opr_operation_number_employee_key 
,convert(varchar(5),DATEADD(MINUTE,SUM(DATEDIFF(MINUTE,0,CAST(opr_operation_actual_end_time AS DATETIME)))/(count(rn)),0),108) as avg_start_last_task
from (
select * from	
 (	
    select	
	opr_operation_number_employee_key,
opr_operation_number_employee_text,
opr_op_dispatch_date,
opr_completion_date,
opr_operation_first_time_in_progress_time_key,
opr_operation_actual_end_time,

        row_number() over(partition by opr_op_dispatch_date, opr_operation_number_employee_text order by opr_operation_first_time_in_progress_time_key desc) as rn
		

FROM DBO.cbg_cdm_input_operations
where opr_op_dispatch_date is not null 
and opr_operation_number_work_centre_text like @job 
and opr_operation_number_work_centre_text like @region
and opr_op_dispatch_date between @startdate and  @enddate
) o	
where rn = 1	) p
group by opr_operation_number_employee_key
),
--------------------------------------------------------------
/*t*/first_job_end as (
select 
opr_operation_number_employee_key
, convert(varchar(5),DATEADD(MINUTE,SUM(DATEDIFF(MINUTE,0, CAST(opr_operation_first_time_in_progress_time_key AS DATETIME))) / (count(rn)),0),108) as avg_end_first_task
from (
select * from	
 (	
    select	
	opr_operation_number_employee_key,
opr_operation_number_employee_text,
opr_op_dispatch_date,
opr_completion_date,
opr_operation_first_time_in_progress_time_key,
opr_operation_actual_end_time,

        row_number() over(partition by opr_op_dispatch_date, opr_operation_number_employee_text order by opr_operation_actual_end_time asc) as rn
		

FROM DBO.cbg_cdm_input_operations
where opr_op_dispatch_date is not null
and opr_operation_number_work_centre_text like @job 
and opr_operation_number_work_centre_text like @region
and opr_op_dispatch_date between @startdate and  @enddate
	
) r
where rn = 1	) s 
group by opr_operation_number_employee_key)
,
-------------------------------------------------------------
/*w*/last_job_End as (
Select opr_operation_number_employee_key 
,convert(varchar(5),DATEADD(MINUTE,SUM(DATEDIFF(MINUTE,0,CAST(opr_operation_actual_end_time AS DATETIME)))/(count(rn)),0),108) as avg_end_last_task
from (
select *
from	
 (	
    select	
	opr_operation_number_employee_key,
opr_operation_number_employee_text,
opr_op_dispatch_date,
opr_completion_date,
opr_operation_first_time_in_progress_time_key,
opr_operation_actual_end_time,

        row_number() over(partition by opr_op_dispatch_date, opr_operation_number_employee_text order by opr_operation_actual_end_time desc) as rn
		
FROM DBO.cbg_cdm_input_operations
where opr_op_dispatch_date is not null 
and opr_operation_number_work_centre_text like @job 
and opr_operation_number_work_centre_text like @region
and opr_op_dispatch_date between @startdate and  @enddate
) u	
where rn = 1) v
group by opr_operation_number_employee_key)
,
/*y*/ 
adjusted_work_time as (select 
pe_employee_key
, sum(case when pe_assessment_time is not null and pe_assessment_time > 0.75 then 0.75 else pe_assessment_time end) as AdjustedAssessmentTime
, sum(case when pe_travel_time is not null and pe_travel_time > 3 then 3 else pe_travel_time end) as AdjustedTravelTime
, sum(case when pe_actual_spanner_time is not null and pe_actual_spanner_time > 9 then 9 else pe_actual_spanner_time  end) as adjustedspannerTimeAct
from
(select * from [dbo].[people_table_work_time_data]
where pe_work_centre_zemploy_workcenter_key like @job 
	  and pe_work_centre_zemploy_workcenter_text like @region
	  and pe_calendar_day between @startdate and  @enddate
) x
group by pe_employee_key)
,
Data as (
	select
	 a.opr_operation_number_employee_key
	 ,a.opr_operation_number_work_centre_text
	,a.NST
	/*,a.opr_operation_number_work_centre_text*/
	,case when (e.core + e.overtime + e.bankedhours -  (e.business + e.personal) - e.CRP) > 0 then cast((b.COMP_Hours + b.UNCO_Hours) / (e.core + e.overtime + e.bankedhours -(e.business + e.personal) - e.CRP) as dec(5,2))  else 0 End as Jobs_per_Day
	,case when (e.core -  (e.business + e.personal ))/e.core > 1 then  '100%' else format((e.core -  (e.business + e.personal ))/e.core, 'P2') end as AvailabilityPercentNoCRP
	,case when (e.core + e.overtime + e.bankedhours -  (e.business + e.personal) - e.CRP) < 0 then 0 else (e.core + e.overtime + e.bankedhours -  (e.business + e.personal) - e.CRP) end as AvailableHoursIncBankOver
	/*,e.total_hours*/
	,format(h.SpannerEfficiency, 'P2') as Spanner_Efficiency
	,i.COMP
	,i.UNCO
	,i.ASTO
	,i.Aborts
	,n.avg_start_first_task
	,t.avg_end_first_task
	,q.avg_start_last_task
	,w.avg_end_last_task
	,cast((y.AdjustedTravelTime + y.AdjustedAssessmentTime + y.adjustedspannerTimeAct) as dec(5,2)) as productive_time
	,case when (y.AdjustedTravelTime + y.AdjustedAssessmentTime + y.adjustedspannerTimeAct) / (e.core + e.overtime + e.bankedhours -  (e.business + e.personal) - e.CRP) > 1 then '100%' else format((y.AdjustedTravelTime + y.AdjustedAssessmentTime + y.adjustedspannerTimeAct) / (e.core + e.overtime + e.bankedhours -  (e.business + e.personal) - e.CRP), 'P2') end as utilisation
	,e.Overtime
	,e.bankedhours
	,e.CRP
	,e.core
	,e.business
	,e.personal
	/*,k.avg_task_time_hours*/
	,a.Line_Manager_Name
	
	
from NST_TV a
	left join Complete_Jobs b on a.opr_operation_number_employee_key = b.opr_operation_number_employee_key
	left join absencetotal e on b.opr_operation_number_employee_key = e.pe_employee_key
	left join Spanner_time_adj h on e.pe_employee_key = h.pe_employee_key
	left join Uncomplete_jobs i on h.pe_employee_key = i.opr_operation_number_employee_key
	left join first_job_start n on  i.opr_operation_number_employee_key = n.opr_operation_number_employee_key
	left join last_job_start q on  n.opr_operation_number_employee_key = q.opr_operation_number_employee_key
	left join first_job_end t on  q.opr_operation_number_employee_key = t.opr_operation_number_employee_key
	left join last_job_End w on  t.opr_operation_number_employee_key = w.opr_operation_number_employee_key
	left join timings k on  w.opr_operation_number_employee_key = k.opr_operation_number_employee_key
	left join adjusted_work_time y on k.opr_operation_number_employee_key = y.pe_employee_key
	) 
	
Select * from Data 
	where opr_operation_number_employee_key is not null 
	and jobs_per_day > 0  
order by NST ASC
 

 	
