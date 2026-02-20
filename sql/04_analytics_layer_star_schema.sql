-- =====================================================
-- FILE: 04_star_schema.sql
-- LAYER: ANALYTICS (STAR SCHEMA - SEQUENCE BASED)
-- PROJECT: SQL DATA CLEANING PIPELINE
-- AUTHOR: Jeeri Chaitanya
-- =====================================================

USE DATABASE SQL_DATA_CLEANING_DB;
USE SCHEMA ANALYTICS_LAYER;
USE WAREHOUSE SQL_WH;

-- =====================================================
-- STEP 1: CREATE SEQUENCES (FOR SURROGATE KEYS)
-- =====================================================

CREATE OR REPLACE SEQUENCE seq_customer_sk START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE seq_product_sk  START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE seq_region_sk   START = 1 INCREMENT = 1;
CREATE OR REPLACE SEQUENCE seq_sales_sk    START = 1 INCREMENT = 1;

-- =====================================================
-- STEP 2: CREATE DIM_CUSTOMER (SCD FUTURE-PROOF)
-- =====================================================

CREATE OR REPLACE TABLE dim_customer (
    customer_sk NUMBER PRIMARY KEY,
    customer_id VARCHAR(25),      -- Business Key
    customer_name VARCHAR(100),

    start_date DATE DEFAULT CURRENT_DATE(),
    end_date DATE DEFAULT TO_DATE('9999-12-31'),
    is_current BOOLEAN DEFAULT TRUE
);

-- Insert UNKNOWN customer first (Enterprise Best Practice)
INSERT INTO dim_customer (
    customer_sk,
    customer_id,
    customer_name
)
VALUES (
    seq_customer_sk.NEXTVAL,
    'Unknown',
    'Unknown Customer'
);

-- Load distinct customers from staging layer
INSERT INTO dim_customer (
    customer_sk,
    customer_id,
    customer_name
)
SELECT DISTINCT
    seq_customer_sk.NEXTVAL,
    customer_id,
    customer_name
FROM staging_layer.cleaned_deduplicated
WHERE customer_id IS NOT NULL;

-- =====================================================
-- STEP 3: CREATE DIM_PRODUCT
-- =====================================================

CREATE OR REPLACE TABLE dim_product (
    product_sk NUMBER PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

INSERT INTO dim_product (
    product_sk,
    product_name,
    category
)
SELECT DISTINCT
    seq_product_sk.NEXTVAL,
    product,
    category
FROM staging_layer.cleaned_deduplicated
WHERE product IS NOT NULL;

-- =====================================================
-- STEP 4: CREATE DIM_REGION
-- =====================================================

CREATE OR REPLACE TABLE dim_region (
    region_sk NUMBER PRIMARY KEY,
    region_name VARCHAR(50)
);

INSERT INTO dim_region (
    region_sk,
    region_name
)
SELECT DISTINCT
    seq_region_sk.NEXTVAL,
    region
FROM staging_layer.cleaned_deduplicated
WHERE region IS NOT NULL;

-- =====================================================
-- STEP 5: CREATE DIM_DATE (ANALYTICS OPTIMIZED)
-- =====================================================

CREATE OR REPLACE TABLE dim_date AS
SELECT DISTINCT
    order_date AS date_key,
    EXTRACT(YEAR FROM order_date)  AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(DAY FROM order_date)   AS day,
    TO_CHAR(order_date, 'MON')     AS month_name,
    DAYNAME(order_date)            AS day_name
FROM staging_layer.cleaned_deduplicated
WHERE order_date IS NOT NULL;

-- =====================================================
-- STEP 6: CREATE FACT TABLE (TRANSACTION GRAIN)
-- Grain: One row per order_id per product
-- =====================================================

CREATE OR REPLACE TABLE fact_sales_transaction (
    sales_sk NUMBER PRIMARY KEY,
    order_id NUMBER,
    date_key DATE,
    customer_sk NUMBER,
    product_sk NUMBER,
    region_sk NUMBER,
    quantity NUMBER(10,2),
    price NUMBER(10,2),
    discount NUMBER(5,2),
    total_amount NUMBER(12,2)
);

-- =====================================================
-- STEP 7: LOAD FACT TABLE USING SURROGATE KEYS
-- =====================================================

INSERT INTO fact_sales_transaction (
    sales_sk,
    order_id,
    date_key,
    customer_sk,
    product_sk,
    region_sk,
    quantity,
    price,
    discount,
    total_amount
)
SELECT
    seq_sales_sk.NEXTVAL AS sales_sk,
    c.order_id,
    c.order_date,
    dc.customer_sk,
    dp.product_sk,
    dr.region_sk,
    c.quantity,
    c.price,
    c.discount,
    c.total_amount

FROM staging_layer.cleaned_deduplicated c

LEFT JOIN dim_customer dc
    ON c.customer_id = dc.customer_id
    AND dc.is_current = TRUE

LEFT JOIN dim_product dp
    ON c.product = dp.product_name

LEFT JOIN dim_region dr
    ON c.region = dr.region_name;

-- =====================================================
-- STEP 8: FINAL VALIDATION CHECKS (DATA QUALITY)
-- =====================================================

-- Row count validation
SELECT COUNT(*) AS fact_row_count
FROM fact_sales_transaction;

-- Check for surrogate key mapping issues
SELECT *
FROM fact_sales_transaction
WHERE customer_sk IS NULL
   OR product_sk IS NULL
   OR region_sk IS NULL;

-- Dimension counts
SELECT COUNT(*) AS dim_customer_count FROM dim_customer;
SELECT COUNT(*) AS dim_product_count  FROM dim_product;
SELECT COUNT(*) AS dim_region_count   FROM dim_region;
SELECT COUNT(*) AS dim_date_count     FROM dim_date;
