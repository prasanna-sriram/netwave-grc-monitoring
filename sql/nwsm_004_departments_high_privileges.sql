/*
===============================================================================
Check ID      : NWSM_004
Check Name    : Business Users With Privileged Access on Critical Systems
Control Area  : SOX ITGC / Access Management & Segregation of Duties
Objective     : Identify privileged roles on High-criticality systems that are
                assigned to users in non-IT / non-Security departments.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Treats roles with role_level = 'Privileged' as high-risk.
  - Filters to systems where criticality = 'High'.
  - Excludes Engineering, IT Operations, and Security to focus on business
    users (Finance, HR, Sales, etc.) holding elevated access.
===============================================================================
*/

SELECT u.user_id, u.username, u.full_name, u.job_title, u.employment_status, u.last_login_at,
u.department_id, d.department_name, 
ur.system_id, s.system_name, s.criticality, 
ur.role_id, r.role_name, r.role_level
FROM users u
LEFT JOIN user_roles ur
ON u.user_id = ur.user_id
LEFT JOIN roles r
ON ur.role_id = r.role_id
INNER JOIN systems s
ON ur.system_id = s.system_id
LEFT JOIN departments d
ON u.department_id = d.department_id
WHERE s.criticality = 'High' AND
d.department_name NOT IN ('Engineering', 'IT Operations', 'Security') AND
r.role_level = 'Privileged'

