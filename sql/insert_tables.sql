USE NetWave
GO

--BULK INSERT departments
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\departments.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);


--SELECT * FROM departments;


--CREATE TABLE #staging_table
--(
--    system_id CHAR(5) PRIMARY KEY NOT NULL,
--	system_name VARCHAR(100) NOT NULL,
--	system_type VARCHAR(50) NOT NULL,
--	criticality VARCHAR(10) NOT NULL,
--	owner_department VARCHAR(100) NOT NULL
--);

--BULK INSERT #staging_table
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\systems.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);

--INSERT INTO systems
--SELECT st.system_id, st.system_name, st.system_type,
--st.criticality, d.department_id
--FROM #staging_table st
--INNER JOIN departments d
--ON st.owner_department = d.department_name

--DROP TABLE #staging_table

--SELECT * FROM systems;


--BULK INSERT roles
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\roles.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);


--SELECT * FROM roles;



--BULK INSERT permissions
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\permissions.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);


--SELECT * FROM permissions;



--BULK INSERT role_permissions
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\role_permissions.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);


--SELECT * FROM role_permissions;



--CREATE TABLE #staging_table
--(
--    user_id CHAR(4) PRIMARY KEY NOT NULL,
--	username VARCHAR(50) NOT NULL,
--	full_name VARCHAR(150) NOT NULL,
--	department_id CHAR(4) NOT NULL,
--	job_title VARCHAR(100) NOT NULL,
--	employment_status VARCHAR(15) NOT NULL,
--	last_login_at DATE,
--	mfa_enabled VARCHAR(10) NOT NULL,
--);

--BULK INSERT #staging_table
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\users.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);

--INSERT INTO users
--SELECT st.user_id, st.username, st.full_name,
--st.department_id, st.job_title, st.employment_status, st.last_login_at,
--CASE
--WHEN LOWER(TRIM(st.mfa_enabled)) = 'true' THEN 1
--WHEN LOWER(TRIM(st.mfa_enabled)) = 'false' THEN 0
--ELSE NULL
--END
--FROM #staging_table st

--DROP TABLE #staging_table

--SELECT * FROM users;



--CREATE TABLE #staging_table
--(
--	job_title VARCHAR(100) NOT NULL,
--	department_id CHAR(4) NOT NULL,
--	allowed_role_id CHAR(4)
--);

--BULK INSERT #staging_table
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\baseline_role_permissions.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);

--INSERT INTO baseline_role_permissions(job_title, department_id, allowed_role_id)
--SELECT st.job_title, st.department_id, st.allowed_role_id
--FROM #staging_table st

--DROP TABLE #staging_table

--SELECT * FROM baseline_role_permissions;



--BULK INSERT user_roles
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\user_roles.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);


--SELECT * FROM user_roles;



--BULK INSERT change_workflows
--FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\change_workflows.csv'
--WITH (
--    FORMAT = 'CSV',
--    FIELDTERMINATOR = ',',
--    ROWTERMINATOR = '\n',
--    FIRSTROW = 2
--);


--SELECT * FROM change_workflows;



BULK INSERT config_changes
FROM 'C:\Users\pras3\OneDrive\Source\portfolio-projects\network-compliance-monitor\data\config_changes.csv'
WITH (
    FORMAT = 'CSV',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);


SELECT * FROM config_changes;


