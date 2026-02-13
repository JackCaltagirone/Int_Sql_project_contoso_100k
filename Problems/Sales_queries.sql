-- Select key sales metrics along with customer and product details
SELECT 
    -- Date the order was placed
    s.orderdate,

    -- Calculate net revenue:
    -- quantity * netprice * exchangerate
    -- Cast to NUMERIC so ROUND(…, 2) works correctly
    ROUND((s.quantity * s.netprice * s.exchangerate)::numeric, 2) AS net_rev,

    -- Customer information
    c.givenname,
    c.surname,
    c.countryfull,
    c.continent,

    -- Product information
    p.productkey,
    p.productname,
    p.categoryname,
    p.subcategoryname,

    -- Categorise order size based on quantity
    CASE 
        WHEN s.quantity >= 100 THEN 'High Volume'
        WHEN s.quantity >= 50  THEN 'Medium Volume'
        ELSE 'Low Volume'
    END AS high_low

FROM sales AS s

-- Join customer table to enrich sales data
LEFT JOIN customer AS c 
    ON s.customerkey = c.customerkey

-- Join product table to include product attributes
LEFT JOIN product AS p 
    ON s.productkey = p.productkey

-- Filter for orders from 2020 onwards
WHERE s.orderdate >= '2020-01-01'

-- Limit output for preview/testing
LIMIT 10;