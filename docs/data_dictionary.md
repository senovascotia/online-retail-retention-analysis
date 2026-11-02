# Data Dictionary - UCI Online Retail II

Source: https://archive.ics.uci.edu/dataset/502/online+retail+ii
Coverage: 01/12/2009 - 09/12/2011, UK-based online retailer.
Format: one Excel file with two sheets (`Year 2009-2010`, `Year 2010-2011`), ~1M rows total.

| Column | Type | Description |
|--------|------|-------------|
| Invoice | string | Invoice number (6 digits). Starting with `C` = cancellation |
| StockCode | string | Product code |
| Description | string | Product name |
| Quantity | int | Units per transaction (negative for cancellations/returns) |
| InvoiceDate | datetime | Invoice date and time |
| Price | float | Unit price (GBP) |
| Customer ID | float | Customer number (missing for guest/untracked orders) |
| Country | string | Customer's country of residence |

## Known data quality issues to handle (document each decision)
- Missing `Customer ID` (~20% of rows)
- Cancellations (`Invoice` starts with `C`) and negative quantities
- Zero or negative `Price` (adjustments, bad debt, samples)
- Non-product `StockCode` values (e.g., POST, D, M, BANK CHARGES)
- Duplicate rows
- Inconsistent / missing `Description`
- Two sheets that overlap in Dec 2010

## Derived fields (to create)
- `LineTotal = Quantity * Price`
- `IsCancellation`
- `InvoiceMonth`
- `CustomerFirstPurchaseMonth` (cohort)
