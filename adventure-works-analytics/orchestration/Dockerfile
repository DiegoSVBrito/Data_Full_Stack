FROM apache/airflow:2.7.1-python3.10

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y gcc python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER airflow

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create dbt project directory
RUN mkdir -p /opt/airflow/dbt_project

# Set environment variables
ENV DBT_PROJECT_DIR=/opt/airflow/dbt_project
ENV DBT_PROFILES_DIR=/opt/airflow/dbt_project