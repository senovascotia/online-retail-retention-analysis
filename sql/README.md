# SQL

Target engine: **SQLite 3.25+** (window functions). The scripts use only standard SQL apart from a few date functions (`julianday`, `substr`) and run unchanged in DB Browser for SQLite or any SQLite client against `data/processed/retail.db`. `notebooks/06_sql_analysis.ipynb` builds that database and runs every script.

| File | Purpose | Techniques |
|------|---------|------------|
| `01_create_tables.sql` | Schema and indexes for the cleaned transactions | DDL, indexes |
| `02_views.sql` | `v_sales`, `v_cancellations`, `v_tracked_sales` | Views |
| `03_kpis.sql` | Monthly KPIs, Jan-Nov growth, leakage summary, customer concentration | CTEs, `LAG`, running totals, `VALUES` lists |
| `04_cohort_retention.sql` | Cohort retention matrix and 90-day repeat rate | CTEs, month arithmetic, `ROW_NUMBER`, self-join |
| `05_rfm_segmentation.sql` | RFM scores and segments | `NTILE`, `CASE`, `SUM() OVER ()` |
| `06_churn_and_leakage.sql` | Churn back-test, 90-day rule precision / recall, live at-risk list | Correlated `EXISTS`, conditional aggregation |

Each query starts with a `-- name: <id>` line so the notebook can run and display it separately.

Reconciliation against pandas (notebook 06): gross sales, cancellations, concentration, all 300 cohort cells, RFM segment counts, back-test precision and recall, and the live at-risk list all match.
