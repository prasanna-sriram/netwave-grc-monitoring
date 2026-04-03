from __future__ import annotations

import os
import datetime as dt
from pathlib import Path
from typing import Any, Dict, List, Optional

import pyodbc
import pandas as pd
from dotenv import load_dotenv


# -----------------------------------------------------------------------------
# Environment setup
# -----------------------------------------------------------------------------
# Loads variables from a local .env file when present.
# Example:
#   DB_SERVER=your_local_server
#   DB_DATABASE=NetWave
#   DB_USER=your_user
#   DB_PASSWORD=your_password
load_dotenv()


# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
DB_SERVER: str = os.getenv("DB_SERVER", "localhost")
DB_PORT: str = os.getenv("DB_PORT", "")
DB_DATABASE: str = os.getenv("DB_DATABASE", "NetWave")
DB_USER: str = os.getenv("DB_USER", "")
DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")


# SQL checks to run. Each dictionary identifies:
# - id: logical control/check ID
# - sql_file: SQL file stored in the sql/ directory
# - base_name: prefix used in the generated CSV output file
CHECKS: List[Dict[str, str]] = [
    { 'id': 'NWSM_001', 'sql_file': 'nwsm_001_excessive_privileges.sql', 'base_name': 'nwsm_001_excessive_privileges' },
    { 'id': 'NWSM_002', 'sql_file': 'nwsm_002_dormant_privileges.sql', 'base_name': 'nwsm_002_dormant_privileges' },
    { 'id': 'NWSM_003', 'sql_file': 'nwsm_003_terminated_users.sql', 'base_name': 'nwsm_003_terminated_users' },
    { 'id': 'NWSM_004', 'sql_file': 'nwsm_004_departments_high_privileges.sql', 'base_name': 'nwsm_004_non_it_departments_high_privileges' },
    { 'id': 'NWSM_005', 'sql_file': 'nwsm_005_mfa_coverage.sql', 'base_name': 'nwsm_005_mfa_coverage' },
    { 'id': 'NWSM_006', 'sql_file': 'nwsm_006_sox_access_control.sql', 'base_name': 'nwsm_006_sox_access_control' },
    { 'id': 'NWSM_007', 'sql_file': 'nwsm_007_unapproved_changes.sql', 'base_name': 'nwsm_007_unapproved_changes' },
    { 'id': 'NWSM_008', 'sql_file': 'nwsm_008_sod_checks.sql', 'base_name': 'nwsm_008_sod_checks' },
    { 'id': 'NWSM_009', 'sql_file': 'nwsm_009_department_level_risk.sql', 'base_name': 'nwsm_009_department_level_risk' },
    { 'id': 'NWSM_010', 'sql_file': 'nwsm_010_system_level_risk.sql', 'base_name': 'nwsm_010_system_level_risk' },
    { 'id': 'NWSM_011', 'sql_file': 'nwsm_011_roles_level_risk.sql', 'base_name': 'nwsm_011_roles_level_risk' }
]

BASE_DIR: Path = Path(__file__).resolve().parent.parent
SQL_DIR: Path = BASE_DIR / 'sql'
OUTPUT_DIR: Path = BASE_DIR / 'outputs'


def validate_env_variables(required_vars: List[str]) -> None:
    """
    Validate that required environment variables are present and non-empty.

    Args:
        required_vars (List[str]):
            List of required environment variable names.

    Returns:
        None

    Raises:
        ValueError:
            If one or more required variables are missing or empty.
    """
    missing_vars = [var for var in required_vars if not os.getenv(var)]

    if missing_vars:
        missing_list = ",".join(missing_vars)
        raise ValueError(f"Missing required environment variables: {missing_list}. Please update your .env file before running the script.")
    pass


def build_connection_string(
        server: str,
        database:  str,
        user: str,
        password: str,
        driver: str = 'ODBC Driver 17 for SQL Server',
        port: str = '1433',
        encrypt: str = 'no'

)-> str:
    """
    Build a SQL Server ODBC connection string.

    Args:
        server (str):
            SQL Server hostname or instance name.
        database (str):
            Target database name.
        user (str):
            SQL Server login username.
        password (str):
            SQL Server login password.
        driver (str, optional):
            Installed ODBC driver name. Defaults to
            'ODBC Driver 17 for SQL Server'.
        port (str, optional):
            Port Number for SQL Connection. Defaults to
            1433
        encrypt (str, optional):
            Whether to enable encryption in the connection string.
            Common values: 'yes' or 'no'. Defaults to 'no'.

    Returns:
        str:
            A formatted pyodbc connection string.

    Output Type:
        str
    """
    return (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"PORT={port};"
        f"DATABASE={database};"
        f"UID={user};"
        f"PWD={password};"
        f"Encrypt={encrypt};"
        "Trusted_Connection=no;"
        "TrustServerCertificate=yes;"
    )


def get_db_connection(connection_string: str) -> pyodbc.Connection:
    """
    Create and return a live pyodbc database connection.

    Args:
        connection_string (str):
            A valid SQL Server ODBC connection string.

    Returns:
        pyodbc.Connection:
            An open database connection object.

    Raises:
        pyodbc.Error:
            If the connection cannot be established.

    Output Type:
        pyodbc.Connection
    """
    return pyodbc.connect(connection_string)


def load_sql_file(sql_path: Path) -> str:
    """
    Read SQL text from a .sql file.

    Args:
        sql_path (Path):
            Absolute or relative path to the SQL file.

    Returns:
        str:
            SQL query text as a string.

    Raises:
        FileNotFoundError:
            If the SQL file does not exist.

    Output Type:
        str
    """
    if not sql_path.exists():
        raise FileNotFoundError(f"SQL file not found: {sql_path}")
    
    return sql_path.read_text(encoding='utf-8')


def execute_sql_to_dataframe(
        connection: pyodbc.Connection,
        sql_text: str
) -> pd.DataFrame:
    """
    Execute a SQL query and return the result as a pandas DataFrame.

    Args:
        connection (pyodbc.Connection):
            An open SQL Server connection.
        sql_text (str):
            SQL query text to execute.

    Returns:
        pd.DataFrame:
            Result set returned by the SQL query. If the query returns
            no rows, an empty DataFrame is returned.

    Raises:
        Exception:
            Propagates database or SQL execution errors.

    Output Type:
        pandas.DataFrame
    """
    return pd.read_sql(sql_text, connection)


def append_audit_metadata(
        df: pd.DataFrame,
        check_id: str,
        run_date: Optional[str] = None,
        run_timestamp: Optional[str] = None
) -> pd.DataFrame:
    """
    Append audit metadata columns to a DataFrame.

    This supports traceability by stamping every output file with
    the logical check identifier and execution time.

    Args:
        df (pd.DataFrame):
            Query result data.
        check_id (str):
            Control/check identifier such as 'Q01'.
        run_date (Optional[str], optional):
            Execution date in YYYY-MM-DD format. If None, today's date is used.
        run_timestamp (Optional[str], optional):
            Execution timestamp in YYYY-MM-DD HH:MM:SS format.
            If None, current timestamp is used.

    Returns:
        pd.DataFrame:
            A new DataFrame with additional columns:
            - check_id (str)
            - run_date (str)
            - run_timestamp (str)

    Output Type:
        pandas.DataFrame
    """
    now = dt.datetime.now()

    final_run_date = run_date or now.strftime("%Y-%m-%d")
    final_run_timestamp = run_timestamp or now.strftime("%Y-%m-%d %H:%M:%S")

    df = df.copy()
    df['check_id'] = check_id
    df['run_date'] = final_run_date
    df["run_timestamp"] = final_run_timestamp
    return df


def build_output_path(
        output_root: Path,
        check_id: str,
        base_name: str,
        run_date: str
) -> Path:
    """
    Build the output CSV path for a given check and ensure its folder exists.

    Args:
        output_root (Path):
            Root output directory.
        check_id (str):
            Logical check identifier such as 'Q01'.
        base_name (str):
            Base output file name such as 'excessive_privileges'.
        run_date (str):
            Execution date in YYYY-MM-DD format.

    Returns:
        Path:
            Full path to the CSV output file.

    Output Type:
        pathlib.Path
    """
    check_dir = output_root / check_id
    check_dir.mkdir(parents=True, exist_ok=True)
    return check_dir / f"{base_name}_{run_date}.csv"


def save_dataframe_to_csv(df:pd.DataFrame, output_path: Path) -> None:
    """
    Save a DataFrame to CSV format.

    Args:
        df (pd.DataFrame):
            DataFrame to persist.
        output_path (Path):
            Full target file path.

    Returns:
        None

    Output Type:
        None
    """
    df.to_csv(output_path, index=False)
    pass


def write_run_manifest(
        manifest_records: List[Dict[str, Any]],
        output_dir: Path,
        run_date: str
) -> Path:
    """
    Write a manifest file summarizing the outcome of all executed checks.

    Args:
        manifest_records (List[Dict[str, Any]]):
            List of manifest rows, one per check.
        output_dir (Path):
            Root output directory.
        run_date (str):
            Execution date in YYYY-MM-DD format.

    Returns:
        Path:
            Full path to the generated manifest CSV file.
    """
    manifest_dir = output_dir / 'manifests'
    manifest_dir.mkdir(parents=True,exist_ok=True)

    manifest_df = pd.DataFrame(manifest_records)
    manifest_path = manifest_dir / f"run_manifest_{run_date}.csv"
    manifest_df.to_csv(manifest_path, index=False)

    return manifest_path


def run_check(
        connection: pyodbc.Connection,
        sql_dir: Path,
        output_dir: Path,
        check: Dict[str, str]
) -> Dict[str, Any]:
    """
    Run a single SQL control check and return a manifest record.

    Workflow:
        1. Read SQL from disk.
        2. Execute SQL against SQL Server.
        3. Append audit metadata columns.
        4. Save the results to CSV. If the query returns zero rows, a CSV file is still generated as
        evidence that the control was executed and no exceptions were found.

    Args:
        connection (pyodbc.Connection):
            Open SQL Server connection.
        sql_dir (Path):
            Directory containing .sql files.
        output_dir (Path):
            Root directory where output CSVs will be saved.
        check (Dict[str, str]):
            Check metadata dictionary containing:
            - id
            - sql_file
            - base_name

    Returns:
        Dict[str, Any]:
            Returns a manifest record.

    Raises:
        FileNotFoundError:
            If the SQL file does not exist.
        Exception:
            If query execution or file writing fails.

    Output Type:
        Dict[str, Any]
    """
    run_timestamp = dt.datetime.now().strftime("%Y-%m-%d %H:%M:&S")
    run_date = dt.date.today().strftime("%Y-%m-%d")

    try:
        sql_path = sql_dir / check['sql_file']
        sql_text = load_sql_file(sql_path)

        print(f"[INFO] Running check: {check['id']} using {sql_path.name}...")
        df = execute_sql_to_dataframe(connection, sql_text)

        row_count = len(df)

        if row_count == 0:
            # Create an evidence row even when no findings exist
            df = pd.DataFrame([
                { "evidence_status": "No exceptions found" }
            ])
        
        df = append_audit_metadata(df=df,check_id=check['id'], run_date=run_date, run_timestamp=run_timestamp)

        output_path = build_output_path(
            output_root=output_dir,
            check_id=check['id'],
            base_name=check['base_name'],
            run_date=run_date
        )

        save_dataframe_to_csv(df,output_path)

        print(f"[INFO] {check['id']} completed. Rows written: {len(df)}")
        print(f"[INFO] Output file: {output_path}")

        return {
            "check_id": check["id"],
            "sql_file": check["sql_file"],
            "base_name": check["base_name"],
            "status": "SUCCESS",
            "row_count": row_count,
            "output_path": str(output_path),
            "run_date": run_date,
            "run_timestamp": run_timestamp,
            "error_message": ""
        }
    except Exception as ex:
        print(f"[ERROR] {check['id']} failed: {ex}")

        return {
            "check_id": check["id"],
            "sql_file": check["sql_file"],
            "base_name": check["base_name"],
            "status": "FAILED",
            "row_count": None,
            "output_path": "",
            "run_date": run_date,
            "run_timestamp": run_timestamp,
            "error_message": str(ex)
        }


def run_all_checks(
        connection: pyodbc.Connection,
        sql_dir: Path,
        output_dir: Path,
        checks: List[Dict[str,str]]
) -> List[Dict[str, Any]]:
    """
    Run all configured SQL checks and return manifest records.

    Args:
        connection (pyodbc.Connection):
            Open SQL Server connection.
        sql_dir (Path):
            Directory containing .sql files.
        output_dir (Path):
            Root output directory.
        checks (List[Dict[str, str]]):
            List of configured check dictionaries.

    Returns:
        List[Dict[str, Any]]:
            List of all the manifest records.

    Notes:
        - Each check is executed independently.
        - A failure in one check does not stop the others.
        - Errors are printed to the console for troubleshooting.

    Output Type:
        List[Dict[str, Any]]
    """
    manifest_records: List[Dict[str, Any]] = []

    for check in checks:
        manifest_record = run_check(
            connection=connection,
            sql_dir=sql_dir,
            output_dir=output_dir,
            check= check
        )

        manifest_records.append(manifest_record)
        pass

    return manifest_records


def main() -> None:
    """
    Main application entry point.

    Responsibilities:
        - Create the SQL Server connection string.
        - Establish a database connection.
        - Execute all configured SQL checks.
        - Write dated CSV evidence files to the outputs directory.

    Args:
        None

    Returns:
        None

    Output Type:
        None
    """
    OUTPUT_DIR.mkdir(parents=True,exist_ok=True)

    validate_env_variables(
        required_vars=['DB_SERVER', 'DB_DATABASE', 'DB_USER', 'DB_PASSWORD']
    )

    connection_string = build_connection_string(
        server=DB_SERVER,
        database=DB_DATABASE,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD
    )

    run_date = dt.date.today().strftime("%Y-%m-%d")

    with get_db_connection(connection_string) as connection:
        manifest_records = run_all_checks(
            connection=connection,
            sql_dir=SQL_DIR,
            output_dir=OUTPUT_DIR,
            checks=CHECKS
        )
        pass

    manifest_path = write_run_manifest(
        manifest_records=manifest_records,
        output_dir=OUTPUT_DIR,
        run_date=run_date
    )
        
    print(f"[INFO] Run Complete. Checks executed: {len(manifest_records)}")
    print(f"[INFO] Manifest written to: {manifest_path}")


if __name__ == "__main__":
    main()