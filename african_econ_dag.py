from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'chido',
    'depends_on_past': False,
    'email_on_failure': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='african_econ_intelligence_pipeline',
    default_args=default_args,
    description='World Bank API → BigQuery → dbt weekly pipeline',
    schedule_interval='@weekly',
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=['african-econ', 'bigquery', 'dbt'],
) as dag:

    start = BashOperator(
        task_id='pipeline_start',
        bash_command='echo "Starting African Econ Intelligence Pipeline $(date)"',
    )

    ingest_world_bank = BashOperator(
        task_id='ingest_world_bank_data',
        bash_command='echo "World Bank ingestion task — replace with Python operator in production"',
    )

    dbt_staging = BashOperator(
        task_id='dbt_run_staging',
        bash_command='echo "dbt run staging — replace with dbt operator in production"',
    )

    dbt_marts = BashOperator(
        task_id='dbt_run_marts',
        bash_command='echo "dbt run marts — replace with dbt operator in production"',
    )

    end = BashOperator(
        task_id='pipeline_complete',
        bash_command='echo "Pipeline complete $(date)"',
    )

    start >> ingest_world_bank >> dbt_staging >> dbt_marts >> end
