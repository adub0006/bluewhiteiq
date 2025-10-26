#  BlueWhiteIQ
BlueWhiteIQ is a Snowflake-only fan-analytics project developed for the **North Melbourne Football Club (NMFC)**.  
It demonstrates reproducible SQL workflows to estimate **Customer Lifetime Value (CLV)** and explore **fan-engagement insights**.

> ⚠️ No confidential or raw data is stored here – only SQL logic, documentation, and mock outputs.

## 🎯 Objectives
- Calculate historical + projected CLV.  
- Segment customers into CLV bands.  
- Analyse engagement and tenure-frequency behaviour.  
- Combine membership & e-commerce data for insights.  
- Present a transparent, reproducible workflow.


## 🗂️ Repository Structure

<pre> bluewhiteiq/ ├── README.md ├── LICENSE ├── .gitignore │ ├── sql/ │ ├── 01_data_cleaning.sql │ ├── 02_clv_calculation.sql │ ├── 03_engagement_analysis.sql │ └── 04_cross_channel_value.sql │ ├── reports/ │ ├── BlueWhiteIQ_Report.qmd │ ├── NMFC_Presentation.pptx │ └── BlueWhiteIQ_Slides.pdf │ ├── outputs/ │ └── sample_outputs.csv │ └── run_guide/ └── Snowflake_Run_Guide.md </pre>

##  Data Description

| Dataset | Description | Key Fields | Purpose |
|----------|--------------|------------|----------|
| FANS.RAW_CUSTOMERS | Fan demographics & membership data | user_id, email, membership_tier | Identify & segment fans |
| SALES.RAW_ORDERS | E-commerce transactions | order_id, user_id, total_amount, order_date | Calculate historical CLV |
| MEMBERSHIP.RAW_MEMBERS | Membership renewals & fees | user_id, start_date, fee_paid | Assess membership value |
| ENGAGEMENT.RAW_EVENTS | Digital interactions (clicks, views, likes) | user_id, event_type, timestamp | Measure fan engagement |

➡️ Only mock/aggregated examples are included in `outputs/sample_outputs.csv`; no real data is shared.

## Reproducibility Explanation
Even without Snowflake access, the project is **reproducible in principle**:

1. Every SQL file lists its inputs, transformations & outputs in comments.  
2. Parameters (e.g., date ranges) appear at the top for easy reruns.  
3. `run_guide/Snowflake_Run_Guide.md` shows the correct execution order.  
4. Example outputs display expected column names and formats.

## How to Run (Conceptually)

Because this project is based on **Snowflake SQL**, actual execution requires access to the NMFC Snowflake environment.  
However, all logic is fully documented so that anyone with the same database can reproduce the results.

### Steps to Reproduce

1️⃣ **Connect to Snowflake**  
   - Use role: `ANALYST_NMFC`  
   - Warehouse: `NMFC_WH`  
   - Database: `NMFC_ANALYTICS`

2️⃣ **Run scripts in this order:**

```sql
USE ROLE ANALYST_NMFC;
USE WAREHOUSE NMFC_WH;
USE DATABASE NMFC_ANALYTICS;

-- 1️⃣ Data Cleaning
-- File: sql/01_data_cleaning.sql
-- Creates: FANS.CLEAN_CUSTOMERS

-- 2️⃣ CLV Calculation
-- File: sql/02_clv_calculation.sql
-- Creates: SALES.CLV_SUMMARY

-- 3️⃣ Engagement Analysis
-- File: sql/03_engagement_analysis.sql
-- Creates: ENGAGEMENT.ENGAGEMENT_AGG

-- 4️⃣ Cross-Channel Value Analysis
-- File: sql/04_cross_channel_value.sql
-- Creates: ANALYTICS.CROSS_CHANNEL_VIEW

## Good Practices Followed

- ✅ Frequent and meaningful commits with clear commit messages  
- ✅ Consistent folder and file naming conventions  
- ✅ `.gitignore` used to exclude data, temporary, and secret files  
- ✅ Repository includes a valid open-source licence (MIT)  
- ✅ Code and SQL scripts contain clear inline comments explaining logic  
- ✅ No large data or temporary files stored — ensuring clean reproducibility  
- ✅ Repository structure easy to navigate and well-organized

##  Deliverables

| File | Description |
|------|--------------|
| `BlueWhiteIQ_Report.qmd` | Reproducible report (Quarto format) explaining analysis & insights |
| `NMFC_Presentation.pptx` | Final presentation slides (main results & visuals) |
| `BlueWhiteIQ_Slides.pdf` | Exported PDF version of slides |
| `sample_outputs.csv` | Mock example output for demonstration (no real data) |
| `Snowflake_Run_Guide.md` | Logical step-by-step explanation for reproducibility |

