/*
===============================================================================
Check ID      : NWSM_006
Check Name    : Actual vs Baseline Roles by Job Title
Control Area  : Role Design / Access Governance
Objective     : Compare the set of roles actually assigned to each job title
                against the least-privilege baseline defined for that
                job title and department.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Summarizes which roles are in use per job_title and which roles are
    defined as baseline for that job_title + department.
  - Intended to highlight role drift (roles in use that were not part of
    the original design) and support catalog reviews.
===============================================================================
*/

WITH assigned_role_cte
AS
(
	SELECT u.job_title, r.role_name, u.department_id, d.department_name
	FROM users u
	LEFT JOIN user_roles ur
	ON u.user_id = ur.user_id
	LEFT JOIN roles r
	ON ur.role_id = r.role_id
	LEFT JOIN departments d
	ON u.department_id = d.department_id
	GROUP BY u.job_title, r.role_name, u.department_id, d.department_name
), base_roles_cte AS (
	SELECT u.job_title, r.role_name AS base_roles, u.department_id, d.department_name
	FROM users u
	LEFT JOIN baseline_role_permissions brp
	ON u.job_title = brp.job_title AND
	u.department_id = brp.department_id
	LEFT JOIN roles r
	ON brp.allowed_role_id = r.role_id
	LEFT JOIN departments d
	ON u.department_id = d.department_id
	GROUP BY u.job_title, r.role_name, u.department_id, d.department_name
)

SELECT arc.job_title, arc.department_name,
arc.role_name, brc.base_roles,
CASE 
WHEN brc.base_roles IS NULL THEN 'NO_BASELINE_ROLE'
WHEN arc.role_name <> brc.base_roles THEN 'BASELINE_ROLE_MISMATCH'
ELSE 'BASELINE_ROLE_ALIGNED'
END AS alignment_status
FROM assigned_role_cte arc
LEFT JOIN base_roles_cte brc
ON arc.job_title = brc.job_title AND
arc.department_id = brc.department_id
