-- Step 1: Build a cohort table that assigns each customer
-- to the YEAR of their first-ever order.
-- This is the customer's "cohort year".
WITH yearly_cohort AS (
    SELECT DISTINCT
        customerkey,
        orderdate,

        -- Window function:
        -- For each customer, find the MIN(orderdate),
        -- then extract the YEAR of that first purchase.
        extract(
            YEAR FROM min(orderdate) OVER (PARTITION BY customerkey)
        ) AS cohort_year

    FROM sales
)

-- Step 2: Join each sale to the customer's cohort year
-- and aggregate revenue by:
--   - cohort_year (when the customer first appeared)
--   - order_year  (when the revenue actually occurred)
SELECT
    yc.cohort_year,

    -- Extract the year of the actual transaction
    extract(YEAR FROM s.orderdate) AS order_year,

    -- Total revenue for that cohort in that order year
    ROUND(
        SUM(s.quantity * s.netprice * s.exchangerate)::numeric,
        2
    ) AS total_revenue

FROM sales AS s

-- Attach each sale to the customer's cohort
LEFT JOIN yearly_cohort AS yc
    ON s.customerkey = yc.customerkey

-- Group by both the cohort year and the year of the sale
GROUP BY
    yc.cohort_year,
    extract(YEAR FROM s.orderdate)

-- Limit for preview
LIMIT 10;