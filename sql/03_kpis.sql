-- KPIs: revenue trend, growth, leakage and concentration.
-- Each query is introduced by a name marker line so the notebook can run and display it separately.

-- name: monthly_kpis
-- Gross sales, cancellations and order metrics by month.
WITH s AS (
    SELECT invoice_month,
           SUM(line_total)             AS gross_sales,
           COUNT(DISTINCT invoice)     AS invoices,
           COUNT(DISTINCT customer_id) AS customers
    FROM v_sales
    GROUP BY invoice_month
),
c AS (
    SELECT invoice_month, -SUM(line_total) AS cancelled
    FROM v_cancellations
    GROUP BY invoice_month
)
SELECT s.invoice_month,
       ROUND(s.gross_sales, 2)                                    AS gross_sales,
       ROUND(COALESCE(c.cancelled, 0), 2)                         AS cancelled,
       ROUND(COALESCE(c.cancelled, 0) / s.gross_sales, 4)         AS cancel_rate,
       s.invoices,
       s.customers,
       ROUND(s.gross_sales / s.invoices, 2)                       AS avg_order_value
FROM s
LEFT JOIN c USING (invoice_month)
ORDER BY s.invoice_month;

-- name: yoy_jan_nov
-- Like-for-like growth: Jan-Nov 2011 vs Jan-Nov 2010 (the data ends 9 Dec 2011).
WITH y AS (
    SELECT substr(invoice_date, 1, 4) AS year, SUM(line_total) AS gross_sales
    FROM v_sales
    WHERE CAST(substr(invoice_date, 6, 2) AS INTEGER) <= 11
      AND substr(invoice_date, 1, 4) IN ('2010', '2011')
    GROUP BY year
)
SELECT year,
       ROUND(gross_sales, 0) AS gross_sales,
       ROUND(gross_sales / LAG(gross_sales) OVER (ORDER BY year) - 1, 4) AS growth_vs_prior_year
FROM y
ORDER BY year;

-- name: leakage_summary
-- Where revenue leaks: cancellations and guest orders with no customer ID.
SELECT
    ROUND((SELECT SUM(line_total) FROM v_sales), 0)                              AS gross_sales,
    ROUND((SELECT -SUM(line_total) FROM v_cancellations), 0)                     AS cancelled_value,
    ROUND((SELECT -SUM(line_total) FROM v_cancellations)
        / (SELECT SUM(line_total) FROM v_sales), 4)                              AS cancel_rate,
    ROUND((SELECT SUM(line_total) FROM v_sales WHERE has_customer = 0)
        / (SELECT SUM(line_total) FROM v_sales), 4)                              AS guest_share_of_sales;

-- name: customer_concentration
-- Share of tracked sales earned by the top 1 / 5 / 10 / 20% of customers.
WITH cust AS (
    SELECT customer_id, SUM(line_total) AS sales
    FROM v_tracked_sales
    GROUP BY customer_id
),
ranked AS (
    SELECT sales,
           ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn,
           COUNT(*)     OVER ()                    AS n,
           SUM(sales)   OVER ()                    AS total
    FROM cust
),
cutoffs(label, pct) AS (
    VALUES ('top 1%', 0.01), ('top 5%', 0.05), ('top 10%', 0.10), ('top 20%', 0.20)
)
SELECT c.label,
       COUNT(*)                                  AS customers,
       ROUND(SUM(r.sales) / MAX(r.total), 4)     AS share_of_sales
FROM ranked r
JOIN cutoffs c ON r.rn <= CAST(r.n * c.pct AS INTEGER)
GROUP BY c.label, c.pct
ORDER BY c.pct;
