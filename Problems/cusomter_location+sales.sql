-- Count daily customer activity and sales by continent
SELECT 
    s.orderdate,

    -- Unique customers from Europe
    COUNT(
        DISTINCT CASE 
            WHEN c.continent = 'Europe' THEN s.customerkey 
        END
    ) AS european_customers,

    -- Total sales from Europe (rounded to 2 decimals)
    ROUND(
        SUM(
            CASE 
                WHEN c.continent = 'Europe' 
                THEN (s.quantity * s.netprice * s.exchangerate)::numeric
                ELSE 0
            END
        ),
        2
    ) AS europe_sales,

    -- Unique customers from Australia
    COUNT(
        DISTINCT CASE 
            WHEN c.continent = 'Australia' THEN s.customerkey 
        END
    ) AS australian_customers,

    -- Total sales from Australia
    ROUND(
        SUM(
            CASE 
                WHEN c.continent = 'Australia' 
                THEN (s.quantity * s.netprice * s.exchangerate)::numeric
                ELSE 0
            END
        ),
        2
    ) AS australia_sales,

    -- Unique customers from North America
    COUNT(
        DISTINCT CASE 
            WHEN c.continent = 'North America' THEN s.customerkey 
        END
    ) AS north_american_customers,

    -- Total sales from North America
    ROUND(
        SUM(
            CASE 
                WHEN c.continent = 'North America' 
                THEN (s.quantity * s.netprice * s.exchangerate)::numeric
                ELSE 0
            END
        ),
        2
    ) AS north_america_sales

FROM 
    sales AS s

-- Join customer table to access continent information
LEFT JOIN 
    customer AS c 
    ON s.customerkey = c.customerkey

-- Filter for 2023 only
WHERE 
    s.orderdate >= '2023-01-01'
    AND s.orderdate < '2023-12-31'

-- Aggregate by day
GROUP BY 
    s.orderdate

-- Sort chronologically
ORDER BY 
    s.orderdate

LIMIT 
    10;

-- Used to verify continent values in the dataset
-- SELECT DISTINCT continent FROM customer LIMIT 10;