-- ======================================================================
-- File: final_clv_segmentation.sql
-- Author: Avni Dubey
-- Project: BlueWhiteIQ (NMFC Fan Analytics)
-- Purpose: Calculate Historical + Projected CLV and Segment Customers
-- Inputs:
--   - RPT_CUSTOMER_NMFC_PII  (membership & customer data)
--   - ARCHTICS_2.RPT_SALES_NMFC (membership transactions)
--   - cen_t1_data_lake.my_schema.big_commerce (e-commerce)
--   - cen_t1_data_lake.my_schema.tradable_bits / tradable_customer_details
-- Output:
--   - ANALYTICS.SEGMENTED (final CLV segmentation dataset)
-- Run Order: 05 (after 04_cross_channel_value.sql)
-- ======================================================================

-- Step 1: Define constant parameters for CLV (Customer Lifetime Value) calculation
-- These are business assumptions used in the projected CLV formula
WITH PARAMS AS (
    SELECT
        0.80::FLOAT AS retention_rate,   -- Percentage of customers expected to stay (80%)
        0.10::FLOAT AS discount_rate,    -- Discount rate to adjust future value to present
        0.60::FLOAT AS gross_margin      -- Profit margin on sales (60%)
),

-- Step 2: Get the latest membership duration for each active customer
-- This helps calculate revenue and purchase frequency per year
LATEST_MEMBERSHIP AS (
    SELECT
        customer_name_id,
        MAX(MEMBER_TOTAL_YEARS) AS MEMBER_TOTAL_YEARS  -- Most recent membership duration
    FROM RPT_CUSTOMER_NMFC_PII
    WHERE account_status = 'Active'  -- Only include active customers
    GROUP BY customer_name_id
),

-- Step 3: Merge customer and sales data to calculate historical and projected CLV
BASE_CLV AS (
    SELECT 
        p.customer_name_id,
        p.account_status,
        p.first_name,
        p.last_name,
        p.email,
        lm.Member_total_years,
        p.birth_year,
        p.postcode,
        p.current_age,
        p.gender,
        p.state,
        -- Total number of membership invoices/orders
        COUNT(DISTINCT a.order_id) AS membership_total_invoices,
        
        -- Total revenue from paid orders (excluding GST)
        SUM(a.PAID_AMOUNT_EXGST) AS MEMBERSHIP_TOTAL_REVENUE, 
        
        -- Average revenue per order
        (SUM(a.PAID_AMOUNT_EXGST) / COUNT(DISTINCT a.order_id)) AS MEMBERSHIP_AVG_REVENUE_SIZE,
        
        -- Revenue per year of membership
        (SUM(a.PAID_AMOUNT_EXGST) / NULLIF(lm.member_total_years, 0)) AS membership_revenue_per_year,
        
        -- Purchase frequency per year
        (COUNT(DISTINCT a.order_id) / NULLIF(lm.member_total_years, 0)) AS purchase_per_year,
        
        -- Historical CLV: total revenue from the customer
        SUM(a.paid_amount_exgst) AS clv_historical,
        
        -- Projected CLV using business parameters
        (membership_revenue_per_year * pr.gross_margin)* pr.retention_rate
        / NULLIF(1 + pr.discount_rate - pr.retention_rate, 0) AS clv_projected

    FROM RPT_CUSTOMER_NMFC_PII AS p 
    JOIN LATEST_MEMBERSHIP AS lm ON p.CUSTOMER_NAME_ID = lm.customer_name_id
    JOIN ARCHTICS_2.RPT_SALES_NMFC AS a ON p.customer_name_id = a.customer_name_id
    CROSS JOIN PARAMS AS pr
    WHERE 
        p.account_status = 'Active' 
        AND a.account_status = 'Active' 
        AND a.complimentary_type = 'Not Comp'  -- Exclude complimentary tickets
        AND a.product_type = 'Membership'      -- Focus only on membership products
        AND p.email IS NOT NULL 
        AND p.email NOT ILIKE '%@nmfc.com.au'  -- Exclude internal club emails
        AND p.email NOT ILIKE 'unknown%'       -- Exclude unknown emails
    GROUP BY 
        p.customer_name_id, p.account_status, lm.MEMBER_TOTAL_YEARS, 
        pr.retention_rate, pr.discount_rate, pr.gross_margin,
        p.first_name, p.last_name, p.email,p.birth_year,p.postcode,p.current_age,p.gender,p.state
),

-- Step 4: Aggregate BigCommerce data to get online purchase behavior
BIGCOMMERCE_AGG AS (
    SELECT 
        customer_email,
        shipping_first_name,
        shipping_last_name,
        PRODUCT_DETAILS,
        COUNT(order_id) AS ecommerce_total_orders,              -- Total number of online orders
        SUM(order_total_inctax) AS ecommerce_total_order_value, -- Total value of those orders
        MAX(order_date) AS last_ecommerce_order_date            -- Most recent order online date
    FROM cen_t1_data_lake.my_schema.big_commerce
    WHERE customer_email IS NOT NULL
    GROUP BY customer_email, shipping_first_name, shipping_last_name, product_details
),

-- Step 5: Combine fan_id from both engagement sources (contest + digital content)
COMBINED_ENGAGEMENT AS (
    SELECT fan_id FROM cen_t1_data_lake.my_schema.tradable_bits
    UNION ALL
    SELECT fan_id FROM cen_t1_data_lake.my_schema.tradable_customer_details
),

-- Step 6: Count how many times each fan_id appears (i.e., engagement frequency)
-- Join with customer details to get name and email
FAN_ENGAGEMENT_COUNT AS (
    SELECT 
        tcd.fan_id,
        tcd.first_name,
        tcd.last_name,
        tcd.email,
        COUNT(*) AS engagement_count  -- Total number of engagements per fan
    FROM COMBINED_ENGAGEMENT AS ce
    JOIN cen_t1_data_lake.my_schema.tradable_customer_details AS tcd
      ON ce.fan_id = tcd.fan_id
    GROUP BY tcd.fan_id, tcd.first_name, tcd.last_name, tcd.email
),

-- Step 7: Merge all datasets and use ROW_NUMBER to deduplicate customers
FINAL_JOINED AS (
    SELECT 
        bc.*,                        -- All CLV and customer fields
        ba.ecommerce_total_orders,             -- Online order count
        ba.ecommerce_total_order_value,        -- Online order value
        ba.last_ecommerce_order_date,          -- Last online order date
        ba.product_details,          -- Product info
        fec.engagement_count,        -- Number of contest/digital engagements
        -- Deduplicate: keep only one row per customer based on highest ecommerce value
        ROW_NUMBER() OVER (
            PARTITION BY bc.customer_name_id 
            ORDER BY COALESCE(ba.ecommerce_total_order_value, 0) DESC
        ) AS dedup_rn                     
    FROM BASE_CLV AS bc
    LEFT JOIN BIGCOMMERCE_AGG AS ba
       ON LOWER(TRIM(bc.email)) = LOWER(TRIM(ba.customer_email))
       AND LOWER(TRIM(bc.first_name)) = LOWER(TRIM(ba.shipping_first_name))
       AND LOWER(TRIM(bc.last_name)) = LOWER(TRIM(ba.shipping_last_name))
    LEFT JOIN FAN_ENGAGEMENT_COUNT AS fec
       ON LOWER(TRIM(bc.email)) = LOWER(TRIM(fec.email))
       AND LOWER(TRIM(bc.first_name)) = LOWER(TRIM(fec.first_name))
       AND LOWER(TRIM(bc.last_name)) = LOWER(TRIM(fec.last_name))
),

-- Step 8: Keep only one row per customer and rank them by historical CLV
Ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (ORDER BY clv_historical DESC) AS rn,  -- Rank by CLV
         COUNT(*) OVER () AS total_count                          -- Total number of customers
  FROM FINAL_JOINED
  WHERE dedup_rn = 1 -- Only keep the top row per customer
),
-- Step 9: Assign each customer to a CLV percentile band
Segmented AS (
  SELECT 
    customer_name_id,
    account_status,
    first_name,
    last_name,
    email,
    birth_year,
    current_age,
    gender,
    state,
    postcode,
    member_total_years,
    membership_total_invoices,
    membership_total_revenue,
    membership_avg_revenue_size,
    membership_revenue_per_year,
    purchase_per_year,
    clv_historical,
    clv_projected,
    ecommerce_total_orders,
    ecommerce_total_order_value,
    last_ecommerce_order_date,
    product_details,
    engagement_count,
    CASE 
      WHEN rn <= total_count * 0.10 THEN 'Top 10%'
      WHEN rn <= total_count * 0.20 THEN '10% to 20%'
      WHEN rn <= total_count * 0.30 THEN '20% to 30%'
      WHEN rn <= total_count * 0.40 THEN '30% to 40%'
      WHEN rn <= total_count * 0.50 THEN '40% to 50%'
      ELSE 'Below 50%'
    END AS clv_percentile_band
  FROM Ranked
)
-- Step 10: Final output with all customers and their CLV segment
SELECT *
FROM Segmented
ORDER BY clv_historical DESC;
