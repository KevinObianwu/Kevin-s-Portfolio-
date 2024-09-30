--select *
--from dbo.cbg_aborts_dashboard 

with T
as (
select (f_code),gang_name
from dbo.cbg_aborts_dashboard 
),

U as(select opr_operation_number_employee_key,opr_operation_number_employee_text,gang_name,f_code
from DBO.cbg_cdm_input_operations as CO

left JOIN T


ON CO.opr_operation_number_employee_text = T.gang_name


)
select *--opr_operation_number_employee_key
from T








--where A.aborts_indicator = 'Field Abort' 
