# Notebooks

Run in order. Each notebook opens with its goal and ends with key takeaways. Notebooks 01-08 read what the earlier ones wrote to `data/processed/`.

| Notebook | Goal | Main output |
|----------|------|-------------|
| `00_download_data.ipynb` | Download the UCI dataset into `data/raw/` | `online_retail_II.xlsx` |
| `01_data_cleaning.ipynb` | Load both sheets, profile quality issues, clean with a row-count waterfall | `transactions_clean.csv` |
| `02_eda.ipynb` | Test each branch of the driver tree: revenue, seasonality, new vs returning customers, concentration, cancellations, geography | `reports/figures/02_*.png` |
| `03_cohort_retention.ipynb` | Monthly cohort retention, 90-day repeat rate, why acquisition fell | `cohort_retention.csv`, `repeat_rate_90d.csv`, `new_customers_by_month.csv` |
| `04_rfm_segmentation.ipynb` | RFM scoring and 10 customer segments | `rfm_customers.csv`, `rfm_segments.csv` |
| `05_churn_and_hypothesis_tests.ipynb` | Time-split churn back-test, hypothesis tests, logistic regression, early-warning rule, live at-risk list | `churn_rule_backtest.csv`, `churn_by_recency.csv`, `at_risk_customers.csv` |
| `06_sql_analysis.ipynb` | Load a SQLite database, run the `sql/` scripts, reconcile every result against pandas | `retail.db` |
| `07_recommendations.ipynb` | Size four recommendations with low / mid / high scenarios | `recommendations.csv` |
| `08_build_dashboard.ipynb` | Assemble everything into the interactive dashboard and write the data files for Tableau | `dashboard/retail_dashboard.html`, `dashboard/tableau/data/*.csv` |
| `09_build_tableau_workbook.ipynb` | Generate a Tableau workbook (5 dashboards, 23 worksheets) connected to those CSV files | `dashboard/tableau/retail_dashboard_generated.twb` and `.twbx` (never overwrites the hand-edited `retail_dashboard.twbx`) |
| `11_robustness_checks.ipynb` | Product mix vs churn, the churn rule at five cutoff dates, bootstrap and exact intervals for the headline numbers | `robustness_*.csv`, `reports/figures/11_*.png` |
| `10_documentation_tables.ipynb` | Write the tables and key numbers of the LaTeX document from the project outputs and the packaged Tableau workbook (run after 11) | `docs/latex/generated/*.tex` |

## Notes
- Notebooks expect to run from the `notebooks/` folder (Jupyter does this by default).
- `06_sql_analysis` ends with an assertion that 18 SQL-vs-pandas checks match.
- Notebooks 08 and 09 must run in that order (09 reads the CSVs 08 writes). If you change the columns of a file in `dashboard/tableau/data/`, save it under a new file name: Tableau caches an extract per CSV name and fails with "InsertData: unbound column" when the layout changes.
- **Run everything:** open `run_all.ipynb` and choose *Run All* (it runs 01 to 09 in order, saves their outputs, and stops at the first error). To run only some, set `RUN_ONLY`, for example `RUN_ONLY=04_rfm_segmentation,05_churn_and_hypothesis_tests`.
- All notebooks have been executed end to end and **their outputs are saved** (tables and charts show when you open them; no errors).
- Python 3.15 was used for development. JupyterLab does not install on 3.15 (`pyyaml`, a dependency, has no build for it). The `.venv` has `ipykernel`, `nbclient` and `nbconvert` instead, which is enough to run notebooks:
  - **Run from VS Code:** open a notebook and pick the `.venv` interpreter as the kernel.
  - **Re-run everything from a terminal** (from this folder): `..\.venv\Scripts\python -m nbconvert --to notebook --execute --inplace 01_data_cleaning.ipynb`, then the same for 02 to 09 in order.
  - For the full JupyterLab interface, create a Python 3.12 or 3.13 environment and run `pip install -r requirements.txt`.
