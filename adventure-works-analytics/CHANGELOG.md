# Changelog

All notable changes to this project will be documented in this file.


## [Unreleased]

## [2.0.0] - 2025-07-10

### 🎯 Major Release: Advanced Analytics Dimensions

#### ✨ Added
- **5 New Analytical Dimensions** for comprehensive business intelligence:
  - `dim_customers_enhanced` - Customer Lifetime Value analysis with VIP/Premium/Regular/Basic segmentation
  - `dim_products_performance` - Product lifecycle analysis (Growth/Maturity/Decline/Discontinued)
  - `dim_territories_performance` - Territory ROI analysis with efficiency rankings
  - `dim_channels_performance` - Sales channel performance (Online/Reseller) with value segments
  - `dim_product_associations` - Market basket analysis with lift, confidence, and support metrics

#### 🧪 Testing & Quality
- **45+ Automated Tests** covering all analytical dimensions
- **3 Custom Business Tests** for data quality validation:
  - `assert_positive_clv` - Validates positive customer lifetime values
  - `assert_valid_lifecycle_stages` - Ensures valid product lifecycle stages
  - `assert_valid_lift_values` - Validates market basket lift values
- **100% Test Coverage** on all new dimensions

#### 🏗️ Infrastructure
- **Complete GitHub Repository Structure** with GitFlow workflow
- **CI/CD Pipeline** with GitHub Actions:
  - Automated dbt testing on every PR
  - Multi-environment deployment (dev → staging → production)
  - Security scanning and code quality checks
  - Automated documentation generation
- **Comprehensive Documentation**:
  - Interactive dbt docs with data lineage
  - Contribution guidelines and development setup
  - Architecture documentation with business use cases

#### 🔧 Technical Improvements
- **Enhanced fact_sales_transactions** with `order_quantity` column
- **Databricks Integration** fully configured with proper error handling
- **Date Function Compatibility** for Spark SQL (ADD_MONTHS instead of DATE_SUB)
- **Column Name Standardization** across all models

#### 📊 Business Intelligence
- **Customer Analytics**: CLV segmentation, churn analysis, marketing targeting
- **Product Intelligence**: Lifecycle tracking, ABC analysis, demand forecasting
- **Sales Optimization**: Territory ROI, channel effectiveness, cross-selling opportunities
- **Operations Intelligence**: Real-time dashboards, data quality monitoring

### 🔄 Changed
- **Updated dbt_project.yml** with proper materialization strategies
- **Enhanced schema.yml** with comprehensive model and column documentation
- **Improved SQL performance** with optimized joins and aggregations
- **Standardized naming conventions** across all models

### 🐛 Fixed
- **Databricks Connection Issues** with proper warehouse configuration
- **Date Function Compatibility** for Spark SQL environment
- **Column Reference Errors** in analytical dimensions
- **Test Failures** related to data type mismatches

### 📚 Documentation
- **README.md** completely rewritten with professional structure
- **Contributing Guidelines** with detailed development workflow
- **Architecture Documentation** with Mermaid diagrams
- **API Documentation** for all models and dimensions

## [1.0.0] - 2025-07-07

### 🎯 Initial Release: Adventure Works Analytics Platform

#### ✨ Added
- **Complete dbt Project Structure** with medallion architecture:
  - **Bronze Layer (Staging)**: Raw data cleaning and standardization
  - **Silver Layer (Intermediate)**: Business logic and data enrichment
  - **Gold Layer (Marts)**: Analytics-ready facts and dimensions

#### 📊 Core Data Models
- **Fact Tables**:
  - `fact_sales_transactions` - Transaction-level sales data
  - `fact_sales_monthly_agg` - Monthly sales aggregations
  - `fact_territorial_performance` - Quarterly territorial performance

- **Core Dimensions**:
  - `dim_customer` - Customer master data with demographics
  - `dim_product` - Product catalog with categories and pricing
  - `dim_date` - Date dimension with fiscal periods

#### 🏗️ Infrastructure Setup
- **Airflow Orchestration** with Docker Compose setup
- **Databricks Integration** for cloud data warehouse
- **Delta Lake Storage** for reliable data management
- **Environment Configuration** for dev/staging/production

#### 📋 Data Sources
- **Adventure Works DW**: Main data warehouse tables
- **Adventure Works API**: Recent/validation data from API
- **Comprehensive Sources**: Sales, customers, products, territories

#### 🧪 Initial Testing
- **Schema Tests** for data quality validation
- **Business Logic Tests** for calculation accuracy
- **Data Freshness Tests** for pipeline monitoring

### 🔧 Technical Implementation
- **dbt 1.6.14** with Databricks adapter
- **Python 3.8+** virtual environment
- **Docker & Docker Compose** for containerized services
- **Git Version Control** with initial GitFlow setup

### 📚 Documentation
- **Basic README** with setup instructions
- **dbt Documentation** with model descriptions
- **Architecture Overview** with technology stack

---

## 🏷️ Version Tags

- **v2.0.0**: Advanced Analytics Dimensions Release
- **v1.0.0**: Initial Adventure Works Analytics Platform

## 🤝 Contributors

- **Diego Brito** - 

## 📈 Release Statistics

### v2.0.0 Metrics
- **5 new analytical dimensions** created
- **45+ automated tests** implemented
- **100% test success rate** achieved
- **~1 minute pipeline runtime** maintained
- **6 GitHub Action workflows** configured

### v1.0.0 Baseline
- **2 fact tables** established
- **3 core dimensions** created
- **15+ staging models** implemented
- **Airflow orchestration** configured
- **Databricks integration** completed

---
