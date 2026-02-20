# SQL Data Cleaning & Data Modeling Project (Snowflake)

## Project Overview

This project demonstrates an end-to-end data pipeline in Snowflake, starting from messy raw retail data and transforming it into a clean, analytics-ready dataset with a scalable Star Schema.

The solution follows a real-world enterprise data warehouse architecture:
**RAW → STAGING → ANALYTICS**

The pipeline includes:

* Data ingestion from Excel/CSV into Snowflake
* Data profiling (data quality assessment)
* Data cleaning & standardization
* Deduplication using business keys
* Dimensional modeling (Fact & Dimension tables with surrogate keys)
* Documentation using GitHub for version control and project storytelling

---

## Objective

Transform messy raw retail sales data into a clean, reliable, and analysis-ready dataset while designing a future-proof dimensional model aligned with industry best practices used in real data warehouses.

---

## Tools & Technologies Used

* SQL (Snowflake SQL)
* Snowflake Cloud Data Warehouse
* GitHub (Version Control & Documentation)
* Excel (Messy Raw Data Simulation)
* Dimensional Modeling (Star Schema Design)

---

## Data Warehouse Architecture (Layered Design)

This project is designed using a modern layered architecture similar to real-world companies:

* **RAW_LAYER** → Stores raw untouched source data
* **STAGING_LAYER** → Cleaned, standardized, and deduplicated data
* **ANALYTICS_LAYER** → Star schema (Fact & Dimension tables)

This separation ensures data auditability, scalability, and maintainability.

---

## Project Structure

sql-data-cleaning/
│
├── data/
│   ├── messy_retail_data_3000_rows.xlsx   # Raw messy dataset (source)
│   └── raw_data.csv                       # Converted CSV for Snowflake loading
│
├── sql/
│   ├── 01_data_profiling.sql              # Data quality analysis
│   ├── 02_data_cleaning.sql               # Cleaning & standardization logic
│   ├── 03_deduplication.sql               # Duplicate removal logic
│   └── 04_star_schema.sql                 # Fact & Dimension table creation
│
└── README.md                              # Project Documentation

---

## Step 1: Data Profiling (RAW Layer)

Initial profiling was performed on the raw dataset to identify real-world data quality issues before applying any transformations.

### Key Issues Identified:

* Multiple date formats (DD-MM-YYYY, YYYY/MM/DD, invalid dates)
* NULL and blank customer_id and customer_name
* Inconsistent region values (north, NORTH, South, south)
* Negative quantity values
* Text values in discount column (e.g., 'abc')
* Missing price and total_amount values
* Potential duplicate records based on business key (order_id)

Instead of directly cleaning the data, profiling results were documented and treated as stakeholder input for business-aligned decisions.

---

## Stakeholder-Aligned Cleaning Strategy (Real-World Approach)

After profiling, cleaning rules were designed based on realistic stakeholder assumptions rather than blindly deleting data.

Business-aligned decisions taken:

* NULL/blank customer fields replaced with 'Unknown'
* Invalid discount values converted to NULL (not forced to 0)
* Negative quantities standardized using ABS()
* Multiple date formats standardized using TRY_TO_DATE()
* Duplicates handled using deterministic window logic
* No raw rows were deleted to preserve data completeness and auditability

This mirrors how real organizations handle messy production data.

---

## Step 2: Data Cleaning & Standardization (STAGING Layer)

Key transformations applied:

* Standardized date formats using TRY_TO_DATE + COALESCE
* Handled blank strings using NULLIF(TRIM(column), '')
* Replaced missing customer values with 'Unknown'
* Standardized region names using INITCAP()
* Converted negative quantities using ABS()
* Cleaned discount column using TRY_CAST()
* Recalculated total_amount using business logic validation

Business Formula Used:
total_amount = quantity * price * (1 - discount)

This ensures analytical accuracy instead of trusting dirty source values.

---

## Step 3: Deduplication (Enterprise-Grade Logic)

Duplicates were removed using a business-key driven approach.

* Business Key: order_id
* Rule: Keep the latest valid record per order
* Technique: ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_date DESC)

Additional logic ensures:

* Valid dates are prioritized over NULL dates
* Deterministic and audit-friendly record selection
* Consistency with real-world ETL pipelines

---

## Step 4: Data Modeling (ANALYTICS Layer – Star Schema)

After cleaning and deduplication, a scalable Star Schema was designed for analytics and BI reporting.

### Fact Table

* fact_sales_transaction
  (Grain: One row per order_id per product)

### Dimension Tables

* dim_customer (SCD Type 2 Ready)
* dim_product (SCD Type 2 Ready)
* dim_category (SCD Type 2 Ready)
* dim_date

### Surrogate keys were implemented in dimension tables using Snowflake SEQUENCE for the following reasons:

* Future-proof Slowly Changing Dimension (SCD) support
* Better join performance compared to natural keys
* Handles NULL and “Unknown” dimension members efficiently
* Industry best practice in data warehouse modeling
* Decouples business keys from technical keys

---

## Data Quality Summary

| Column        | Issues Observed               |
| ------------- | ----------------------------- |
| order_date    | NULL values & invalid formats |
| customer_id   | NULL and blank values         |
| customer_name | Missing values                |
| discount      | Text values + NULLs           |
| quantity      | Negative values               |
| total_amount  | Incorrect & missing values    |

---

## Key Learnings

* Real-world data is always messy and incomplete
* Importance of stakeholder-driven data cleaning decisions
* Advanced NULL handling using COALESCE, NULLIF, and TRY_CAST
* Enterprise deduplication using ROW_NUMBER()
* Snowflake-specific data transformation techniques
* Designing layered data architecture (RAW → STAGING → ANALYTICS)
* Building Star Schema with surrogate keys for scalability
* End-to-end data pipeline thinking instead of just “data cleaning”

---

## Future Improvements

* Implement full SCD Type 2 logic for dim_customer
* Add automated data quality validation checks
* Build Power BI / Tableau dashboard on fact table
* Add SQL unit tests for data validation
* Orchestrate pipeline using dbt or Airflow (future scope)

---

## Author

Jeeri Chaitanya
Data Analyst | SQL | Snowflake | Data Modeling
Focused on building end-to-end analytics pipelines and scalable data warehouse solutions.
