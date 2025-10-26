# 🧭 Snowflake Run Guide — BlueWhiteIQ

This document describes how to reproduce the Snowflake SQL analysis for **BlueWhiteIQ**, 
a fan analytics project for North Melbourne Football Club (NMFC).  
It outlines the SQL execution order, assumptions, and validation steps.

## ⚙️ Environment Setup

All SQL scripts were written and executed in **Snowflake**.  
Before running the queries, ensure the correct **role**, **warehouse**, and **database** are set:

```sql
USE ROLE ANALYST_NMFC;
USE WAREHOUSE NMFC_WH;
USE DATABASE NMFC_ANALYTICS;


✅ *Why?* — Tells others what environment and settings are needed before running code.

---

### 🪜 Step 3 — List your scripts in execution order

Now write a simple **numbered list** showing what to run and what each file produces.

```markdown
## 📜 Script Execution Order

Run the scripts in the following order:

| Step | File | Purpose | Output Table |
|------|------|----------|---------------|
| 1 | `01_data_cleaning.sql` | Cleans and deduplicates membership and sales data. | `FANS.CLEAN_CUSTOMERS` |
| 2 | `02_clv_calculation.sql` | Calculates historical and projected CLV values. | `SALES.CLV_SUMMARY` |
| 3 | `03_engagement_analysis.sql` | Aggregates digital engagement data (Tradable Bits). | `ENGAGEMENT.ENGAGEMENT_AGG` |
| 4 | `04_cross_channel_value.sql` | Integrates e-commerce and membership metrics. | `ANALYTICS.CROSS_CHANNEL_VIEW` |
| 5 | `final_clv_segmentation.sql` | Segments fans into percentile bands and finalizes dataset. | `ANALYTICS.SEGMENTED` |

## ⚙️ Parameters Used in CLV Calculation

In the `PARAMS` CTE of `final_clv_segmentation.sql`, the following parameters are defined:

| Parameter | Description | Default Value |
|------------|--------------|----------------|
| `retention_rate` | % of customers expected to stay | 0.80 |
| `discount_rate` | Annual discount rate | 0.10 |
| `gross_margin` | Profit margin on sales | 0.60 |

These can be adjusted for sensitivity analysis if needed.

## ✅ Validation Checklist

After running all scripts:

- [ ] All 5 SQL scripts executed without error.
- [ ] `ANALYTICS.SEGMENTED` table exists.
- [ ] Row count > 0 (ensures successful joins).
- [ ] Columns present: `customer_name_id`, `clv_historical`, `clv_projected`, `engagement_count`, `clv_percentile_band`.
- [ ] No duplicate `customer_name_id` values.
- [ ] Tableau dashboards load data from `SEGMENTED` successfully.

## 📦 Expected Outputs

| Output | Format | Location |
|---------|---------|-----------|
| Final Segmented Dataset | Snowflake Table | `ANALYTICS.SEGMENTED` |
| Example Mock Output | CSV File | `/outputs/sample_outputs.csv` |
| Dashboards | Tableau Exports | `/tableau/` |
| Report | Quarto HTML | `/reports/BlueWhiteIQ_Report.html` |

---

🖋 **Author:** Avni Dubey  
📧 sales@procurewiser.com.au  
📅 Last updated: October 2025
