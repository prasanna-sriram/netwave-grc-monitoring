/*
===============================================================================
Check ID      : NWSM_001
Check Name    : Excessive Privileges vs Baseline
Control Area  : SOX ITGC / Access Management
Objective     : Identify users whose assigned role exceeds the least-privilege
                baseline defined for their job title and department.
Author        : NetWave Systems Portfolio Project
Notes         :
  - A finding is returned when:
      1) No baseline role exists for the user's job title + department, OR
      2) The assigned role is Privileged while the baseline role is Standard
         or Read_Only.
  - This query is intended to support periodic access reviews and audit
    evidence generation.
===============================================================================
*/

WITH privilege_check_cte
AS
(
	SELECT u.user_id, u.username, u.full_name, u.job_title, u.employment_status, 
	u.department_id, d.department_name, 
	ur.system_id, s.system_name, s.criticality,
	ur.role_id AS assigned_role_id, r_assigned.role_name AS assigned_role_name,	r_assigned.role_level AS assigned_role_level, 
	brp.allowed_role_id AS baseline_role_id, r_base.role_name AS baseline_role_name, r_base.role_level AS baseline_role_level,
	ur.assigned_at, ur.assigned_by
	FROM users u
	LEFT JOIN user_roles ur
	ON u.user_id = ur.user_id
	LEFT JOIN baseline_role_permissions brp
	ON u.job_title = brp.job_title AND
	u.department_id = brp.department_id
	LEFT JOIN roles r_assigned
	ON ur.role_id = r_assigned.role_id
	LEFT JOIN roles r_base
	ON brp.allowed_role_id = r_base.role_id
	LEFT JOIN departments d
	ON u.department_id = d.department_id
	LEFT JOIN systems s
	ON ur.system_id = s.system_id
), violations_cte AS (
	SELECT *,
	CASE
	WHEN baseline_role_level IS NULL THEN 'NO_BASELINE_ROLE_DEFINED'
	WHEN assigned_role_level = 'Privileged' AND baseline_role_level IN ('Standard', 'Read_Only') THEN 'ASSIGNED_ROLE_EXCEEDS_BASELINE'
	ELSE 'COMPLIANT' END AS compliance_status
	FROM privilege_check_cte
)


SELECT *
FROM violations_cte
WHERE compliance_status <> 'COMPLIANT'