-- Convenience views used by the analysis queries.
DROP VIEW IF EXISTS v_sales;
DROP VIEW IF EXISTS v_cancellations;
DROP VIEW IF EXISTS v_tracked_sales;

-- Real sales (cancellations excluded)
CREATE VIEW v_sales AS
SELECT * FROM transactions WHERE is_cancellation = 0;

-- Cancelled lines (negative quantity and line_total)
CREATE VIEW v_cancellations AS
SELECT * FROM transactions WHERE is_cancellation = 1;

-- Sales from customers we can follow over time (guest orders excluded)
CREATE VIEW v_tracked_sales AS
SELECT * FROM transactions WHERE is_cancellation = 0 AND has_customer = 1;
