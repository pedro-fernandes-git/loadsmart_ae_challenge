# Loadsmart Analytics Engineer Challenge

This repository contains the solution I created for the Loadsmart Analytics Engineer Challenge 2025.

## Overview

This project implements a complete data pipeline that:
1. Ingests raw loads data from CSV loadsmart provided
2. Transforms and cleans data using Python
3. Builds a dimensional star schema using dbt
4. Exports analytics-ready datasets
5. Provides data visualization through Power BI


## Prerequisites

- **Docker Desktop** (for PostgreSQL database)
- **Python 3.9+**
- **Poetry 1.9** (for dependency management) - [Installation guide](https://python-poetry.org/docs/#installation)
- **Power BI Desktop** (optional, for viewing reports)

## Setup Instructions

### Step 1: Start the PostgreSQL Database

The project uses PostgreSQL running in Docker:

```bash
# Start the PostgreSQL container
docker-compose up -d

# Verify the container is running
docker ps
```

**Database Connection Details:**
- Host: `localhost`
- Port: `5432`
- Database: `loadsmart_challenge`
- User: `loadsmart_user`
- Password: `loadsmart_password`

### Step 2: Install Python Dependencies with Poetry

```bash
# Install all dependencies using Poetry
poetry install --no-root
# Poetry will automatically create and manage a virtual environment
```

**Using Poetry commands:**
- Run commands directly: `poetry run <command>`
- Or activate the Poetry shell: `poetry shell` (then run commands normally)

### Step 3: Clean and Ingest the Raw Data

Run the data cleaning notebook to process the raw CSV and load it into PostgreSQL:

```bash
# Navigate to the notebooks directory
cd notebooks

# Start Jupyter Notebook using Poetry
poetry run jupyter notebook
```

Open `clean-raw_loads.ipynb` and run all cells. This notebook will:
- Read the raw CSV file
- Split the `lane` column into pickup/delivery city/state
- Cast columns to appropriate data types
- Load data into PostgreSQL schema `analytics_cleaned`


### Step 4: Run dbt Models

Build the dimensional data model:

Open a new terminal because jupyter logs are running on the other terminal

```bash
# Navigate to the dbt project directory
cd loadsmart_dbt

# Run dbt models to create the dimensional schema
poetry run dbt run --profile loadsmart_dbt --target dev --profiles-dir .

# Run dbt tests to validate data quality
poetry run dbt test --profile loadsmart_dbt --target dev --profiles-dir .

# Generate and serve documentation
poetry run dbt docs generate
poetry run dbt docs serve
```

This will create the following tables in the `analytics` schema:
- `dim_carrier` - Carrier dimension
- `dim_shipper` - Shipper dimension
- `dim_date` - Calendar dimension
- `fact_loads` - Load fact table with metrics

**Test Coverage:**
-  Unique key constraints on all dimension tables
-  Not null constraints on critical fields
-  Referential integrity (foreign key relationships)
-  Date dimension completeness


### Step 5: Generate Export CSV and Send CSV via SFTP and email

**Requirements**
- Start SFTP server to be able to upload file:
```bash
# Start local SFTP test server
docker-compose -f docker-compose-sftp-test.yml up -d
```

-The email function uses environment variables for credentials. To test:
```powershell
# Windows PowerShell - set before starting Jupyter
$env:SMTP_SENDER="your-email@gmail.com"
$env:SMTP_RECIPIENT="recipient@example.com"
$env:SMTP_USERNAME="your-email@gmail.com"
$env:SMTP_PASSWORD="your-gmail-app-password"  # Get from: https://support.google.com/accounts/answer/185833
```

```bash
# macOS/Linux - set before starting Jupyter
export SMTP_SENDER="your-email@gmail.com"
export SMTP_RECIPIENT="recipient@example.com"  
export SMTP_USERNAME="your-email@gmail.com"
export SMTP_PASSWORD="your-gmail-app-password"
```


After setting the credentials, open and execute all cells from the notebook

```bash
# In the notebooks directory
poetry run jupyter notebook export.ipynb
```

- Generate CSV Export (Cells 1-4): 
Creates `exports/delivered_last_month.csv` with loads delivered in the most recent month

- Test SFTP Upload (Cell 5):
```bash
docker exec loadsmart-sftp-test ls -lh /home/testuser/upload/
```


### Step 6: Power BI Visualizations




