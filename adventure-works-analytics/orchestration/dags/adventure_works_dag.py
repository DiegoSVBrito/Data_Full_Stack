"""
Adventure Works Analytics Pipeline DAG

This DAG orchestrates the complete Adventure Works analytics pipeline:
1. Data quality checks
2. Staging layer execution 
3. Intermediate layer execution
4. Marts layer execution
5. Testing and validation

Runs daily at 6:00 AM UTC
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.email import EmailOperator
from airflow.models import Variable
import logging

# DAG default arguments
default_args = {
    'owner': 'analytics-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email': ['admin@adventureworks.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
    'catchup': False,
}

# Create DAG instance
dag = DAG(
    'adventure_works_analytics_pipeline',
    default_args=default_args,
    description='Adventure Works Analytics Pipeline with dbt',
    schedule_interval='0 6 * * *',  # Daily at 6:00 AM UTC
    max_active_runs=1,
    tags=['adventure-works', 'analytics', 'dbt', 'data-warehouse'],
)

# Define dbt project directory
DBT_PROJECT_DIR = '/opt/airflow/dbt_project'

def log_pipeline_start():
    """Log pipeline start"""
    logging.info("Starting Adventure Works Analytics Pipeline")
    logging.info(f"Execution Date: {datetime.now()}")

def log_pipeline_end():
    """Log pipeline completion"""
    logging.info("Adventure Works Analytics Pipeline completed successfully")

# Task definitions
start_pipeline = PythonOperator(
    task_id='start_pipeline',
    python_callable=log_pipeline_start,
    dag=dag,
)

# Clean dbt environment
clean_dbt = BashOperator(
    task_id='clean_dbt_environment',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt clean',
    dag=dag,
)

# Install dbt dependencies
install_deps = BashOperator(
    task_id='install_dbt_dependencies',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt deps',
    dag=dag,
)

# Staging layer execution
run_staging_models = BashOperator(
    task_id='run_staging_models',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt run --select staging',
    dag=dag,
)

# Test staging models
test_staging_models = BashOperator(
    task_id='test_staging_models',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt test --select staging',
    dag=dag,
)

# Intermediate layer execution
run_intermediate_models = BashOperator(
    task_id='run_intermediate_models',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt run --select intermediate',
    dag=dag,
)

# Test intermediate models
test_intermediate_models = BashOperator(
    task_id='test_intermediate_models',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt test --select intermediate',
    dag=dag,
)

# Marts layer execution
run_marts_models = BashOperator(
    task_id='run_marts_models',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt run --select marts',
    dag=dag,
)

# Test marts models
test_marts_models = BashOperator(
    task_id='test_marts_models',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt test --select marts',
    dag=dag,
)

# Run all singular tests
run_singular_tests = BashOperator(
    task_id='run_singular_tests',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt test --select test_type:singular',
    dag=dag,
)

# Generate dbt documentation
generate_docs = BashOperator(
    task_id='generate_dbt_docs',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt docs generate',
    dag=dag,
)

# Final validation - run all tests
final_validation = BashOperator(
    task_id='final_validation',
    bash_command=f'cd {DBT_PROJECT_DIR} && dbt test',
    dag=dag,
)

# Log completion
end_pipeline = PythonOperator(
    task_id='end_pipeline',
    python_callable=log_pipeline_end,
    dag=dag,
)

# Success notification
success_notification = EmailOperator(
    task_id='success_notification',
    to=['admin@adventureworks.com'],
    subject='Adventure Works Pipeline - SUCCESS',
    html_content="""
    <h3>Adventure Works Analytics Pipeline Completed Successfully</h3>
    <p><strong>Execution Date:</strong> {{ ds }}</p>
    <p><strong>Tasks Completed:</strong></p>
    <ul>
        <li>Staging models executed and tested</li>
        <li>Intermediate models executed and tested</li>
        <li>Marts models executed and tested</li>
        <li>All data quality tests passed</li>
        <li>Documentation generated</li>
    </ul>
    <p>Data warehouse is ready for business consumption.</p>
    """,
    dag=dag,
)

# Define task dependencies
start_pipeline >> clean_dbt >> install_deps
install_deps >> run_staging_models >> test_staging_models
test_staging_models >> run_intermediate_models >> test_intermediate_models
test_intermediate_models >> run_marts_models >> test_marts_models
test_marts_models >> run_singular_tests >> generate_docs
generate_docs >> final_validation >> end_pipeline
end_pipeline >> success_notification