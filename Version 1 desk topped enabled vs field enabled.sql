WITH Table1 AS (
    SELECT *
    FROM cbg_cdm_output_operations
    WHERE opr_standard_text_key_zcktsch_key = 'CENABLE'
)
SELECT
    *
FROM (
    SELECT
        a.tw_sql_id,
        a.whereabouts_item,
        a.dates,
        a.gang_name,
        a.created_age_days,
        a.work_no,
        a.op_no,
        a.permit,
        a.f_code,
        a.address,
        a.post_code,
        a.j_code,
        a.closing_j_code,
        a.tm_name,
        a.office_comments,
        a.closing_comments,
        a.backfill,
        a.current_status,
        a.status_reasons,
        a.osc,
        a.task_type,
        a.district,
        a.waiting_time,
        a.first_photo,
        a.last_photo,
        a.op_no_formatted,
        a.work_no_formatted,
        a.swims_data_file,
        CASE WHEN a.op_no_formatted = '10' THEN 'LeakDetection' ELSE 'NST' END AS Raised_by,
        CASE WHEN b.lead_order IS NOT NULL THEN 'Field Enabled' ELSE 'Desktop Enabled' END AS EnablingFlag,
        b.opr_operation_number_employee_text,
        c.employee_name AS enabler,
        c.position_name AS enabler_role
    FROM
        cbg_swims_data a
    LEFT JOIN
        Table1 b ON a.work_no_formatted = b.lead_order
    LEFT JOIN
        cbg_monthly_employee_list_BIT_update c ON b.opr_operation_number_employee_key = c.emp_no
    WHERE
        a.task_type = 'R&M'
        AND a.district = 'Thames Valley'
        AND a.current_status LIKE 'Visited%'
        AND a.dates > '2021-04-01'
) AS src
PIVOT (
    COUNT(tw_sql_id)
    FOR EnablingFlag IN ([Field Enabled], [Desktop Enabled])
) AS P