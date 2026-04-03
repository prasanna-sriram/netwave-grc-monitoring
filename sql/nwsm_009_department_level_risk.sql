/*
===============================================================================
Check ID      : NWSM_009
Check Name    : Department-Level Access Risk Summary
Control Area  : Management Reporting / Access Risk
Objective     : Provide a per-department summary of key access risk indicators
                such as excessive privilege, dormant privileged accounts,
                terminated users with access, and privileged users without MFA.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Builds on prior checks using CTEs for:
      * Excessive privilege vs baseline
      * Dormant privileged accounts
      * Terminated users with roles
      * Privileged users without MFA
  - Aggregates counts by department_name to support dashboards and
    periodic management review.
===============================================================================
*/


WITH dept_check_cte
AS
(
	SELECT u.user_id, u.department_id, u.job_title, u.employment_status, u.last_login_at, u.mfa_enabled,
	r.role_level AS assigned_role_level,
	(
		SELECT role_level FROM roles WHERE role_id = brp.allowed_role_id
	) AS baseline_role_level,
	ur.system_id
	FROM users u
	LEFT JOIN user_roles ur
	ON u.user_id = ur.user_id
	LEFT JOIN roles r
	ON ur.role_id = r.role_id
	LEFT JOIN baseline_role_permissions brp
	ON u.job_title = brp.job_title AND
	u.department_id = brp.department_id
	LEFT JOIN systems s
	ON ur.system_id = s.system_id
), excessive_privilege_cte AS (
	SELECT *  
	FROM dept_check_cte
	WHERE (baseline_role_level IS NULL OR (assigned_role_level = 'Privileged' AND baseline_role_level IN ('Standard','Read_Only')))
), dormant_privilege_cte AS (
	SELECT *  
	FROM dept_check_cte
	WHERE (assigned_role_level = 'Privileged' AND employment_status = 'Active' AND DATEDIFF(DAY,last_login_at,GETDATE()) > 90)
), terminated_accnt_cte AS (
	SELECT *  
	FROM dept_check_cte
	WHERE employment_status = 'Terminated'
), mfa_coverage_cte AS (
	SELECT * 
	FROM dept_check_cte 
	WHERE assigned_role_level = 'Privileged' AND mfa_enabled = 0
)


SELECT d.department_name, COUNT(DISTINCT epc.user_id) AS excessive_priviliges_count,
COUNT(DISTINCT dpc.user_id) AS dormant_privileges_count, COUNT(DISTINCT tac.user_id) AS terminated_access_count,
COUNT(DISTINCT mcc.user_id) AS mfa_disabled_count, COUNT(DISTINCT dcc.user_id) AS total_users_by_dept
FROM departments d
LEFT JOIN dept_check_cte dcc
ON d.department_id = dcc.department_id
LEFT JOIN excessive_privilege_cte epc
ON d.department_id = epc.department_id
LEFT JOIN dormant_privilege_cte dpc
ON d.department_id = dpc.department_id
LEFT JOIN terminated_accnt_cte tac
ON d.department_id = tac.department_id
LEFT JOIN mfa_coverage_cte mcc
ON d.department_id = mcc.department_id
GROUP BY d.department_name