# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **dbt (Data Build Tool)** project for Adventure Works analytics, implementing a modern data warehouse architecture with medallion pattern (staging → intermediate → marts). The project transforms raw Adventure Works data from both data warehouse and API sources into clean, business-ready models.

## Architecture

### Layer Structure
- **Staging** (`models/staging/`): Raw data cleansing and standardization
  - `api_sales/`: API-sourced sales data
  - `products/`: Product master data with categories
  - `sales/`: Sales transactions, customers, territories
- **Intermediate** (`models/intermediate/`): Business logic and joins
  - `int_sales__enriched.sql`: Comprehensive sales fact with all dimensions
  - `int_products__hierarchy.sql`: Product category hierarchies
- **Marts** (`models/marts/`): Final business-ready models
  - `products/`: Product analytics
  - `sales/`: Sales analytics

### Data Sources
- **adventure_works_dw**: Main data warehouse tables (database: `ted_dev`, schema: `dev_diego_brito`)
- **adventure_works_api**: Recent/validation data from API

### Naming Conventions
- `stg_` = staging models
- `int_` = intermediate models  
- `fact_` = fact tables (marts)
- `dim_` = dimension tables (marts)

## Development Commands

### Core dbt Commands
```bash
# Run all models
dbt run

# Run specific model
dbt run --select stg_sales__customer

# Run models with dependencies
dbt run --select +int_sales__enriched

# Test all models
dbt test

# Test specific model
dbt test --select stg_sales__customer

# Generate documentation
dbt docs generate
dbt docs serve

# Check model dependencies
dbt deps

# Clean target directory
dbt clean
```

### Development Workflow
```bash
# Full development cycle
dbt clean && dbt deps && dbt run && dbt test

# Incremental development
dbt run --select +model_name && dbt test --select model_name
```

## Key Configuration

- **Profile**: `adventure_works_analytics`
- **Target schema**: Uses `+schema` config (staging, intermediate, marts)
- **Raw data variable**: `raw_schema: "ted_dev.dev_diego_brito"`
- **Materialization strategy**:
  - Staging: `view`
  - Intermediate: `view`
  - Marts: `table`

## Important Model Relationships

- `int_sales__enriched` is the core enriched sales fact joining all dimensions
- Product hierarchy models use self-referencing relationships for category trees
- All staging models reference sources defined in `models/sources/sources.yml`
- Customer classification distinguishes B2B vs B2C segments
- Territory models include performance metrics and regional groupings

## Environment Setup

The project uses a virtual environment with dbt installed at `/home/diego/adventure-works-analytics/venv/bin/dbt`.