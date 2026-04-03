# Continuous IT GRC Monitoring for SaaS Network Platforms (SOX ITGC, Access Governance, Change Management, Analytics)

---

### Table of Contents

- [Executive Summary](#executive-summary)
- [Business Problem](#business-problem)
- [Methodology](#methodology)
- [Data](#data)
- [Skills](#skills)
- [Results and Business Recommendation](#results-and-business-recommendation)
- [Project Files](#project-files)
- [How To Run](#how-to-run)
- [Next Steps](#next-steps)
- [License](#license)
- [Author Info](#author-info)

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Executive Summary

This project simulates a SaaS, network‑heavy software company and builds an automated IT governance, risk and compliance (GRC) monitoring pipeline focused on SOX ITGC, access governance, and change‑management controls. Using a relational schema in SQL Server, parameterized SQL checks, and a production‑style Python evidence runner, it detects excessive privileges, dormant privileged accounts, terminated users with access, weak MFA coverage, and unapproved configuration changes on critical systems. The framework is designed to feed downstream Power BI dashboards for risk analytics and audit‑ready reporting; business next steps include operationalizing exception review workflows and expanding coverage to cloud and AI‑driven monitoring (to be detailed after dashboard work is complete).

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Business Problem

Modern SaaS and network‑heavy software companies rely on complex internal platforms where privileged access, misconfigured change processes, and stale accounts can directly impact financial reporting, availability, and customer trust. Traditional manual reviews of user access and change tickets are slow, error‑prone, and often fail to provide timely visibility to auditors and risk stakeholders. This project addresses the need for continuous, data‑driven monitoring of key SOX ITGC and access controls—so the business can quickly identify who has too much access, which privileged accounts are dormant, whether terminated users still have rights, and where configuration changes bypass formal approvals, all in a form that can be reused each audit cycle.

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Methodology

The project starts by designing a realistic relational schema for a fictional SaaS company (NetWave Systems) with multiple departments, critical network systems, roles, permissions, workflows, and change logs, then loading synthetic CSV datasets into SQL Server. On top of this, a set of targeted SQL checks are implemented to answer specific GRC questions (excessive privileges vs baseline, dormant privileged accounts, terminated users with access, change approvals, SoD conflicts), and a Python script using pyodbc and pandas automates running these checks, stamping them with audit metadata, and writing dated CSV evidence files for each control run. A run manifest summarizes rows returned, status, and output paths per check, setting up the data layer that will later be consumed by Power BI dashboards to present department, system, and role‑level risk views (to be added when dashboard work is completed).

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Data

This project uses synthetic, anonymized data that simulates a network‑heavy SaaS company called NetWave Systems. All records are fictional and designed to reproduce realistic access, role, and change‑management patterns (including intentional control failures) for SOX ITGC and GRC analytics.

**Source files (CSV, before loading into SQL Server):**
    - departments.csv – list of departments (Engineering, IT Operations, Security, Finance, Sales & Marketing, HR, Internal Audit).
    - systems.csv – critical systems and applications, including type (network_monitoring, firewall, config_repo, etc.), criticality, and owning department.
    - roles.csv – application roles with role levels (Privileged, Standard, Read_Only) used for access‑governance checks.
    - permissions.csv / role_permissions.csv – fine‑grained permissions and mappings of roles to permissions for least‑privilege modeling.
    - users.csv – 30 employees with department, job_title, employment_status, last_login_at, and MFA status.
    - baseline_role_permissions.csv – least‑privilege role baselines by job_title and department, used to detect excessive privilege.
    - user_roles.csv – actual role assignments per user per system, including intentional violations (e.g., Finance/HR/Sales users with admin roles, terminated users with access, dormant privileged accounts).
    - change_workflows.csv – change‑management tickets with status (Approved/Rejected/Draft) and dates.
    - config_changes.csv – configuration change events on systems, including user, change_type, workflow reference and several out‑of‑policy scenarios (no ticket, rejected workflow, wrong department).

These CSVs are first loaded into SQL Server (database NetWave) and then used as the source for all SQL checks and Python‑based evidence generation.

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Skills

- **SQL (MS SQL Server):**
    - Schema design for GRC use cases: users, departments, systems, roles, permissions, baselines, user_roles, change_workflows, config_changes.
    - Joins and filtering: multi‑table joins across users, roles, systems, workflows to detect SOX ITGC violations (excessive privilege, terminated users with access, non‑IT privileged access on critical systems).
    - CTEs and aggregation: CTE‑based patterns for building reusable contexts and department/system/role‑level summaries (counts of violations by dimension).
    - Conditional logic: CASE expressions and status flags to classify records as compliant vs non‑compliant for reporting.

- **Python:**
    - pyodbc for SQL Server connectivity, constructing ODBC connection strings, and managing DB sessions safely.
    - pandas for executing SQL into DataFrames, stamping audit metadata (check_id, run_date, run_timestamp), and writing outputs as CSV.
    - File and path management (pathlib) to organize SQL files, outputs, and manifests by check and run date.
    - Environment and configuration management (python-dotenv) to load DB credentials and validation logic that ensures required .env variables are present before execution.

- **GRC / SOX / Access Governance Concepts:**
    - SOX ITGC themes: least‑privilege baselines by job role, dormant privileged account detection, terminated user de‑provisioning, MFA coverage for admin accounts, and change‑management approvals.
    - Segregation of duties (SoD): identifying toxic combinations where a user both holds privileged access and performs high‑risk configuration changes on the same critical system.
    - Evidence automation: generating dated, check‑specific CSV outputs and consolidated manifests to serve as repeatable audit evidence.

- **(Planned) Power BI – to be implemented**
    - Importing control outputs (CSV) as fact tables for risk dashboards.
    - Building visuals for access risk by department, system, role, and run date; designing auditor‑friendly drill‑downs.
    - This section will be updated once the Power BI dashboards are built and wired to the Python outputs.

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Results and Business Recommendation

At this stage, the project delivers a working data and control‑execution layer rather than finalized analytics; it can already identify multiple classes of violations in a synthetic SaaS environment, such as excessive privileges versus baselines, dormant privileged accounts, terminated users retaining roles, privileged users without MFA, and configuration changes missing approved workflows or executed by non‑owner departments. Business stakeholders (e.g., Security, IT Operations, Internal Audit) can use this pattern to implement continuous access reviews, prioritize remediation on high‑criticality systems and high‑risk roles (like “Global_SuperAdmin”), and establish an auditable history of control operation for each monthly or quarterly run.

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Project Files

The project is organized to clearly separate data, SQL controls, automation scripts, and outputs to make it easy for reviewers and auditors to follow the flow from source data to evidence.

**Key components:**
    - data/ – raw synthetic CSV files used to seed the SQL Server NetWave database.
    - sql/ – one .sql file per control check, each with a documented header (check ID, name, objective, notes).
    - scripts/run_all_checks.py – Python evidence runner using pyodbc and pandas to execute each SQL file, add audit metadata, and save outputs to CSV along with a manifest per run.
    - outputs/ – dated evidence files per check (e.g., Q01/excessive_privileges_YYYY-MM-DD.csv) and aggregated run manifests under outputs/manifests/.
    - README.md – project overview, methodology, skills, and instructions.
    - requirements.txt – will list Python dependencies (pyodbc, pandas, python-dotenv, etc.) so the environment can be reproduced (to be finalized).

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## How to Run

**Prerequisites:**
    - SQL Server (local or remote) with rights to create a database and tables.
    - ODBC Driver 17 for SQL Server (or equivalent) installed on the machine running Python.
    - Python 3.9+ with the following packages installed:
        - pyodbc
        - pandas
        - python-dotenv

(Once requirements.txt is added, you will be able to run pip install -r requirements.txt instead of installing manually.)

1. Clone the repository
```bash
git clone https://github.com/prasanna-sriram/netwave-grc-monitoring.git
cd netwave-grc-monitoring
```

2. Set up the NetWave database and load CSV data
    - Create a new database in SQL Server called NetWave.
    - Create tables using the schema definitions described in the README (or in a future schema.sql file).
    - Use SQL Server Management Studio (SSMS) or bulk insert methods to load the CSV files from the data/ folder into their corresponding tables (departments, systems, roles, permissions, role_permissions, users, baseline_role_permissions, user_roles, change_workflows, config_changes).

Note: A complete schema.sql and/or loading script can be added later for full automation.

3. Configure environment variables (.env)
Create a .env file at the project root:

```text
DB_SERVER=localhost
DB_DATABASE=NetWave
DB_USER=your_sql_username
DB_PASSWORD=your_sql_password
```
The runner validates that these variables are set before attempting to connect.

4. Install Python dependencies
If requirements.txt is present:

```bash
pip install -r requirements.txt
```
Otherwise, install manually:

```bash
pip install pyodbc pandas python-dotenv
```

5. Run the evidence runner
From the project root:

```bash
python scripts/run_all_checks.py
```

The script will:
    - Read each .sql file in the sql/ directory.
    - Execute it against the NetWave database using pyodbc.
    - Load results into pandas, append check_id, run_date, and run_timestamp, and handle zero‑row results by still writing an evidence file.
    - Save outputs under outputs/<CHECK_ID>/...csv.
    - Write a run manifest under outputs/manifests/run_manifest_YYYY-MM-DD.csv summarizing status, row counts, and output paths for each check.

6. Review outputs
    - Open the CSV files in outputs/Qxx/ to see individual control findings.
    - Open the latest manifest in outputs/manifests/ to see a summary of which checks succeeded, how many rows they returned, and where the results were written.

These outputs will later be used as data sources for Power BI dashboards (to be documented when the BI layer is completed).

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Next Steps

- Build and document Power BI dashboards
    - Import the CSV evidence outputs and manifest files to create interactive dashboards for access risk, MFA coverage, change‑management violations, and SoD conflicts by department/system/role.
    - Add examples of how management and auditors could use these dashboards in periodic reviews and SOX walkthroughs; update README sections for Results and Methodology accordingly.
- Extend to cloud and modern GRC tooling
    - Adapt schemas and checks to include cloud resources (AWS/Azure/GCP IAM, logging, and configuration) and model how these SQL‑based checks could complement or feed into commercial GRC/TPRM platforms.
    - Add scenarios for continuous vendor monitoring and AI‑assisted risk scoring, reflecting how modern SaaS companies manage third‑party and cloud risk.
- Add more advanced analytics
    - Implement time‑series views of how violations change across runs, plus basic risk‑scoring for systems, roles, and departments using the existing SQL/Python outputs.
    - Explore simple risk quantification ideas (e.g., weighting violations by system criticality and role level) to prioritize remediation for the “top N” risky combinations.
- Operationalization and process integration
    - Design an example workflow for how findings from these checks would be triaged, assigned, and closed in an ITSM or ticketing tool (e.g., linking this project conceptually to Jira/ServiceNow).
    - Document how this pipeline could be scheduled (e.g., via a job scheduler or CI runner) and how evidence files and manifests would be archived for multi‑year audit support.

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## License

MIT License

Copyright (c) [2026] [Prasanna Sriram]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)

---

## Author Info

- Github - [Github Profile](https://github.com/prasanna-sriram)
- LinkedIn - [Prasanna Sriram](https://www.linkedin.com/in/prasanna-sriram/)
- Tableau - [Tableau Public Profile](https://public.tableau.com/app/profile/prasanna.sriram.ps)

[Back to the Top](#continuous-it-grc-monitoring-for-saas-network-platforms-sox-itgc-access-governance-change-management-analytics)