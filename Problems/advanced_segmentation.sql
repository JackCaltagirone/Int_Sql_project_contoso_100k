-- Step 1: Compute the overall median revenue across ALL sales
-- for the years 2022 and 2023 combined.
-- This median will be used as the threshold to split low/high revenue.
WITH median_value AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY (quantity * netprice * exchangerate)
        ) AS median_revenue
    FROM sales
    WHERE orderdate >= '2022-01-01' 
      AND orderdate <  '2024-01-01'
)

-- Step 2: Calculate low/high revenue for each category in 2022 and 2023
SELECT
    p.categoryname AS category,

    ----------------------------------------------------------------------
    -- 2022 LOW REVENUE
    -- Sum of all revenue values BELOW the global median for 2022 only.
    ----------------------------------------------------------------------
    ROUND(
        SUM(
            CASE 
                WHEN (s.quantity * s.netprice * s.exchangerate) < mv.median_revenue
                 AND s.orderdate >= '2022-01-01'
                 AND s.orderdate <  '2023-01-01'
                THEN (s.quantity * s.netprice * s.exchangerate)::numeric
            END
        ),
        2
    ) AS low_revenue_2022,

    ----------------------------------------------------------------------
    -- 2022 HIGH REVENUE
    -- Sum of all revenue values ABOVE or EQUAL to the global median for 2022.
    ----------------------------------------------------------------------
    ROUND(
        SUM(
            CASE 
                WHEN (s.quantity * s.netprice * s.exchangerate) >= mv.median_revenue
                 AND s.orderdate >= '2022-01-01'
                 AND s.orderdate <  '2023-01-01'
                THEN (s.quantity * s.netprice * s.exchangerate)::numeric
            END
        ),
        2
    ) AS high_revenue_2022,

    ----------------------------------------------------------------------
    -- 2023 LOW REVENUE
    -- Same logic as 2022, but applied to 2023 date range.
    ----------------------------------------------------------------------
    ROUND(
        SUM(
            CASE 
                WHEN (s.quantity * s.netprice * s.exchangerate) < mv.median_revenue
                 AND s.orderdate >= '2023-01-01'
                 AND s.orderdate <  '2024-01-01'
                THEN (s.quantity * s.netprice * s.exchangerate)::numeric
            END
        ),
        2
    ) AS low_revenue_2023,

    ----------------------------------------------------------------------
    -- 2023 HIGH REVENUE
    -- Revenue values ABOVE or EQUAL to the global median for 2023.
    ----------------------------------------------------------------------
    ROUND(
        SUM(
            CASE 
                WHEN (s.quantity * s.netprice * s.exchangerate) >= mv.median_revenue
                 AND s.orderdate >= '2023-01-01'
                 AND s.orderdate <  '2024-01-01'
                THEN (s.quantity * s.netprice * s.exchangerate)::numeric
            END
        ),
        2
    ) AS high_revenue_2023

FROM sales AS s
LEFT JOIN product AS p 
    ON s.productkey = p.productkey

-- Bring in the median value (single-row CTE)
CROSS JOIN median_value AS mv

-- Aggregate results per category
GROUP BY category

-- Sort alphabetically for readability
ORDER BY category;