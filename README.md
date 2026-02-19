# SQL Data Cleaning & Data Modeling Project (Snowflake)

## Project Overview

This project demonstrates an end-to-end SQL data cleaning and data modeling workflow using messy retail sales data in Snowflake.

The pipeline includes:

* Data ingestion
* Data profiling
* Data cleaning & standardization
* Deduplication
* Star schema modeling (Fact & Dimension tables)

---

## Objective

Transform messy raw retail data into a clean, analysis-ready dataset and design a scalable data model suitable for BI and analytics.

---

## Tools & Technologies Used

* SQL (Snowflake SQL)
* Snowflake Cloud Data Warehouse
* GitHub (Version Control & Documentation)
* Excel (Raw Data Simulation)

---

## Project Structure

```
sql-data-cleaning/
│
├── data/
│   ├── messy_retail_data_3000_rows.xlsx   # Raw messy dataset
│   └── raw_data.csv                       # Converted CSV for Snowflake
│
├── sql/
│   └── data_cleaning_queries.sql          # Profiling, Cleaning, Deduplication, Modeling
│
└── README.md                              # Project Documentation
```

---

## 🔍 Step 1: Data Profiling

Performed initial analysis to identify data quality issues:

* Multiple date formats
* NULL customer IDs and names
* Inconsistent region values (north, NORTH, South)
* Negative quantities
* Text values in discount column (e.g., 'abc')
* Missing prices and total_amount
* Duplicate order records

## Data Cleaning Strategy (Business-Aligned)

After performing data profiling, key data quality issues were identified:
- NULL customer IDs and names
- Invalid discount values (text)
- Multiple date formats
- Negative quantities

Instead of deleting rows, stakeholder-aligned cleaning rules were applied:
- NULL/blank customer fields replaced with 'Unknown'
- Invalid discounts converted to NULL
- Negative quantities standardized using ABS()
- Dates standardized using TRY_TO_DATE()
- Duplicate records removed using ROW_NUMBER()

No raw records were deleted to preserve data completeness and auditability.

## Step 2: Data Cleaning & Standardization

Key transformations applied:

* Standardized date formats using TRY_TO_DATE + COALESCE
* Trimmed and handled blank strings using NULLIF + TRIM
* Replaced missing customer values with 'Unknown'
* Standardized region names using INITCAP()
* Converted negative quantities using ABS()
* Cleaned discount using TRY_CAST()
* Recalculated total_amount using business logic:

  ```
  total_amount = quantity * price * (1 - discount)
  ```

---

## 🧾 Step 3: Deduplication Logic

Duplicates were removed using enterprise-grade logic:

* Business Key: order_id
* Rule: Keep latest valid record per order
* Technique: ROW_NUMBER() with ORDER BY order_date DESC and NULL handling

---

## Step 4: Data Modeling (Star Schema)

Designed a scalable star schema for analytics:

### Fact Table:

* fact_sales (Transactional data)

### Dimension Tables:

* dim_customer (SCD Type 2 Ready with surrogate keys)
* dim_product
* dim_region
* dim_date

Why surrogate keys?

* Future-proof for Slowly Changing Dimensions (SCD)
* Better performance in joins
* Industry best practice

---

## 📊 Data Quality Observations

| Column       | Issues Found                 |
| ------------ | ---------------------------- |
| order_date   | NULL values, invalid formats |
| customer_id  | NULL & blank values          |
| discount     | Text + NULL values           |
| quantity     | Negative values              |
| total_amount | Incorrect & missing values   |

---

## 🧠 Key Learnings

* Real-world data is always messy and incomplete
* Importance of stakeholder decisions for NULL handling
* Using TRY_CAST and TRY_TO_DATE in Snowflake
* Enterprise deduplication using ROW_NUMBER()
* Designing star schema with surrogate keys
* End-to-end data pipeline thinking (not just cleaning)

---

## 🚀 Future Improvements

* Add automated data quality checks
* Implement SCD Type 2 for customer dimension
* Build Power BI / Looker dashboard on fact table
* Add data validation tests (SQL checks)

---

## 👤 Author

Jeeri Chaitanya
Data Analyst | SQL | Snowflake | Data Modeling

