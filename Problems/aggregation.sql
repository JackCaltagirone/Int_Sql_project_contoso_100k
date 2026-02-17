-- Outer SELECT:
-- Adds an extra calculated column (revenue_percentage)
-- based on the results of the inner query.
SELECT *,
    
    -- Percentage of daily revenue contributed by this order line.
    -- Uses the already‑rounded net_revenue and daily_net_revenue
    -- from the subquery to keep the math clean and readable.
    ROUND(100 * net_revenue / daily_net_revenue, 2) AS revenue_percentage

FROM (

    ----------------------------------------------------------------------
    -- Inner query:
    -- Computes per‑line revenue, daily total revenue, and each line’s
    -- percentage contribution to its day's revenue.
    ----------------------------------------------------------------------
    SELECT
        orderdate,

        -- Create a unique identifier for each order line
        orderkey * linenumber AS order_line_no,

        ------------------------------------------------------------------
        -- Net revenue per line (rounded to 2 decimals)
        -- Casting to NUMERIC ensures ROUND(x, 2) works in PostgreSQL.
        ------------------------------------------------------------------
        ROUND(
            (quantity * netprice * exchangerate)::numeric,
            2
        ) AS net_revenue,

        ------------------------------------------------------------------
        -- Daily total revenue (sum of all lines for that date)
        -- Window function: SUM() OVER (PARTITION BY orderdate)
        -- Rounded to 2 decimals.
        ------------------------------------------------------------------
        ROUND(
            (
                SUM(quantity * netprice * exchangerate)
                OVER (PARTITION BY orderdate)
            )::numeric,
            2
        ) AS daily_net_revenue,

        ------------------------------------------------------------------
        -- Percentage of daily revenue contributed by this line.
        -- Uses the raw values (not the rounded ones) for accuracy,
        -- then rounds the final percentage to 2 decimals.
        ------------------------------------------------------------------
        ROUND(
            (
                (quantity * netprice * exchangerate)::numeric * 100
                /
                (
                    SUM(quantity * netprice * exchangerate)
                    OVER (PARTITION BY orderdate)
                )::numeric
            ),
            2
        ) AS daily_revenue_percent

    FROM sales

) AS revenue_by_day

-- Sort by date, then by highest revenue contribution within each day
ORDER BY
    orderdate,
    daily_revenue_percent DESC

-- Only show the top 10 rows
