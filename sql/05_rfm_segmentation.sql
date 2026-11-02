-- RFM segmentation. Snapshot date = 2011-12-10 (day after the last transaction).
-- Recency and monetary are scored by quintile (NTILE); frequency uses fixed order-count bands
-- because quintiles would split identical one-order customers arbitrarily.

DROP VIEW IF EXISTS v_rfm;

CREATE VIEW v_rfm AS
WITH base AS (
    SELECT customer_id,
           MAX(CASE WHEN is_cancellation = 0 THEN invoice_date END)               AS last_purchase,
           COUNT(DISTINCT CASE WHEN is_cancellation = 0 THEN invoice END)         AS frequency,
           ROUND(SUM(line_total), 2)                                               AS monetary   -- net of cancellations, to pennies
    FROM transactions
    WHERE has_customer = 1
    GROUP BY customer_id
),
metrics AS (
    SELECT customer_id, frequency, monetary,
           CAST(julianday('2011-12-10') - julianday(last_purchase) AS INTEGER) AS recency
    FROM base
    WHERE last_purchase IS NOT NULL AND monetary > 0
),
scored AS (
    SELECT customer_id, recency, frequency, monetary,
           NTILE(5) OVER (ORDER BY recency DESC, customer_id) AS r,   -- recent = high score
           NTILE(5) OVER (ORDER BY monetary,     customer_id) AS m,
           CASE WHEN frequency = 1 THEN 1
                WHEN frequency = 2 THEN 2
                WHEN frequency <= 4 THEN 3
                WHEN frequency <= 9 THEN 4
                ELSE 5 END AS f
    FROM metrics
)
SELECT customer_id, recency, frequency, monetary, r, f, m,
       CASE WHEN r >= 4 AND f >= 4 THEN 'Champions'
            WHEN r = 3  AND f >= 4 THEN 'Loyal'
            WHEN r >= 4 AND f = 1  THEN 'New Customers'
            WHEN r >= 4            THEN 'Potential Loyalists'
            WHEN r = 3             THEN 'Need Attention'
            WHEN r = 2  AND f <= 2 THEN 'About to Sleep'
            WHEN r = 2             THEN 'At Risk'
            WHEN f >= 4            THEN 'Can''t Lose Them'
            WHEN f = 3             THEN 'Hibernating'
            ELSE 'Lost' END AS segment
FROM scored;

-- name: rfm_segments
SELECT segment,
       COUNT(*)                                                    AS customers,
       ROUND(1.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 4)            AS customer_share,
       ROUND(SUM(monetary), 0)                                     AS revenue,
       ROUND(SUM(monetary) / SUM(SUM(monetary)) OVER (), 4)        AS revenue_share,
       ROUND(AVG(recency), 1)                                      AS avg_recency_days,
       ROUND(AVG(frequency), 2)                                    AS avg_orders,
       ROUND(AVG(monetary), 0)                                     AS avg_net_sales
FROM v_rfm
GROUP BY segment
ORDER BY revenue DESC;
