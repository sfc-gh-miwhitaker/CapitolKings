/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 03_transformations/03_create_views.sql
 *
 * PURPOSE:
 *   Create helper views over the star schema for common analytical patterns.
 *   These views simplify queries for applications while maintaining single
 *   source of truth in the dimensional model.
 *
 * OBJECTS CREATED:
 *   - V_CURRENT_PORTFOLIO_SUMMARY
 *   - V_WATCHLIST_DEALS
 *   - V_MONTHLY_EXPOSURE_TRENDS
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SFE_ANALYTICS_CREDIT;

-- View 1: Current Portfolio Summary
-- Provides latest snapshot metrics for all positions
CREATE OR REPLACE VIEW V_CURRENT_PORTFOLIO_SUMMARY
COMMENT = 'DEMO: credit-portfolio - Current portfolio positions with latest metrics | Author: SE Community | Expires: 2025-12-21'
AS
SELECT
    companies.company_name,
    deals.deal_name,
    deals.watchlist,
    deals.rating,
    deals.originator1,
    funds.fund_name,
    funds.fund_family,
    SUM(f.exposure) AS total_exposure,
    SUM(f.commitment) AS total_commitment,
    SUM(f.fair_value) AS total_fair_value,
    AVG(f.mark) AS average_mark,
    dates.calendar_date AS as_of_date
FROM FACT_POSITION_SNAPSHOT f
JOIN DIM_COMPANY companies ON f.company_id = companies.company_id
JOIN DIM_DEAL deals ON f.deal_id = deals.deal_id
JOIN DIM_FUND funds ON f.fund_id = funds.fund_id
JOIN DIM_DATE dates ON f.date_id = dates.date_key
WHERE dates.calendar_date = CURRENT_DATE()
GROUP BY 
    companies.company_name,
    deals.deal_name,
    deals.watchlist,
    deals.rating,
    deals.originator1,
    funds.fund_name,
    funds.fund_family,
    dates.calendar_date;

-- View 2: Watchlist Deals
-- Quick access to deals requiring elevated monitoring
CREATE OR REPLACE VIEW V_WATCHLIST_DEALS
COMMENT = 'DEMO: credit-portfolio - Deals on watchlist or intensive care status | Author: SE Community | Expires: 2025-12-21'
AS
SELECT
    deals.deal_name,
    companies.company_name,
    deals.watchlist,
    deals.rating,
    deals.originator1,
    deals.deal_date,
    SUM(f.exposure) AS total_exposure,
    SUM(f.commitment) AS total_commitment,
    AVG(f.mark) AS average_mark
FROM FACT_POSITION_SNAPSHOT f
JOIN DIM_DEAL deals ON f.deal_id = deals.deal_id
JOIN DIM_COMPANY companies ON f.company_id = companies.company_id
JOIN DIM_DATE dates ON f.date_id = dates.date_key
WHERE deals.watchlist IN ('Watchlist', 'Intensive Care')
  AND dates.calendar_date = CURRENT_DATE()
GROUP BY 
    deals.deal_name,
    companies.company_name,
    deals.watchlist,
    deals.rating,
    deals.originator1,
    deals.deal_date;

-- View 3: Monthly Exposure Trends
-- Time-series view of portfolio metrics at month-end
CREATE OR REPLACE VIEW V_MONTHLY_EXPOSURE_TRENDS
COMMENT = 'DEMO: credit-portfolio - Month-end portfolio metrics for trend analysis | Author: SE Community | Expires: 2025-12-21'
AS
SELECT
    dates.month_end_date,
    dates.year,
    dates.month,
    SUM(f.exposure) AS total_exposure,
    SUM(f.commitment) AS total_commitment,
    SUM(f.fair_value) AS total_fair_value,
    SUM(f.funded_par) AS total_funded_par,
    SUM(f.unfunded_par) AS total_unfunded_par,
    AVG(f.mark) AS average_mark,
    COUNT(DISTINCT f.deal_id) AS deal_count,
    COUNT(DISTINCT f.company_id) AS company_count
FROM FACT_POSITION_SNAPSHOT f
JOIN DIM_DATE dates ON f.date_id = dates.date_key
WHERE dates.is_month_end = TRUE
GROUP BY 
    dates.month_end_date,
    dates.year,
    dates.month
ORDER BY dates.month_end_date;
