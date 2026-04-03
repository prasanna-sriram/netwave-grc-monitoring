/*
===============================================================================
Check ID      : NWSM_010
Check Name    : System-Level Access Risk Summary
Control Area  : Management Reporting / Access Risk
Objective     : Summarize access risk indicators by system, including counts
                of users with excessive privilege, dormant privileged accounts,
                terminated users with access, and privileged users without MFA.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Reuses the same risk CTE patterns as other checks but groups results
    by system_name.
  - Intended to help prioritize remediation on High-criticality systems
    with the greatest concentration of access issues.
===============================================================================
*/

WITH sys_check_cte
AS
(
	SELECT u.user_id, u.full_name, u.job_title, u.employment_status, u.last_login_at, u.mfa_enabled,
	u.department_id,
	ur.role_id, r.role_level AS assigned_role_level,
	(SELECT role_level FROM roles WHERE role_id = brp.allowed_role_id) AS baseline_role,
	ur.system_id
	FROM users u
	LEFT JOIN user_roles ur
	ON u.user_id = ur.user_id
	LEFT JOIN roles r
	ON ur.role_id = r.role_id
	LEFT JOIN baseline_role_permissions brp
	ON u.job_title = brp.job_title AND
	u.department_id = brp.department_id
), excessive_privileges_cte AS (
	SELECT *
	FROM sys_check_cte 
	WHERE baseline_role IS NULL OR (assigned_role_level = 'Privileged' AND baseline_role IN ('Standard', 'Read_Only'))
), dormant_acct_cte AS (
	SELECT *
	FROM sys_check_cte
	WHERE employment_status = 'Active' AND assigned_role_level= 'Privileged' AND DATEDIFF(DAY, last_login_at, GETDATE()) > 90
), terminated_accnt_cte AS (
	SELECT * 
	FROM sys_check_cte
	WHERE employment_status != 'Active'
), mfa_coverage_cte AS (
	SELECT * 
	FROM sys_check_cte 
	WHERE assigned_role_level = 'Privileged' AND mfa_enabled = 0
)

SELECT s.system_name, COUNT(DISTINCT epc.user_id) AS excessive_privileges_count,
COUNT(DISTINCT dac.user_id) AS dormant_acct_count, COUNT(DISTINCT tac.user_id) AS terminated_acct_count,
COUNT(DISTINCT mcc.user_id) AS mfa_disabled_count, COUNT(DISTINCT scc.user_id) AS total_system_users
FROM systems s
LEFT JOIN sys_check_cte scc
ON s.system_id = scc.system_id
LEFT JOIN excessive_privileges_cte epc
ON s.system_id = epc.system_id
LEFT JOIN dormant_acct_cte dac
ON s.system_id = dac.system_id
LEFT JOIN terminated_accnt_cte tac
ON s.system_id = tac.system_id
LEFT JOIN mfa_coverage_cte mcc
ON s.system_id = mcc.system_id
GROUP BY s.system_name