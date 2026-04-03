/*
===============================================================================
Check ID      : NWSM_007
Check Name    : Unapproved or Out-of-Policy Configuration Changes
Control Area  : Change Management / SOX ITGC
Objective     : Identify configuration changes executed without an approved
                workflow, executed before approval, or executed by users
                outside the owning department.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Flags changes where:
      * workflow_id IS NULL (no ticket), OR
      * workflow status is not 'Approved', OR
      * change timestamp is earlier than approval date, OR
      * the change was made by a department different from the system's
        owner_department.
  - Intended to demonstrate that changes to critical systems follow an
    approved change-management process.
===============================================================================
*/

WITH change_mgmt_cte
AS
(
	SELECT cc.change_id, cc.timestamp, cc.user_id, cc.system_id, s.system_name, s.criticality,
	(
		SELECT department_name FROM departments WHERE department_id = s.owner_department
	) AS system_owner_department,
	d.department_name AS user_department_name, cc.change_type, cc.change_summary, 
	cc.workflow_id, cw.workflow_source, cw.status, cw.created_at, cw.approved_at, cw.approved_by
	FROM config_changes cc
	LEFT JOIN users u
	ON cc.user_id = u.user_id
	LEFT JOIN departments d
	ON u.department_id = d.department_id
	LEFT JOIN systems s
	ON cc.system_id = s.system_id
	LEFT JOIN change_workflows cw
	ON cc.workflow_id = cw.workflow_id
), violations_check_cte AS (
	SELECT *,
	CASE
	WHEN workflow_id IS NULL THEN 'AD_HOC_CHANGE'
	WHEN status <> 'Approved' THEN 'UNAUTHORIZED_CHANGE'
	WHEN DATEFROMPARTS(YEAR(timestamp),MONTH(timestamp),DAY(timestamp)) < approved_at THEN 'PRE_AUTHORIZED_CHANGE'
	WHEN system_owner_department != user_department_name THEN 'EXTERNAL_CHANGE'
	ELSE 'APPROVED_CHANGE'
	END AS compliance_status
	FROM change_mgmt_cte
)

SELECT *
FROM violations_check_cte

