-- Churn back-test and live at-risk list.
-- Back-test: history to 2011-06-30; churned = no purchase between 2011-07-01 and the end of the data.
-- Base: customers with at least one purchase in the 12 months to the cutoff.

DROP VIEW IF EXISTS v_churn_base;

CREATE VIEW v_churn_base AS
WITH base AS (
    SELECT customer_id, MAX(invoice_date) AS last_ts
    FROM v_tracked_sales
    WHERE invoice_date <= '2011-06-30 23:59:59'
    GROUP BY customer_id
    HAVING MAX(invoice_date) > '2010-06-30 23:59:59'
)
SELECT b.customer_id,
       CAST(julianday('2011-06-30') - julianday(date(b.last_ts)) AS INTEGER) AS recency,
       CASE WHEN EXISTS (
                SELECT 1 FROM v_tracked_sales f
                WHERE f.customer_id = b.customer_id
                  AND f.invoice_date > '2011-06-30 23:59:59')
            THEN 0 ELSE 1 END AS churned
FROM base b;

-- name: churn_overall
SELECT COUNT(*) AS base_customers, ROUND(AVG(churned), 4) AS churn_rate
FROM v_churn_base;

-- name: churn_by_recency_band
-- Churn rate rises with time since last purchase.
SELECT CASE WHEN recency <= 30  THEN '0-30'
            WHEN recency <= 60  THEN '31-60'
            WHEN recency <= 90  THEN '61-90'
            WHEN recency <= 120 THEN '91-120'
            WHEN recency <= 180 THEN '121-180'
            ELSE '181-365' END AS days_silent,
       COUNT(*)                AS customers,
       ROUND(AVG(churned), 4)  AS churn_rate
FROM v_churn_base
GROUP BY days_silent
ORDER BY MIN(recency);

-- name: rule_silent_90_days
-- Back-test of the early-warning rule "no purchase for more than 90 days".
SELECT COUNT(*)                                                             AS flagged,
       ROUND(AVG(churned), 4)                                               AS precision,
       ROUND(1.0 * SUM(churned) / (SELECT SUM(churned) FROM v_churn_base), 4) AS recall
FROM v_churn_base
WHERE recency > 90;

-- name: at_risk_now
-- Apply the rule at the end of the data (2011-12-10) to customers active in the previous 12 months.
WITH base AS (
    SELECT customer_id, MAX(invoice_date) AS last_ts
    FROM v_tracked_sales
    WHERE invoice_date <= '2011-12-10 00:00:00'
    GROUP BY customer_id
    HAVING MAX(invoice_date) > '2010-12-10 00:00:00'
),
rev AS (
    SELECT customer_id, ROUND(SUM(line_total), 2) AS trailing_rev      -- net of cancellations
    FROM transactions
    WHERE has_customer = 1
      AND invoice_date >  '2010-12-10 00:00:00'
      AND invoice_date <= '2011-12-10 00:00:00'
    GROUP BY customer_id
),
scored AS (
    SELECT b.customer_id,
           CAST(julianday('2011-12-10') - julianday(date(b.last_ts)) AS INTEGER) AS recency,
           COALESCE(r.trailing_rev, 0) AS trailing_rev
    FROM base b
    LEFT JOIN rev r USING (customer_id)
)
SELECT COUNT(*)                                                         AS active_customers,
       SUM(recency > 90 AND trailing_rev > 0)                           AS flagged_customers,
       ROUND(SUM(CASE WHEN recency > 90 AND trailing_rev > 0 THEN trailing_rev END), 0) AS flagged_trailing_rev
FROM scored;

-- name: at_risk_top_customers
-- The most valuable customers silent for more than 90 days.
WITH last_buy AS (
    SELECT customer_id, MAX(invoice_date) AS last_ts
    FROM v_tracked_sales
    WHERE invoice_date <= '2011-12-10 00:00:00'
    GROUP BY customer_id
    HAVING MAX(invoice_date) > '2010-12-10 00:00:00'
)
SELECT t.customer_id,
       CAST(julianday('2011-12-10') - julianday(date(l.last_ts)) AS INTEGER) AS days_silent,
       COUNT(DISTINCT CASE WHEN t.is_cancellation = 0 THEN t.invoice END)    AS invoices,
       ROUND(SUM(t.line_total), 0)                                           AS trailing_rev
FROM transactions t
JOIN last_buy l USING (customer_id)
WHERE t.has_customer = 1
  AND t.invoice_date >  '2010-12-10 00:00:00'
  AND t.invoice_date <= '2011-12-10 00:00:00'
GROUP BY t.customer_id
HAVING days_silent > 90 AND trailing_rev > 0
ORDER BY trailing_rev DESC
LIMIT 10;
