/*
===============================================================================
Check ID      : NWSM_011
Check Name    : Role-Level Access Risk Summary
Control Area  : Management Reporting / Role Governance
Objective     : Summarize access risk indicators by role, including counts
                of users with excessive privilege, dormant privileged accounts,
                terminated users with access, and privileged users without MFA.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Anchors on the roles catalog and left-joins each risk CTE so that
    every role is visible, even when it has no current findings.
  - Helps identify high-risk roles such as Global_SuperAdmin or other
    privileged roles that accumulate a disproportionate share of issues.
===============================================================================
*/


WITH roles_check_cte
AS
(
	SELECT u.user_id, u.department_id, u.job_title, u.employment_status, u.last_login_at, u.mfa_enabled,
	 r.role_id , r.role_level AS assigned_role_level,
	(
		SELECT role_level FROM roles WHERE role_id = brp.allowed_role_id
	) AS baseline_role_level
	FROM users u
	LEFT JOIN user_roles ur
	ON u.user_id = ur.user_id
	LEFT JOIN roles r
	ON ur.role_id = r.role_id
	LEFT JOIN baseline_role_permissions brp
	ON u.job_title = brp.job_title AND
	u.department_id = brp.department_id
), excessive_privilege_cte AS (
	SELECT *  
	FROM roles_check_cte
	WHERE (baseline_role_level IS NULL OR (assigned_role_level = 'Privileged' AND baseline_role_level IN ('Standard','Read_Only')))
), dormant_privilege_cte AS (
	SELECT *  
	FROM roles_check_cte
	WHERE (assigned_role_level = 'Privileged' AND employment_status = 'Active' AND DATEDIFF(DAY,last_login_at,GETDATE()) > 90)
), terminated_accnt_cte AS (
	SELECT *  
	FROM roles_check_cte
	WHERE employment_status = 'Terminated'
), mfa_coverage_cte AS (
	SELECT * 
	FROM roles_check_cte 
	WHERE assigned_role_level = 'Privileged' AND mfa_enabled = 0
)

SELECT r.role_name, r.role_level, COUNT(DISTINCT epc.user_id) AS excessive_priviliges_count,
COUNT(DISTINCT dpc.user_id) AS dormant_privileges_count, COUNT(DISTINCT tac.user_id) AS terminated_access_count,
COUNT(DISTINCT mcc.user_id) AS mfa_disabled_count, COUNT(DISTINCT rcc.user_id) AS total_users_by_role
FROM roles r
LEFT JOIN roles_check_cte rcc
ON r.role_id = rcc.role_id
LEFT JOIN excessive_privilege_cte epc
ON r.role_id = epc.role_id
LEFT JOIN dormant_privilege_cte dpc
ON r.role_id = dpc.role_id
LEFT JOIN terminated_accnt_cte tac
ON r.role_id = tac.role_id
LEFT JOIN mfa_coverage_cte mcc
ON r.role_id = mcc.role_id
GROUP BY r.role_name, r.role_level