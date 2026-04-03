/*
===============================================================================
Check ID      : NWSM_002
Check Name    : Dormant Privileged Accounts
Control Area  : SOX ITGC / Access Management
Objective     : Identify users with privileged roles who have not logged in
                for more than 90 days but remain Active.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Focuses on roles marked as Privileged in the roles catalog.
  - Flags Active users whose last_login_at exceeds the dormancy threshold
    (e.g., 90 days) while still holding privileged access on any system.
  - Intended to support periodic reviews and deprovisioning of stale
    privileged accounts.
===============================================================================
*/

WITH privilege_check_cte AS
(
    SELECT u.user_id, u.username, u.full_name, u.job_title, u.employment_status, u.last_login_at,
    u.department_id, d.department_name,
    ur.system_id, s.system_name, s.criticality,
    r.role_id, r.role_name, r.role_level,
    ur.assigned_at, ur.assigned_by
    FROM users u
    LEFT JOIN user_roles ur
    ON u.user_id = ur.user_id
    LEFT JOIN roles r
    ON ur.role_id = r.role_id
    LEFT JOIN departments d
    ON u.department_id = d.department_id
    LEFT JOIN systems s
    ON ur.system_id = s.system_id
), violations_cte AS (
    SELECT *,
    CASE 
    WHEN role_level = 'Privileged' AND employment_status = 'Active' AND DATEDIFF(DAY,last_login_at, '2026-03-20') > 90 THEN 'DORMANT'
    WHEN role_level = 'Privileged' AND employment_status = 'Active' AND DATEDIFF(DAY,last_login_at, '2026-03-20') BETWEEN 30 AND 90 THEN 'AT_RISK'
    WHEN role_level = 'Privileged' AND employment_status = 'Active' AND DATEDIFF(DAY,last_login_at, '2026-03-20') < 30 THEN 'COMPLIANT'
    ELSE 'NOT_APPLICABLE'
    END AS compliance_status
    FROM privilege_check_cte
)

SELECT *
FROM violations_cte
WHERE compliance_status <> 'Not Applicable'
