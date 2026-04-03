/*
===============================================================================
Check ID      : NWSM_003
Check Name    : Terminated Users With Active Access
Control Area  : SOX ITGC / User Provisioning & Deprovisioning
Objective     : Detect users whose employment_status is Terminated but who
                still have roles assigned on in-scope systems.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Any row returned represents a deprovisioning failure and a clear
    SOX ITGC violation.
  - Results can be used to drive immediate remediation and as evidence
    that this control is periodically monitored.
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
LEFT JOIN departments d
ON u.department_id = d.department_id
LEFT JOIN systems s
ON ur.system_id = s.system_id
WHERE u.employment_status = 'Terminated'