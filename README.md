# SQL Data Cleaning & Data Modeling Project (Snowflake)

## Project Overview

This project demonstrates an end-to-end data pipeline in Snowflake, transforming messy raw retail sales data into a clean, validated, and analytics-ready dataset using a scalable Star Schema.

The solution follows a real-world enterprise data warehouse architecture:

RAW → STAGING → ANALYTICS

The pipeline includes:

- Data ingestion from Excel/CSV into Snowflake
- Data profiling (data quality assessment)
- Data cleaning & standardization
- Deduplication using business-key logic
- Dimensional modeling (Fact & Dimension tables with surrogate keys)
- SCD-ready dimension design
- Data quality & validation checks
- GitHub-based version control and documentation

---

## Objective

Transform messy raw retail sales data into a reliable and analysis-ready dataset while designing a future-proof dimensional model aligned with real-world data warehouse best practices.

The goal is not just cleaning data, but building a scalable analytics foundation similar to enterprise ETL pipelines.

---

## Tools & Technologies Used

- SQL (Snowflake SQL)
- Snowflake Cloud Data Warehouse
- GitHub (Version Control & Documentation)
- Excel / CSV (Raw Data Simulation)
- Dimensional Modeling (Star Schema)
- Data Quality Validation Techniques

---

## Data Warehouse Architecture (Layered Design)

This project uses a modern layered architecture similar to enterprise data platforms:

- RAW_LAYER → Stores raw, untouched source data (audit-friendly)
- STAGING_LAYER → Cleaned, standardized, and deduplicated data
- ANALYTICS_LAYER → Star schema (Fact & Dimension tables)

This separation ensures data auditability, scalability, and maintainability.

---

## Project Structure

sql-data-warehouse-pipeline/

├── data/
│   ├── messy_retail_data_3000_rows.xlsx   # Raw dataset
│   └── raw_data.csv                       # CSV for Snowflake ingestion
│
├── sql/
│   ├── 01_data_profiling.sql              # Raw data analysis
│   ├── 02_data_cleaning.sql               # Cleaning & standardization logic
│   ├── 03_deduplication.sql               # Duplicate removal logic
│   ├── 04_star_schema.sql                 # Dimension & Fact table creation
│   └── 05_data_quality_checks.sql         # Validation & integrity checks
│
└── README.md                              # Project Documentation

---

## Step 1: Data Profiling (RAW Layer)

Initial profiling was performed to identify real-world data quality issues before applying transformations.

Key issues identified:

- Multiple date formats and invalid dates
- NULL and blank customer_id and customer_name
- Inconsistent region values (north, NORTH, South, south)
- Negative quantity values
- Text values in discount column (e.g., 'abc')
- Missing price and total_amount values
- Duplicate records based on business key (order_id)

Profiling insights were used to design stakeholder-aligned cleaning rules instead of blindly deleting data.

---

## Step 2: Data Cleaning & Standardization (STAGING Layer)

Key transformations applied:

- Standardized date formats using TRY_TO_DATE + COALESCE
- Handled blank strings using NULLIF(TRIM(column), '')
- Replaced missing customer values with 'Unknown'
- Standardized region names using INITCAP()
- Converted negative quantities using ABS()
- Cleaned discount values using TRY_TO_NUMBER()
- Recalculated total_amount using business validation logic

Business formula used:

total_amount = quantity * price * (1 - discount)

This ensures analytical accuracy instead of trusting dirty source values.

---

## Step 3: Deduplication

Duplicates were removed using deterministic business-key logic:

- Business Key: order_id
- Technique: ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_date DESC)
- Rule: Keep the latest valid record per order
- Valid dates prioritized over NULL dates

This mirrors real-world ETL deduplication practices.

---

## Step 4: Data Modeling (ANALYTICS Layer – Star Schema)

After cleaning and deduplication, a scalable Star Schema was designed for analytics and BI reporting.

Fact Table:

- fact_sales
  - Grain: One row per order line item
  - Measures: quantity, price, discount, total_amount
  - Foreign Keys: customer_sk, product_sk, category_sk, date_key
  - Degenerate Dimension: order_id

Dimension Tables:

- dim_customer (SCD Type 2 Ready)
- dim_product (SCD Type 2 Ready)
- dim_category (SCD Type 2 Ready)
- dim_date (Static Calendar Dimension)

Surrogate keys were implemented using Snowflake SEQUENCE to:

- Support future Slowly Changing Dimensions (SCD)
- Improve join performance vs natural keys
- Handle NULL and “Unknown” members efficiently
- Decouple business keys from technical warehouse keys

Unknown dimension members (SK = 0) were created to prevent NULL foreign keys in the fact table.

---

## Step 5: Data Quality & Validation

A dedicated validation script ensures:

- Record count consistency across layers
- NULL checks on critical business fields
- Dimension load verification
- Foreign key integrity checks in fact table
- Revenue and measure consistency validation

This simulates real-world production data validation practices.

---

## Data Quality Summary

| Column        | Issues Observed               |
|---------------|-------------------------------|
| order_date    | NULL values & invalid formats |
| customer_id   | NULL and blank values         |
| customer_name | Missing values                |
| discount      | Text values + NULLs           |
| quantity      | Negative values               |
| total_amount  | Incorrect & missing values    |

---

## Key Learnings

- Real-world data is messy and incomplete
- Importance of stakeholder-driven cleaning decisions
- Advanced NULL handling using COALESCE, NULLIF, and TRY functions
- Enterprise deduplication using window functions
- Designing layered architecture (RAW → STAGING → ANALYTICS)
- Building Star Schema with surrogate keys
- Creating SCD-ready dimension tables for future-proofing
- Implementing data validation as a final pipeline step
- Thinking end-to-end like a data warehouse engineer

---

## Future Improvements

- Implement full SCD Type 2 change tracking logic
- Add incremental fact table loading (MERGE-based ETL)
- Build BI dashboard (Power BI / Tableau)
- Add automated SQL tests
- Orchestrate pipeline using dbt or Airflow

---

## Author

Jeeri Chaitanya  
Data Analyst | SQL | Snowflake | Data Modeling  
Focused on building end-to-end analytics pipelines and scalable data warehouse solutions.
