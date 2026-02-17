-- Remove duplicates
SELECT *
FROM raw_data
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY order_id
  ORDER BY updated_at DESC
) = 1;

-- Standardize country names
SELECT
  CASE
    WHEN country IN ('IND','IN') THEN 'India'
    ELSE country
  END AS country_cleaned
FROM raw_data;

-- Handle NULL values
SELECT
  COALESCE(customer_name, 'Unknown') AS customer_name
FROM raw_data;

