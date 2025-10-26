# 🏈 BlueWhiteIQ

**BlueWhiteIQ** is a *Snowflake + Tableau* fan analytics project developed for the **North Melbourne Football Club (NMFC)**.  
It calculates **Customer Lifetime Value (CLV)**, explores **fan engagement behaviour**, and visualises insights using **Tableau dashboards** — all following reproducible data-analysis practices.

> ⚠️ No confidential or raw data is stored in this repository.  
> Only SQL logic, documentation, and example outputs are included for transparency.

---

## 🎯 Objectives

- Calculate historical and projected **Customer Lifetime Value (CLV)**.  
- Segment customers into CLV percentile bands.  
- Analyse engagement patterns and tenure–frequency behaviour.  
- Integrate **Snowflake SQL** analysis with **Tableau** for visual insights.  
- Present a transparent and reproducible analytical workflow.

---

## 🗂️ Repository Structure
```
bluewhiteiq/
├── README.md # Project overview and reproducibility notes
├── LICENSE # MIT licence
├── .gitignore # Excludes temp/data/secret files
│
├── sql/ # Snowflake SQL scripts
│ ├── 01_data_cleaning.sql
│ ├── 02_clv_calculation.sql
│ ├── 03_engagement_analysis.sql
│ ├── 04_cross_channel_value.sql
│ └── final_clv_segmentation.sql
│
├── tableau/ # Tableau dashboards and screenshots
│ ├── BlueWhiteIQ_Dashboard_Screenshots.pdf
│ ├── CLV_Distribution.png
│ ├── Engagement_vs_CLV.png
│ ├── Cross_Channel_Value.png
│ └── README_Tableau.md
│
├── reports/ # Quarto report and presentation
│ ├── BlueWhiteIQ_Report.qmd
│ ├── BlueWhiteIQ_Report.html
│ ├── NMFC_Presentation.pptx
│ └── BlueWhiteIQ_Slides.pdf
│
├── outputs/ # Example (non-confidential) output
│ └── sample_outputs.csv
│
└── run_guide/ # Reproducibility documentation
└── Snowflake_Run_Guide.md

```
---

## 📊 Data Description

| Dataset | Description | Key Fields | Purpose |
|----------|--------------|------------|----------|
| `RPT_CUSTOMER_NMFC_PII` | Active membership and demographic info | `customer_name_id`, `email`, `membership_years`, `state` | Identify and segment members |
| `ARCHTICS_2.RPT_SALES_NMFC` | Membership sales and transactions | `order_id`, `customer_name_id`, `paid_amount_exgst` | Calculate historical CLV |
| `big_commerce` | E-commerce purchase data | `order_id`, `customer_email`, `order_total_inctax` | Analyse merchandise behaviour |
| `tradable_bits` / `tradable_customer_details` | Digital engagement data | `fan_id`, `email`, `event_type` | Measure fan engagement intensity |

➡️ Only **aggregated or mock output samples** are shared; no raw or personal data is included.

---

## 🧠 Reproducibility Explanation

Even without direct Snowflake access, this project ensures **conceptual reproducibility**:

1. Each SQL script lists its **inputs, transformations, and outputs** clearly in commented headers.  
2. Parameters (retention, margin, discount rate) are declared for easy modification.  
3. The full execution order is documented in `run_guide/Snowflake_Run_Guide.md`.  
4. Mock outputs in `/outputs/` show the expected table structure and variable names.  
5. Tableau dashboards are based on the same `Segmented` table produced in SQL.

---

## ⚙️ How to Run (Conceptually)

Because this project is based on **Snowflake SQL**, actual execution requires access to NMFC’s Snowflake data warehouse.  
However, the logic is fully reproducible for anyone with similar datasets.

### 🪜 Steps to Reproduce

1️⃣ **Connect to Snowflake**
- Role: `ANALYST_NMFC`  
- Warehouse: `NMFC_WH`  
- Database: `NMFC_ANALYTICS`

2️⃣ **Run scripts in this order**

```sql
USE ROLE ANALYST_NMFC;
USE WAREHOUSE NMFC_WH;
USE DATABASE NMFC_ANALYTICS;

-- 1️⃣ Data Cleaning
-- File: sql/01_data_cleaning.sql → FANS.CLEAN_CUSTOMERS

-- 2️⃣ CLV Calculation
-- File: sql/02_clv_calculation.sql → SALES.CLV_SUMMARY

-- 3️⃣ Engagement Analysis
-- File: sql/03_engagement_analysis.sql → ENGAGEMENT.ENGAGEMENT_AGG

-- 4️⃣ Cross-Channel Value
-- File: sql/04_cross_channel_value.sql → ANALYTICS.CROSS_CHANNEL_VIEW

-- 5️⃣ Final CLV Segmentation
-- File: sql/final_clv_segmentation.sql → ANALYTICS.SEGMENTED

## 📊 Visualisation & Insights (Tableau)

After producing the final **Segmented dataset** in Snowflake, the results were imported into **Tableau** for interactive visualisation and business insight generation.

### 🔹 Dashboards Created

1. **CLV Distribution Dashboard**
   - Shows the distribution of **Customer Lifetime Value (CLV)** across fan segments.
   - Confirms the **Pareto pattern (80/20 rule)** — top 20 % of customers contribute ~70 % of total revenue.
   - Helps the club identify and retain high-value members.

2. **Engagement vs CLV Scatter Plot**
   - Displays the relationship between **digital engagement** and **fan value**.
   - Highlights customers with **high engagement but low CLV**, a key group for upselling and retention campaigns.

3. **Cross-Channel Value Dashboard**
   - Compares **membership value** versus **e-commerce value**.
   - Reveals **omnichannel champions** who perform strongly across both channels.

4. **Geographic Reach Map (Optional, if you have one)**
   - Plots fan concentration by state/region.
   - Provides insight into regional marketing opportunities.

### 🧠 Key Insights

- CLV is **positively correlated** with engagement frequency.  
- **High-value fans** often hold multi-year memberships and purchase merchandise regularly.  
- **Low-CLV but highly engaged** fans represent **potential growth** opportunities.  
- Targeted offers and cross-channel campaigns can **increase retention** and average CLV.

📂 All dashboard screenshots are stored in `/tableau/BlueWhiteIQ_Dashboard_Screenshots.pdf`.

## 🧩 Good Practices Followed

This repository follows professional data-science and software-engineering conventions to ensure clarity, reproducibility, and maintainability.

- ✅ **Version control discipline** – frequent, meaningful commits with descriptive messages (e.g., `feat(sql): add CLV calculation query`).  
- ✅ **Structured folder organisation** – logical separation for `sql/`, `reports/`, `tableau/`, `outputs/`, and `run_guide/`.  
- ✅ **Data privacy and security** – `.gitignore` excludes all raw or sensitive data files (`.csv`, `.env`, etc.).  
- ✅ **Open-source transparency** – licensed under the MIT licence for reuse.  
- ✅ **Reproducible workflow** – every SQL script includes headers explaining purpose, inputs, and outputs.  
- ✅ **Consistent formatting** – descriptive variable names, indentation, and comments maintained throughout.  
- ✅ **No temporary or redundant files** – only final, relevant deliverables are committed.  
- ✅ **Readable documentation** – detailed `README.md` and `Snowflake_Run_Guide.md` enable others to follow the workflow easily.
