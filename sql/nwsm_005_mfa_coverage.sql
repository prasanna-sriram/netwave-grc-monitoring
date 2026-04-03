/*
===============================================================================
Check ID      : NWSM_005
Check Name    : Privileged Users Without MFA
Control Area  : Identity & Access Management / Strong Authentication
Objective     : Identify users with privileged roles who do not have MFA
                enabled on their accounts.
Author        : NetWave Systems Portfolio Project
Notes         :
  - Focuses on roles with role_level = 'Privileged'.
  - Flags accounts where mfa_enabled = 0.
  - Results can be aggregated to produce MFA coverage KPIs for
    privileged users.
===============================================================================
*/


WITH mfa_context_cte AS 
(
    SELECT u.user_id, u.username, u.full_name, u.job_title, u.employment_status, u.last_login_at, u.mfa_enabled, 
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
), mfa_check_cte AS (
    SELECT *,
    CASE
    WHEN role_level = 'Privileged' AND mfa_enabled = 0 THEN 'NON_COMPLIANT'
    WHEN role_level = 'Privileged' AND mfa_enabled = 1 THEN 'COMPLIANT'
    ELSE 'NOT_APPLICABLE' 
    END AS compliance_status
    FROM mfa_context_cte
)

SELECT *
FROM mfa_check_cte
WHERE compliance_status <> 'NOT_APPLICABLE'