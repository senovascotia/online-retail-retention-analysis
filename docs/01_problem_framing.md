# 01 - Problem Framing

> Complete this **before** touching the data. Everything below is a hypothesis to be confirmed, refuted, or refined by the analysis.

## Business context
A UK-based online retailer selling giftware, largely to wholesale customers (Dec 2009 - Dec 2011).

## Core question
Why is revenue growth being held back, and where is revenue being lost? Focus: customer retention and repeat purchasing.

## 5 Whys (hypotheses)

| # | Why? | Hypothesis | Evidence needed | Status |
|---|------|-----------|-----------------|--------|
| 1 | Why is revenue growth stalling? | Too few customers keep buying after their first orders | Cohort retention, repeat-purchase rate | **Refuted.** 72% of customers reorder and cohort quality has been stable since mid-2010 (month-1 activity ~20%; 90-day repeat about 41%, against 45% in 2010 H1). Sales are flat (+1.9%) while new-customer acquisition fell 41-54% in 2011 (UK -43%) and first-order value held steady. That fits the flat total, but it does not prove the cause. The data cannot say why (no channel data). Notebook 11: the -41% has a 95% interval of -46% to -36% and all 6 months fell; the 45% to 41% drop in the 90-day repeat rate between 2010 H1 and H2 is significant (p = 0.013) but may partly reflect left-censoring |
| 2 | Why do customers stop buying? | A large share of revenue depends on a small set of customers who churn | Pareto / RFM, churned-customer revenue share | **Confirmed.** Top 10% of customers = 63% of sales; RFM Champions (24% of customers) = 70% of net revenue. 126 top-value customers have been silent 142+ days (£858k lifetime sales) |
| 3 | Why do high-value customers churn? | Purchase gaps lengthen before churn; no re-engagement | Inter-purchase time analysis | **Refuted.** The last gap vs earlier gaps does not differ between churners and retained customers (p = 0.58). Current silence is the signal: churn rises from 19% (0-30 days silent) to 65% (181-365 days) |
| 4 | Why are there lengthening gaps? | Product mix is seasonal/one-off; high cancellations/returns | Category/product seasonality, cancellation rate by customer | **Partly.** Seasonality confirmed (Sep-Nov ~40% of sales; peak-season cohorts retain worse). Cancellations are 5-7% of sales and do **not** drive churn (p = 0.54 after controls). Product mix tested in notebook 11: a small effect that does not improve out-of-time prediction |
| 5 | Why isn't it caught early? | No early-warning signal or re-engagement trigger | Define churn-risk rule and back-test it | **Confirmed feasible.** A 90-day-silence rule flags 54% of active customers, catches 75% of churners and 65% of churner revenue (precision 61%). Applied today it flags 1,365 customers with £809k trailing sales. Notebook 11: across five cutoffs precision is 61-76% but recall is 45-76%, so the 75% holds at the 30 Jun 2011 cutoff, not in general |

Update the *Status* column (Confirmed / Refuted / Partly) and note findings. A refuted "why" is worth showing.

## Driver (issue) tree

```
Revenue growth stalls / revenue leakage
├── Customer base
│   ├── New customers
│   │   └── Acquisition volume per month
│   └── Existing customers
│       ├── Retention rate (cohort)
│       ├── Churned customers (no purchase in N days)
│       └── Concentration risk (top customers' share of revenue)
├── Order value
│   ├── Basket size (items per invoice)
│   └── Average unit price / product mix
├── Order frequency
│   ├── Inter-purchase time
│   └── Seasonality (Q4 peak vs rest of year)
└── Leakage
    ├── Cancellations (invoices starting with "C")
    ├── Returns / negative quantities
    └── Guest orders with no Customer ID (untrackable revenue)
```

## Success metrics
- Repeat purchase rate
- Monthly cohort retention
- Revenue share by RFM segment
- Cancellation rate (by value)
- Share of revenue from customers at churn risk

## Deliverable
3 prioritized, quantified recommendations (e.g., "re-engaging the 'At Risk' segment could recover ~X GBP/yr").
