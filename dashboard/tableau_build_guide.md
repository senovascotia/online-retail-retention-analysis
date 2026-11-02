# Build the dashboard in Tableau

Mirrors `retail_dashboard.html` (five tabs). Allow about 60-90 minutes in Tableau Desktop or Tableau Public Desktop.

All data is in `dashboard/tableau_data/`. Every file is tidy and needs **no joins**: connect each one as its own text-file data source (Connect > Text file, then Data > New Data Source for each additional file).

## 1. Connect the data

| File | Used for |
|---|---|
| `kpis.csv` | Headline tiles |
| `monthly.csv` | Sales trend, new vs returning customers |
| `new_customers_by_region.csv` | New customers, UK vs non-UK |
| `cohort_retention.csv` | Cohort heatmap |
| `repeat_rate_90d.csv` | 90-day repeat rate |
| `rfm_segments.csv` | Segment bars and slipping tiles |
| `revenue_concentration.csv` | Pareto curve |
| `churn_by_days_silent.csv` | Churn by recency |
| `rule_backtest.csv` | Early-warning rule table |
| `top_at_risk_customers.csv` | Contact list |
| `recommendations.csv` | Actions table |

On each source check the data types: `month`, `cohort_month` = **Date**; `*_share`, `retention`, `churn_rate`, `precision`, `recall`, `revenue_captured`, `repeat_rate_90d`, `pct_of_customers`, `cum_pct_of_sales` = **Number (decimal)**, default format **Percentage**; `is_partial`, `early_flag` = **Boolean**; `customer_id` = **String** (right-click > Convert to Dimension).

## 2. Style

- Font: Tableau Book. Chart background white, no borders, light gray gridlines, no zero lines except the axis.
- Palette (same as the HTML version): **blue `#2A78D6`** (main series), **orange `#EB6834`** (second series / emphasis), gray `#898781` for axis text, `#52514E` for secondary text.
- Heatmap sequential ramp (Edit Colors > Custom Sequential, 7 steps): `#CDE2FB` `#9EC5F4` `#6DA7EC` `#3987E5` `#256ABF` `#184F95` `#0D366B`.
- Number formats: GBP millions `£#,##0.0,,"M"`; GBP thousands `£#,##0,"K"`; percentages `0%`.

## 3. Calculated fields

In `kpis.csv` (one per tile; the tile sheet shows a single number):

```
Gross sales          = SUM(IF [metric] = "gross_sales" THEN [value] END)
Tracked customers    = SUM(IF [metric] = "tracked_customers" THEN [value] END)
Repeat rate          = SUM(IF [metric] = "repeat_rate" THEN [value] END)
Sales growth         = SUM(IF [metric] = "yoy" THEN [value] END)
New customer change  = SUM(IF [metric] = "new_cust_change" THEN [value] END)
Flagged customers    = SUM(IF [metric] = "flagged_customers" THEN [value] END)
Flagged sales        = SUM(IF [metric] = "flagged_rev" THEN [value] END)
Expected loss        = SUM(IF [metric] = "expected_loss" THEN [value] END)
Top tier customers   = SUM(IF [metric] = "top_tier_customers" THEN [value] END)
Top tier sales       = SUM(IF [metric] = "top_tier_rev" THEN [value] END)
```

In `revenue_concentration.csv`: `Equal share = [pct_of_customers]`.

## 4. Worksheets

Create one sheet per row. "Filter" lists filters to add.

### Overview
| Sheet | Source | Columns | Rows | Marks and format | Filter |
|---|---|---|---|---|---|
| `T Gross sales` | kpis | | | Text, `Gross sales`, 48pt bold, format `£#,##0.0,,"M"` | |
| `T Customers` / `T Repeat` / `T Growth` / `T New` | kpis | | | Text, the matching calculated field, 24pt, `Sales growth` and `New customer change` as `+0.0%;-0.0%` | |
| `Monthly sales` | monthly | `MONTH(month)` continuous (exact month) | `SUM(gross_sales)` | Bar, blue, axis `£#,##0.0,,"M"`, tooltip adds orders and avg order value | `is_partial` = False |
| `New vs returning` | monthly | `MONTH(month)` | Measure Values: `new_customers`, `returning_customers` | Stacked bar, Measure Names on Color (returning = blue, new = orange), legend on top | `is_partial` = False |

### Retention
| Sheet | Source | Columns | Rows | Marks and format | Filter |
|---|---|---|---|---|---|
| `Cohort heatmap` | cohort_retention | `months_since_first_purchase` (discrete) | `MONTH(cohort_month)` discrete, year + month | Square marks, Color = `AVG(retention)` with the blue ramp, Label = `AVG(retention)` as `0%`, white text on dark cells (Label > Font, or use the auto contrast), tooltip shows `active_customers` of `cohort_size` | months 1-12 |
| `Repeat 90d` | repeat_rate_90d | `acquisition_period` (sort by `sort_order`) | `SUM(repeat_rate_90d)` | Bar, blue, label on top as `0%` | |
| `New customers by region` | new_customers_by_region | `MONTH(month)` | `SUM(customers)` | Stacked bar, `region` on Color (UK blue, Non-UK orange) | |

### Segments
| Sheet | Source | Columns | Rows | Marks and format | Filter |
|---|---|---|---|---|---|
| `RFM segments` | rfm_segments | Measure Values: `customer_share`, `revenue_share` | `segment` sorted by `revenue_rank` | Bar, Measure Names on Color (customers blue, revenue orange), label only on revenue as `0%`, axis `0%` | |
| `Concentration` | revenue_concentration | `pct_of_customers` (continuous dimension) | Measure Values: `cum_pct_of_sales` and `Equal share` (shared axis, not dual axis) | Line, blue 2px for cumulative, gray thin for equal share, axes `0%` | |
| `Slipping tiles` | rfm_segments | | | Text; filter `segment_group` = Slipping; show `SUM(customers)`, `SUM(revenue)`, `SUM(revenue_share)` | |

### Churn risk
| Sheet | Source | Columns | Rows | Marks and format | Filter |
|---|---|---|---|---|---|
| `T Flagged` / `T Flagged sales` / `T Expected loss` / `T Top tier` | kpis | | | Text, the matching calculated fields | |
| `Churn by silence` | churn_by_days_silent | `days_silent` (sort by `sort_order`) | `SUM(churn_rate)` | Bar, orange, label as `0%` | |
| `Rule back-test` | rule_backtest | Measure Names: `flagged`, `precision`, `recall`, `revenue_captured` | `rule` (sort by `sort_order`) | Text table, percentages as `0%` | |
| `Contact list` | top_at_risk_customers | Measure Names: `days_silent`, `own_avg_gap_days`, `trailing_12m_sales` | `customer_id` sorted by sales descending | Text table | `value_tier` = 5, then Top 12 by `SUM(trailing_12m_sales)` |

### Actions
| Sheet | Source | Columns | Rows | Marks and format | Filter |
|---|---|---|---|---|---|
| `Recommendations` | recommendations | Measure Names: `measured_base_gbp`, `low_gbp`, `mid_gbp`, `high_gbp` | `rank`, `recommendation`, `effort` | Text table, GBP as `£#,##0,"K"` | |

## 5. Dashboards

Create five dashboards (size **Fixed, 1200 x 1000**, or Automatic). On each: a title text object, a row of **Navigation** buttons (Dashboard > Objects > Navigation, targets: the five dashboards), then the sheets below. Use a horizontal container for side-by-side items, a vertical container for stacks, and "Fit Width" for charts. Hide sheet titles and put a short subtitle in each chart's title area instead.

| Dashboard | Layout |
|---|---|
| **Overview** | Top row: `T Gross sales` (wide) + four small tiles. Middle: `Monthly sales` full width. Bottom: `New vs returning` (left) and a text box "Key insights" (right, copy the five bullets from the HTML version) |
| **Retention** | `Cohort heatmap` full width on top. Below: `Repeat 90d` (left), `New customers by region` (right). Add a caption about seasonality and the overstated Dec 2009 cohort |
| **Segments** | `RFM segments` full width. Below: `Concentration` (left), `Slipping tiles` (right) |
| **Churn risk** | Tile row on top. Below: `Churn by silence` (left), `Rule back-test` (right). Bottom: `Contact list` full width |
| **Actions** | `Recommendations` full width, plus a text box with the "what this data cannot tell you" caveats |

Interactivity: add **Use as Filter** on `RFM segments` (so clicking a segment filters the slipping tiles) and tooltips on every chart (Worksheet > Tooltip).

## 6. Check your numbers

If these match, the dashboard is wired correctly:

| Item | Expected |
|---|---|
| Gross sales tile | £20.5M |
| Tracked customers / repeat rate | 5,878 / 72% |
| Sales growth / new customers | +1.9% / -41% |
| Cohort heatmap, Dec 2009 row, months 1 and 3 | 35% and 43% |
| Champions | 24% of customers, 70% of revenue |
| Concentration, top 10% | 64% of sales |
| Churn by silence | 19%, 25%, 39%, 47%, 54%, 65% |
| Flagged customers / expected loss | 1,365 / £490K |
| Recommendations, mid scenario | £98K, £134K, £186K, £146K |

## 7. Publish (optional)

Tableau Public: Server > Tableau Public > Save to Tableau Public. This needs a free account and makes the workbook and its data public. The data is the public UCI dataset plus aggregates derived from it. Save the workbook as `dashboard/retail_dashboard.twbx` (packaged) so the data travels with it, then add the public link to the project README.
