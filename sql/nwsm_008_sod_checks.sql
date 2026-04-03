/*
===============================================================================
Check ID      : NWSM_008
Check Name    : SoD Conflicts: Privileged Users Executing High Risk Changes
Control Area  : Segregation of Duties / Change Management
Objective     : Detect users who both hold privileged roles on a system and
                perform high-risk configuration changes on that same system.
Author        : NetWave Systems Portfolio Project
Notes         :
  1. Focuses on change records joined to user_roles with role_level =
    'Privileged'.
  2. Can be further constrained to high risk change_type values such as
    FirewallRuleUpdate, AdminRoleAssignment, or VPNAccessPolicyChange.
  3. Intended to surface toxic combinations where one individual both
    controls configuration and holds admin access.
===============================================================================
*/

SELECT cc.change_id, cc.timestamp, cc.change_type, cc.change_summary,
cc.system_id, s.system_name, s.criticality,
cc.user_id, u.username, u.full_name, u.job_title, u.employment_status,
u.department_id, d.department_name,
ur.role_id, r.role_name, r.role_level
FROM config_changes cc
LEFT JOIN user_roles ur
ON cc.user_id = ur.user_id AND
cc.system_id = ur.system_id
LEFT JOIN users u
ON cc.user_id = u.user_id
LEFT JOIN roles r
ON ur.role_id = r.role_id
LEFT JOIN systems s
ON cc.system_id = s.system_id
LEFT JOIN departments d
ON u.department_id = d.department_id
WHERE r.role_level = 'Privileged'


