/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 02_data/02_load_sample_data.sql
 *
 * PURPOSE:
 *   Populate star schema with synthetic credit portfolio data including
 *   specific entities: HealthTech Solutions, ACME, John Williams.
 *
 * DATA REQUIREMENTS:
 *   - HealthTech Solutions must exist in DIM_COMPANY
 *   - ACME must exist as fund_family in DIM_FUND
 *   - John Williams must be originator1 for 5-8 deals (2-3 on watchlist)
 *   - March 31, 2024 snapshot must exist in FACT_POSITION_SNAPSHOT
 *   - Month-end snapshots for Jan 2024 - current month
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SFE_ANALYTICS_CREDIT;

-- ============================================================================
-- STEP 1: POPULATE DIM_DATE
-- ============================================================================

INSERT INTO DIM_DATE
SELECT
    TO_NUMBER(TO_CHAR(d.date_val, 'YYYYMMDD')) AS date_key,
    d.date_val AS calendar_date,
    YEAR(d.date_val) AS year,
    QUARTER(d.date_val) AS quarter,
    MONTH(d.date_val) AS month,
    DAY(d.date_val) AS day_of_month,
    LAST_DAY(d.date_val) AS month_end_date,
    (d.date_val = LAST_DAY(d.date_val)) AS is_month_end
FROM (
    SELECT DATEADD(day, SEQ4(), '2024-01-01'::DATE) AS date_val
    FROM TABLE(GENERATOR(ROWCOUNT => 731))  -- 2024-01-01 to 2025-12-31 (2 years)
) d
WHERE d.date_val <= '2025-12-31';

-- ============================================================================
-- STEP 2: POPULATE DIM_COMPANY
-- ============================================================================

INSERT INTO DIM_COMPANY (company_id, company_name, industry, region)
VALUES
    -- Required entities
    (1, 'HealthTech Solutions', 'Healthcare Technology', 'Northeast'),
    (2, 'ACME Healthcare Partners', 'Healthcare Services', 'Southeast'),
    
    -- Additional synthetic companies
    (3, 'Summit Medical Systems', 'Healthcare Technology', 'West'),
    (4, 'Precision Diagnostics Corp', 'Healthcare Services', 'Midwest'),
    (5, 'CloudTech Solutions', 'Technology', 'West'),
    (6, 'DataCore Analytics', 'Technology', 'Northeast'),
    (7, 'CyberSecure Systems', 'Technology', 'West'),
    (8, 'Advanced Manufacturing Co', 'Manufacturing', 'Midwest'),
    (9, 'Industrial Components Inc', 'Manufacturing', 'Southeast'),
    (10, 'Precision Parts Group', 'Manufacturing', 'Midwest'),
    (11, 'RetailNext Brands', 'Retail', 'Southeast'),
    (12, 'Consumer Goods Direct', 'Retail', 'Southwest'),
    (13, 'MarketPlace Solutions', 'Retail', 'West'),
    (14, 'Business Services Hub', 'Business Services', 'Northeast'),
    (15, 'Professional Staffing Co', 'Business Services', 'Southeast'),
    (16, 'Logistics Partners LLC', 'Transportation & Logistics', 'Midwest'),
    (17, 'Supply Chain Systems', 'Transportation & Logistics', 'Southwest'),
    (18, 'Energy Solutions Group', 'Energy', 'Southwest'),
    (19, 'Telecommunications Inc', 'Telecommunications', 'Northeast'),
    (20, 'Financial Services Corp', 'Financial Services', 'Northeast');

-- ============================================================================
-- STEP 3: POPULATE DIM_SPONSOR
-- ============================================================================

INSERT INTO DIM_SPONSOR (sponsor_id, sponsor_name, sponsor_type)
SELECT
    SEQ4() + 1 AS sponsor_id,
    sponsor_data.sponsor_name,
    sponsor_data.sponsor_type
FROM (
    SELECT * FROM VALUES
        ('Apex Capital Partners', 'Mega-cap'),
        ('BlackStone Capital', 'Mega-cap'),
        ('Summit Equity Group', 'Large-cap'),
        ('Meridian Partners', 'Large-cap'),
        ('Pinnacle Investment Group', 'Large-cap'),
        ('Cornerstone Capital', 'Mid-market'),
        ('Heritage Partners', 'Mid-market'),
        ('Catalyst Equity', 'Mid-market'),
        ('Frontier Capital', 'Mid-market'),
        ('Vista Growth Partners', 'Mid-market'),
        ('Elevation Capital', 'Mid-market'),
        ('Pathway Equity', 'Mid-market'),
        ('Horizon Partners', 'Mid-market'),
        ('Bridge Capital Group', 'Mid-market'),
        ('Crest Equity Partners', 'Mid-market'),
        ('Ascent Capital', 'Small-cap'),
        ('Velocity Partners', 'Small-cap'),
        ('Momentum Capital', 'Small-cap'),
        ('Genesis Equity', 'Small-cap'),
        ('Nexus Partners', 'Small-cap'),
        ('Titan Capital', 'Small-cap'),
        ('Atlas Equity Group', 'Small-cap'),
        ('Pioneer Partners', 'Small-cap'),
        ('Venture Growth Capital', 'Small-cap'),
        ('Legacy Equity Partners', 'Small-cap'),
        ('Strategic Capital Group', 'Small-cap'),
        ('North Star Partners', 'Small-cap'),
        ('Crescent Capital', 'Small-cap'),
        ('Redwood Equity', 'Small-cap'),
        ('Evergreen Capital Partners', 'Small-cap')
) AS sponsor_data(sponsor_name, sponsor_type)
LIMIT 30;

-- ============================================================================
-- STEP 4: POPULATE DIM_FUND
-- ============================================================================

INSERT INTO DIM_FUND (fund_id, fund_name, fund_family, strategy_type, vintage_year)
VALUES
    -- Required ACME entities
    (1, 'ACME Direct Lending Fund I', 'ACME', 'Direct Lending', 2020),
    (2, 'ACME Opportunistic Credit Fund II', 'ACME', 'Opportunistic', 2021),
    (3, 'ACME Core+ Fund III', 'ACME', 'Core+', 2022),
    
    -- Additional funds
    (4, 'Summit Credit Partners Fund IV', 'Summit Credit', 'Direct Lending', 2021),
    (5, 'Apex Mezzanine Fund II', 'Apex Capital', 'Mezzanine', 2020),
    (6, 'Meridian Senior Secured Fund', 'Meridian Partners', 'Direct Lending', 2022),
    (7, 'Pinnacle Opportunistic Fund I', 'Pinnacle Investment', 'Opportunistic', 2023),
    (8, 'Vista Growth Credit Fund', 'Vista Growth', 'Core+', 2021),
    (9, 'Cornerstone Direct Lending II', 'Cornerstone Capital', 'Direct Lending', 2022),
    (10, 'Heritage Credit Opportunities', 'Heritage Partners', 'Opportunistic', 2023);

-- ============================================================================
-- STEP 5: POPULATE DIM_DEAL
-- ============================================================================

-- First, insert John Williams's deals (8 deals, 3 on watchlist)
INSERT INTO DIM_DEAL (deal_id, deal_name, company_id, deal_date, watchlist, rating, originator1, preparer)
VALUES
    -- John Williams deals with watchlist status
    (1, 'HealthTech Solutions IT Facility', 1, '2023-03-15', 'None', 2, 'John Williams', 'Jennifer Mills'),
    (2, 'CloudTech Infrastructure Loan', 5, '2023-06-20', 'Watchlist', 3, 'John Williams', 'Michael Chen'),
    (3, 'RetailNext Expansion Facility', 11, '2023-09-10', 'Intensive Care', 4, 'John Williams', 'Sarah Johnson'),
    (4, 'DataCore Growth Credit', 6, '2023-11-05', 'None', 2, 'John Williams', 'Robert Davis'),
    (5, 'Supply Chain Revolver', 17, '2024-01-15', 'None', 2, 'John Williams', 'Jennifer Mills'),
    (6, 'Energy Solutions Term Loan', 18, '2024-03-01', 'Watchlist', 3, 'John Williams', 'Michael Chen'),
    (7, 'Professional Staffing Credit', 15, '2024-04-20', 'None', 2, 'John Williams', 'Emily Parker'),
    (8, 'Logistics Partners Facility', 16, '2024-06-15', 'Intensive Care', 5, 'John Williams', 'David Kim');

-- Insert additional deals with other originators
INSERT INTO DIM_DEAL (deal_id, deal_name, company_id, deal_date, watchlist, rating, originator1, preparer)
SELECT
    deal_id,
    deal_name,
    company_id,
    deal_date,
    watchlist,
    rating,
    originator,
    preparer
FROM (
    SELECT
        SEQ4() + 9 AS deal_id,
        deal_data.deal_name,
        deal_data.company_id,
        deal_data.deal_date,
        deal_data.watchlist,
        deal_data.rating,
        deal_data.originator,
        deal_data.preparer
    FROM (
        SELECT * FROM VALUES
            ('Summit Medical Senior Facility', 3, '2023-02-10', 'None', 2, 'Jennifer Martinez', 'Sarah Johnson'),
            ('Precision Diagnostics Loan', 4, '2023-04-15', 'None', 2, 'John Williams', 'Emily Parker'),
            ('CyberSecure Growth Facility', 7, '2023-05-20', 'None', 2, 'Jennifer Martinez', 'David Kim'),
            ('Advanced Manufacturing Credit', 8, '2023-07-10', 'None', 3, 'Lisa Anderson', 'Robert Davis'),
            ('Industrial Components Facility', 9, '2023-08-15', 'Watchlist', 3, 'John Williams', 'Michael Chen'),
            ('Precision Parts Revolver', 10, '2023-10-01', 'None', 2, 'Jennifer Martinez', 'Jennifer Mills'),
            ('Consumer Goods Term Loan', 12, '2023-11-20', 'None', 2, 'Mark Thompson', 'Sarah Johnson'),
            ('MarketPlace Solutions Credit', 13, '2023-12-15', 'None', 2, 'Lisa Anderson', 'Emily Parker'),
            ('Business Services Facility', 14, '2024-01-10', 'None', 2, 'John Williams', 'David Kim'),
            ('ACME Healthcare Expansion', 2, '2024-02-01', 'None', 2, 'Jennifer Martinez', 'Robert Davis'),
            ('Telecommunications Loan', 19, '2024-02-20', 'Watchlist', 3, 'Mark Thompson', 'Michael Chen'),
            ('Financial Services Credit', 20, '2024-03-10', 'None', 2, 'Lisa Anderson', 'Jennifer Mills'),
            ('Summit Medical Equipment', 3, '2024-04-01', 'None', 2, 'John Williams', 'Sarah Johnson'),
            ('CyberSecure Infrastructure', 7, '2024-05-15', 'None', 2, 'Jennifer Martinez', 'Emily Parker'),
            ('Advanced Manufacturing II', 8, '2024-06-01', 'None', 3, 'Mark Thompson', 'David Kim'),
            ('RetailNext Digital', 11, '2024-07-10', 'None', 2, 'Lisa Anderson', 'Robert Davis'),
            ('Logistics Expansion', 16, '2024-08-01', 'None', 2, 'John Williams', 'Michael Chen'),
            ('Energy Solutions II', 18, '2024-09-15', 'Watchlist', 4, 'Mark Thompson', 'Jennifer Mills'),
            ('CloudTech Cloud Platform', 5, '2024-10-01', 'None', 2, 'Jennifer Martinez', 'Sarah Johnson'),
            ('DataCore AI Initiative', 6, '2024-10-20', 'None', 2, 'Lisa Anderson', 'Emily Parker')
        ) AS deal_data(deal_name, company_id, deal_date, watchlist, rating, originator, preparer)
) deals
LIMIT 42; -- Total of 50 deals (8 John Williams + 42 others)

-- ============================================================================
-- STEP 6: POPULATE DIM_ASSET
-- ============================================================================

-- Generate ~100 assets (2 per deal on average)
INSERT INTO DIM_ASSET (asset_id, asset_name, deal_id, facility_type, security_type, maturity_date)
SELECT
    asset_id,
    asset_name,
    deal_id,
    facility_type,
    security_type,
    maturity_date
FROM (
    SELECT
        (d.deal_id - 1) * 2 + a.asset_num AS asset_id,
        d.deal_name || ' - ' || a.facility_type AS asset_name,
        d.deal_id,
        a.facility_type,
        a.security_type,
        DATEADD(year, 5, d.deal_date) AS maturity_date
    FROM (
        SELECT deal_id, deal_name, deal_date FROM DIM_DEAL
    ) d
    CROSS JOIN (
        SELECT * FROM VALUES
            (1, 'Term Loan A', 'First Lien'),
            (2, 'Revolver', 'First Lien')
    ) AS a(asset_num, facility_type, security_type)
    
    UNION ALL
    
    -- Add some Second Lien and Delayed Draw facilities
    SELECT
        100 + SEQ4() AS asset_id,
        deals.deal_name || ' - ' || facilities.facility_type AS asset_name,
        deals.deal_id,
        facilities.facility_type,
        facilities.security_type,
        DATEADD(year, 6, deals.deal_date) AS maturity_date
    FROM (
        SELECT deal_id, deal_name, deal_date 
        FROM DIM_DEAL 
        WHERE MOD(deal_id, 5) = 0  -- Every 5th deal
    ) deals
    CROSS JOIN (
        SELECT * FROM VALUES
            ('Second Lien', 'Second Lien'),
            ('Delayed Draw', 'First Lien')
    ) AS facilities(facility_type, security_type)
    LIMIT 20
);

-- ============================================================================
-- STEP 7: POPULATE FACT_POSITION_SNAPSHOT
-- ============================================================================

-- Generate snapshots for:
-- 1. All month-end dates from Jan 2024 to current month
-- 2. March 31, 2024 (explicitly required)
-- 3. Current date

INSERT INTO FACT_POSITION_SNAPSHOT
SELECT
    ROW_NUMBER() OVER (ORDER BY snap_dates.date_key, assets.asset_id) AS snapshot_fact_id,
    snap_dates.date_key AS date_id,
    companies.company_id,
    deals.deal_id,
    assets.asset_id,
    funds.fund_id,
    sponsors.sponsor_id,
    
    -- Financial measures with realistic values
    -- Exposure: $1M to $50M
    ROUND(1000000 + UNIFORM(0, 49000000, RANDOM()), 2) * 
        (1 + (snap_dates.months_since_start * 0.01)) AS exposure,  -- Grows slightly over time
    
    -- Commitment: Varies ±10-20% from exposure
    ROUND((1000000 + UNIFORM(0, 49000000, RANDOM())) * 
        (1 + UNIFORM(-0.20, 0.20, RANDOM())), 2) AS commitment,
    
    -- Fair value: 95%-105% of exposure
    ROUND((1000000 + UNIFORM(0, 49000000, RANDOM())) * 
        UNIFORM(0.95, 1.05, RANDOM()), 2) AS fair_value,
    
    -- Funded par: 60-90% of exposure
    ROUND((1000000 + UNIFORM(0, 49000000, RANDOM())) * 
        UNIFORM(0.60, 0.90, RANDOM()), 2) AS funded_par,
    
    -- Unfunded par: remainder of commitment
    ROUND((1000000 + UNIFORM(0, 49000000, RANDOM())) * 
        UNIFORM(0.10, 0.40, RANDOM()), 2) AS unfunded_par,
    
    -- Cost: close to par
    ROUND((1000000 + UNIFORM(0, 49000000, RANDOM())) * 
        UNIFORM(0.98, 1.02, RANDOM()), 2) AS cost,
    
    -- Mark: 0.98 to 1.02 (par = 1.0000)
    ROUND(UNIFORM(0.98, 1.02, RANDOM()), 4) AS mark

FROM (
    -- Get all month-end dates from Jan 2024 to current month + March 31 + current date
    SELECT DISTINCT
        date_key,
        DATEDIFF(month, '2024-01-01', calendar_date) AS months_since_start
    FROM DIM_DATE
    WHERE (
        (is_month_end = TRUE AND calendar_date >= '2024-01-01' AND calendar_date <= CURRENT_DATE())
        OR calendar_date = '2024-03-31'  -- Explicitly include March 31
        OR calendar_date = CURRENT_DATE()  -- Current date
    )
) snap_dates
CROSS JOIN (
    SELECT asset_id, deal_id FROM DIM_ASSET LIMIT 100
) assets
INNER JOIN DIM_DEAL deals ON assets.deal_id = deals.deal_id
INNER JOIN DIM_COMPANY companies ON deals.company_id = companies.company_id
CROSS JOIN (
    SELECT fund_id FROM DIM_FUND ORDER BY RANDOM() LIMIT 1
) funds
CROSS JOIN (
    SELECT sponsor_id FROM DIM_SPONSOR ORDER BY RANDOM() LIMIT 1
) sponsors;

-- ============================================================================
-- VALIDATION QUERIES
-- ============================================================================

-- Show row counts for all tables
SELECT 'DIM_DATE' AS table_name, COUNT(*) AS row_count FROM DIM_DATE
UNION ALL
SELECT 'DIM_COMPANY', COUNT(*) FROM DIM_COMPANY
UNION ALL
SELECT 'DIM_SPONSOR', COUNT(*) FROM DIM_SPONSOR
UNION ALL
SELECT 'DIM_FUND', COUNT(*) FROM DIM_FUND
UNION ALL
SELECT 'DIM_DEAL', COUNT(*) FROM DIM_DEAL
UNION ALL
SELECT 'DIM_ASSET', COUNT(*) FROM DIM_ASSET
UNION ALL
SELECT 'FACT_POSITION_SNAPSHOT', COUNT(*) FROM FACT_POSITION_SNAPSHOT
ORDER BY table_name;

-- Verify required entities exist
SELECT 'HealthTech Solutions Check' AS validation_check, COUNT(*) AS count
FROM DIM_COMPANY WHERE company_name = 'HealthTech Solutions'
UNION ALL
SELECT 'ACME Fund Check', COUNT(*)
FROM DIM_FUND WHERE fund_family = 'ACME'
UNION ALL
SELECT 'John Williams Deals', COUNT(*)
FROM DIM_DEAL WHERE originator1 = 'John Williams'
UNION ALL
SELECT 'John Williams Watchlist Deals', COUNT(*)
FROM DIM_DEAL WHERE originator1 = 'John Williams' AND watchlist IN ('Watchlist', 'Intensive Care')
UNION ALL
SELECT 'March 31 2024 Snapshot', COUNT(*)
FROM FACT_POSITION_SNAPSHOT f
JOIN DIM_DATE d ON f.date_id = d.date_key
WHERE d.calendar_date = '2024-03-31';
