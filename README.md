# Retention & Revenue Leakage Analysis - Online Retail II

An end-to-end analysis of a UK online giftware retailer's transactions (Dec 2009 - Dec 2011) to find why revenue growth is held back and where revenue is lost.

**Dataset:** [UCI Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (1.07M raw rows, 1.03M after cleaning)
**Tools:** Python (pandas, seaborn, scipy, statsmodels), SQL (SQLite), interactive HTML dashboard

**Full write-up:** [`docs/latex/project_documentation.pdf`](docs/latex/project_documentation.pdf) (six phases, with the LaTeX source beside it)

**Open the dashboard:** [`dashboard/retail_dashboard.html`](dashboard/retail_dashboard.html) | Tableau version: [`dashboard/tableau/retail_dashboard.twbx`](dashboard/tableau/retail_dashboard.twbx) (packaged with its data; manual build guide: [`dashboard/tableau_build_guide.md`](dashboard/tableau_build_guide.md))

## Business problem
Sales grew only 1.9% year on year (Jan-Nov 2011 vs 2010). The starting hypothesis was that customers buy once and leave. The data says otherwise: the business is a repeat-driven wholesaler where **new-customer acquisition fell** while a **small group of loyal buyers carries the revenue**.

## Approach
1. **Frame** - 5 Whys and driver tree before touching data ([docs/01_problem_framing.md](docs/01_problem_framing.md))
2. **Clean** - sheet overlap, duplicates, invalid prices, cancellations, guest orders (notebook 01)
3. **Explore** - test each branch of the driver tree (notebook 02)
4. **Analyze** - cohort retention, RFM segmentation, churn back-test with hypothesis tests (notebooks 03-05)
5. **Reproduce in SQL** - the same answers from SQL scripts, reconciled against pandas (notebook 06)
6. **Recommend and present** - sized actions and an interactive dashboard (notebooks 07-08)

## Key findings

| 5 Whys hypothesis | Verdict | Evidence |
|---|---|---|
| 1. Customers stop after their first orders | **Refuted** | 72% reorder. Cohort quality has been stable since mid-2010 (90-day repeat rate about 41%, against 45% for 2010 H1). Growth is flat while new-customer acquisition fell 41% (Jun-Nov 2011 vs 2010), which fits the flat total but is not proof of cause |
| 2. Revenue depends on a small group | **Confirmed** | Top 10% of customers = 64% of sales. RFM Champions (24% of customers) = 70% of net revenue |
| 3. Purchase gaps lengthen before churn | **Refuted** | Last gap vs earlier gaps does not differ for churners (p = 0.58). Current silence is the signal: churn rises from 19% to 65% as silence grows |
| 4. Cancellations and seasonality drive churn | **Partly** | Seasonality confirmed (Sep-Nov = 40% of sales). Cancellations (7.1% of sales) do not drive churn (p = 0.54 after controls) |
| 5. No early-warning signal exists | **Feasible to build** | "Silent > 90 days" flags 54% of active customers, catches 75% of churners and 65% of churner revenue (61% precision) |

## Recommendations

| # | Action | Measured base | Annual impact (low / mid / high scenario) |
|---|---|---|---|
| 1 | Win back high-value customers silent for 90+ days (start with the top 60) | £490K expected loss | £49K / £98K / £147K |
| 2 | Alert on Champions and Loyal buyers at 1.5x their own reorder gap | £6.7M trailing sales | £67K / £134K / £200K |
| 3 | Find out why acquisition fell and restore it (UK first) | 646 fewer new customers | £93K / £186K / £371K |
| 4 | Order-entry checks for sale-then-cancel errors; capture customer IDs on guest orders | £731K cancelled a year | £73K / £146K / £219K |

The scenario percentages are assumptions to replace with test results; the measured bases come from the data.

## Limits of this analysis
- No marketing or channel data, so **why** acquisition fell is not answered.
- Churn is defined as no purchase for 161 days (a back-test window that includes the Q4 peak), not a confirmed loss.
- Product mix has only a small association with churn (notebook 11): it adds nothing to out-of-time prediction. Product categories are derived from descriptions, not an official field.
- The Dec 2009 cohort is overstated because the data starts there.

## Project structure
```
data/raw/          Original downloaded data
data/processed/    Cleaned data and analysis outputs (CSV, SQLite database)
docs/              Problem framing (5 Whys, driver tree), data dictionary
sql/               SQL scripts (numbered in run order)
notebooks/         Jupyter notebooks 00-08 (numbered in run order)
dashboard/         Interactive dashboard, its template, and CSV exports for BI tools
reports/figures/   Charts produced by the notebooks
```

## How to reproduce
```bash
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt
```
Then run the notebooks in `notebooks/` in order, or run them all at once by opening `notebooks/run_all.ipynb` and choosing *Run All* (about 6 minutes). `requirements.txt` lists the exact package versions tested on Python 3.15.2. For the full JupyterLab interface use Python 3.12 or 3.13 and `pip install -r requirements-jupyterlab.txt`.

Then open `dashboard/retail_dashboard.html`. See [notebooks/README.md](notebooks/README.md) for notes on Python versions.

## Data and licensing
The raw data and the large processed files are not stored in this repository. Run `notebooks/00_download_data.ipynb` to download the dataset, then run the remaining notebooks (or `run_all.ipynb`) to rebuild everything under `data/`. The Tableau package in `dashboard/tableau/` includes the small CSVs it needs.

- **Code and documentation:** MIT License, copyright Sena Miftahul Aziz, see [LICENSE](LICENSE).
- **Dataset:** [Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii), UCI Machine Learning Repository, licensed CC BY 4.0. Chen, D. (2012). Not redistributed here; follow the dataset's own terms when you download it.
