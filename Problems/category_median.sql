-- Calculate median revenue per category for 2022 and 2023
SELECT
    p.categoryname AS category,

    -- Median revenue for 2022
    ROUND(
        percentile_cont(0.5) WITHIN GROUP (
            ORDER BY 
                CASE 
                    WHEN s.orderdate >= '2022-01-01'
                     AND s.orderdate <  '2023-01-01'
                    THEN (s.quantity * s.netprice * s.exchangerate)
                END
        )::numeric,
        2
    ) AS median_revenue_2022,

    -- Median revenue for 2023
    ROUND(
        percentile_cont(0.5) WITHIN GROUP (
            ORDER BY 
                CASE 
                    WHEN s.orderdate >= '2023-01-01'
                     AND s.orderdate <  '2024-01-01'
                    THEN (s.quantity * s.netprice * s.exchangerate)
                END
        )::numeric,
        2
    ) AS median_revenue_2023

FROM product AS p
LEFT JOIN sales AS s 
    ON p.productkey = s.productkey

-- Group by category to aggregate medians per product category
GROUP BY category

-- Sort alphabetically (or swap to DESC on a median column if ranking)
ORDER BY category;