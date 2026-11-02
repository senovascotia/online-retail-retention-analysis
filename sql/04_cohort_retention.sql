-- Cohort retention: customers grouped by the month of their first purchase.
-- December 2011 is a partial month and is excluded.

-- name: cohort_retention
-- % of each cohort that placed an order k months after their first purchase.
WITH activity AS (
    SELECT DISTINCT customer_id, first_purchase_month AS cohort, invoice_month
    FROM v_tracked_sales
    WHERE invoice_month <= '2011-11-01'
),
indexed AS (
    SELECT customer_id, cohort,
           (CAST(substr(invoice_month, 1, 4) AS INTEGER) * 12 + CAST(substr(invoice_month, 6, 2) AS INTEGER))
         - (CAST(substr(cohort, 1, 4) AS INTEGER) * 12 + CAST(substr(cohort, 6, 2) AS INTEGER)) AS k
    FROM activity
),
sizes AS (
    SELECT cohort, COUNT(DISTINCT customer_id) AS cohort_size
    FROM indexed
    WHERE k = 0
    GROUP BY cohort
)
SELECT i.cohort,
       i.k,
       s.cohort_size,
       COUNT(DISTINCT i.customer_id)                                  AS active,
       ROUND(1.0 * COUNT(DISTINCT i.customer_id) / s.cohort_size, 4)  AS retention
FROM indexed i
JOIN sizes s USING (cohort)
GROUP BY i.cohort, i.k
ORDER BY i.cohort, i.k;

-- name: repeat_rate_90d
-- Share of new customers who placed a second order within 90 days of their first.
-- Only customers whose first order is at least 90 days before the end of the data.
WITH orders AS (
    SELECT customer_id, invoice, MIN(invoice_date) AS ts
    FROM v_tracked_sales
    GROUP BY customer_id, invoice
),
ranked AS (
    SELECT customer_id, ts,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ts) AS rn
    FROM orders
),
pairs AS (
    SELECT a.customer_id, a.ts AS first_ts, b.ts AS second_ts
    FROM ranked a
    LEFT JOIN ranked b ON b.customer_id = a.customer_id AND b.rn = 2
    WHERE a.rn = 1
)
SELECT substr(first_ts, 1, 4) || ' H' ||
           CASE WHEN CAST(substr(first_ts, 6, 2) AS INTEGER) <= 6 THEN 1 ELSE 2 END AS acquisition_half,
       COUNT(*) AS customers,
       ROUND(AVG(CASE WHEN julianday(second_ts) - julianday(first_ts) <= 90 THEN 1.0 ELSE 0.0 END), 4) AS repeat_rate_90d
FROM pairs
WHERE julianday((SELECT MAX(invoice_date) FROM transactions)) - julianday(first_ts) >= 90
GROUP BY acquisition_half
ORDER BY acquisition_half;
