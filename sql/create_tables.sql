USE NetWave
GO

--CREATE TABLE departments
--(
--	department_id CHAR(4) PRIMARY KEY NOT NULL,
--	department_name VARCHAR(100) NOT NULL
--)

--CREATE TABLE systems
--(
--	system_id CHAR(5) PRIMARY KEY NOT NULL,
--	system_name VARCHAR(100) NOT NULL,
--	system_type VARCHAR(50) NOT NULL,
--	criticality VARCHAR(10) NOT NULL,
--	owner_department CHAR(4) NOT NULL,
--	CONSTRAINT FK_sys_dep FOREIGN KEY (owner_department) REFERENCES departments(department_id)
--);

--CREATE TABLE roles
--(
--	role_id CHAR(4) PRIMARY KEY NOT NULL,
--	role_name VARCHAR(50) NOT NULL,
--	role_level VARCHAR(20) NOT NULL,
--	CONSTRAINT CK_roles CHECK (role_level IN ('Privileged', 'Standard', 'Read_Only'))
--);

--CREATE TABLE permissions
--(
--	permission_id CHAR(4) PRIMARY KEY NOT NULL,
--	permission_name VARCHAR(100) NOT NULL,
--	permission_category VARCHAR(20) NOT NULL,
--	CONSTRAINT CK_permissions CHECK(permission_category IN ('READ', 'WRITE', 'ADMIN'))
--);

--CREATE TABLE role_permissions
--(
--	role_id CHAR(4) NOT NULL,
--	permission_id CHAR(4) NOT NULL,
--	CONSTRAINT PK_role_permissions PRIMARY KEY (role_id, permission_id),
--	CONSTRAINT FK_rp_rol FOREIGN KEY (role_id) REFERENCES roles(role_id),
--	CONSTRAINT FK_rp_per FOREIGN KEY (permission_id) REFERENCES permissions(permission_id),
--);

--CREATE TABLE users
--(
--	user_id CHAR(4) PRIMARY KEY NOT NULL,
--	username VARCHAR(50) NOT NULL,
--	full_name VARCHAR(150) NOT NULL,
--	department_id CHAR(4) NOT NULL,
--	job_title VARCHAR(100) NOT NULL,
--	employment_status VARCHAR(15) NOT NULL,
--	last_login_at DATE,
--	mfa_enabled BIT NOT NULL,
--	CONSTRAINT FK_usr_dep FOREIGN KEY (department_id) REFERENCES departments(department_id),
--	CONSTRAINT UQ_users UNIQUE(username),
--	CONSTRAINT CK_users CHECK (employment_status IN ('Active', 'Terminated', 'On_Leave'))
--);

--CREATE TABLE baseline_role_permissions
--(
--	baseline_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
--	job_title VARCHAR(100) NOT NULL,
--	department_id CHAR(4) NOT NULL,
--	allowed_role_id CHAR(4),
--	CONSTRAINT FK_brp_dep FOREIGN KEY (department_id) REFERENCES departments(department_id),
--	CONSTRAINT FK_brp_rol FOREIGN KEY (allowed_role_id) REFERENCES roles(role_id),
--	CONSTRAINT UQ_brp UNIQUE(job_title, department_id, allowed_role_id)
--);

--CREATE TABLE user_roles
--(
--	user_id CHAR(4) NOT NULL,
--	system_id CHAR(5) NOT NULL,
--	role_id CHAR(4) NOT NULL,
--	assigned_at DATE NOT NULL,
--	assigned_by VARCHAR(50) NOT NULL,
--	CONSTRAINT PK_ur PRIMARY KEY (user_id, system_id, role_id),
--	CONSTRAINT FK_ur_usr FOREIGN KEY (user_id) REFERENCES users(user_id),
--	CONSTRAINT FK_ur_sys FOREIGN KEY (system_id) REFERENCES systems(system_id),
--	CONSTRAINT FK_ur_rls FOREIGN KEY (role_id) REFERENCES roles(role_id)
--);

--CREATE TABLE change_workflows
--(
--	workflow_id CHAR(5) PRIMARY KEY NOT NULL,
--	workflow_source VARCHAR(50) NOT NULL,
--	status VARCHAR(20) NOT NULL,
--	created_at DATE NOT NULL,
--	approved_at DATE,
--	approved_by VARCHAR(50),
--	CONSTRAINT CK_cw CHECK (status IN ('Approved', 'Rejected', 'Draft'))
--);

--CREATE TABLE config_changes
--(
--	change_id CHAR(4) PRIMARY KEY NOT NULL,
--	timestamp DATETIME2 NOT NULL,
--	system_id CHAR(5) NOT NULL,
--	user_id CHAR(4) NOT NULL,
--	change_type VARCHAR(50) NOT NULL,
--	change_summary VARCHAR(255),
--	workflow_id CHAR(5),
--	CONSTRAINT FK_cc_sys FOREIGN KEY (system_id) REFERENCES systems(system_id),
--	CONSTRAINT FK_cc_usr FOREIGN KEY (user_id) REFERENCES users(user_id),
--	CONSTRAINT FK_cc_cw FOREIGN KEY (workflow_id) REFERENCES change_workflows(workflow_id)
--);

