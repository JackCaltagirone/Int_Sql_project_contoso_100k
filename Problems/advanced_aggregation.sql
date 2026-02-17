-- Step 1: Build a cohort table that assigns each customer
-- to the YEAR of their first-ever purchase (cohort_year),
-- and also records the YEAR of each purchase they made (purchase_year).
WITH yearly_cohort AS (
    SELECT DISTINCT
        customerkey,

        ------------------------------------------------------------------
        -- COHORT YEAR:
        -- For each customer, find the MIN(orderdate) across all their orders.
        -- This is their first purchase date.
        -- Then extract the YEAR from that date.
        ------------------------------------------------------------------
        EXTRACT(
            YEAR FROM MIN(orderdate) OVER (PARTITION BY customerkey)
        ) AS cohort_year,

        ------------------------------------------------------------------
        -- PURCHASE YEAR:
        -- The year of this specific transaction.
        -- A customer may appear in multiple purchase years.
        ------------------------------------------------------------------
        EXTRACT(
            YEAR FROM orderdate
        ) AS purchase_year
    FROM sales
)

-- Step 2: Count how many customers from each cohort
-- made purchases in each purchase year.
SELECT DISTINCT
    cohort_year,
    purchase_year,

    ----------------------------------------------------------------------
    -- Count customers per (cohort_year, purchase_year) pair.
    -- Window function counts DISTINCT customerkeys within