-- Cleaned transactions (output of notebooks/01_data_cleaning.ipynb).
-- Target engine: SQLite 3.25+ (window functions). Dates are ISO-8601 text.
DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    invoice               TEXT    NOT NULL,
    stock_code            TEXT    NOT NULL,
    description           TEXT,
    quantity              INTEGER NOT NULL,
    invoice_date          TEXT    NOT NULL,   -- 'YYYY-MM-DD HH:MM:SS'
    price                 REAL    NOT NULL,
    customer_id           INTEGER,            -- NULL for guest orders
    country               TEXT,
    is_cancellation       INTEGER NOT NULL,   -- 1 = invoice starts with 'C'
    is_product            INTEGER NOT NULL,   -- 0 = postage, bank charges, vouchers, ...
    has_customer          INTEGER NOT NULL,
    line_total            REAL    NOT NULL,   -- quantity * price (negative for cancellations)
    invoice_month         TEXT    NOT NULL,   -- 'YYYY-MM-01'
    first_purchase_month  TEXT                -- cohort month, NULL for guests
);

CREATE INDEX idx_tx_customer ON transactions (customer_id);
CREATE INDEX idx_tx_date     ON transactions (invoice_date);
CREATE INDEX idx_tx_month    ON transactions (invoice_month);
