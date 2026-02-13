SELECT
p.categoryname,
ROUND(
    SUM(
        CASE
            WHEN s.orderdate >= '2023-01-01' AND s.orderdate < '2024-01-01' THEN (s.quantity * s.netprice * s.exchangerate)::numeric
            ELSE 0
        END
    ),
    2
) AS revenue_23,

ROUND(
    SUM(
        CASE
            WHEN s.orderdate >= '2022-01-01' AND s.orderdate < '2023-01-01' THEN (s.quantity * s.netprice * s.exchangerate)::numeric
            ELSE 0
        END
    ),
    2
) AS revenue_22

from product as p
    LEFT JOIN sales as s ON p.productkey = s.productkey

GROUP BY p.categoryname Desc

limit 10