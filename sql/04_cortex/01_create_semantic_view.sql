/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 04_cortex/01_create_semantic_view.sql
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Create semantic view over credit portfolio star schema enabling natural
 *   language queries for deals, exposures, commitments, and portfolio analysis.
 *
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_CREDIT_PORTFOLIO_OVERVIEW
 *
 * VERIFIED QUERIES (6 business questions):
 *   1. Financial metrics for HealthTech Solutions
 *   2. John Williams's deals in the watchlist
 *   3. Deals with commitment changes >2% (March 31 vs current)
 *   4. Monthly exposure totals for current year
 *   5. Total deal count for ACME
 *   6. Top 10 deals by fair value
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS;

CREATE OR REPLACE SEMANTIC VIEW SV_CREDIT_PORTFOLIO_OVERVIEW
TABLES (
  facts AS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT
    PRIMARY KEY (snapshot_fact_id)
    WITH SYNONYMS = ('positions', 'portfolio snapshots', 'holdings')
    COMMENT = 'Daily portfolio position snapshots with financial metrics',
  
  companies AS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY
    PRIMARY KEY (company_id)
    WITH SYNONYMS = ('issuers', 'borrowers', 'portfolio companies', 'credits')
    COMMENT = 'Portfolio companies receiving credit facilities',
  
  deals AS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL
    PRIMARY KEY (deal_id)
    WITH SYNONYMS = ('transactions', 'credit facilities', 'loans', 'facilities')
    COMMENT = 'Credit deal transactions and characteristics',
  
  assets AS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_ASSET
    PRIMARY KEY (asset_id)
    WITH SYNONYMS = ('securities', 'instruments', 'tranches')
    COMMENT = 'Individual assets within deals',
  
  funds AS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_FUND
    PRIMARY KEY (fund_id)
    WITH SYNONYMS = ('investment funds', 'vehicles', 'fund vehicles')
    COMMENT = 'Investment funds holding positions',
  
  sponsors AS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_SPONSOR
    PRIMARY KEY (sponsor_id)
    WITH SYNONYMS = ('PE firms', 'private equity', 'financial sponsors')
    COMMENT = 'Private equity sponsors backing companies',
  
  dates AS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE
    PRIMARY KEY (date_key)
    WITH SYNONYMS = ('calendar', 'time dimension')
    COMMENT = 'Date dimension for time-based analysis'
)

RELATIONSHIPS (
  facts(company_id) REFERENCES companies(company_id),
  facts(deal_id) REFERENCES deals(deal_id),
  facts(asset_id) REFERENCES assets(asset_id),
  facts(fund_id) REFERENCES funds(fund_id),
  facts(sponsor_id) REFERENCES sponsors(sponsor_id),
  facts(date_id) REFERENCES dates(date_key)
)

FACTS (
  facts.exposure AS exposure
    WITH SYNONYMS = ('total exposure', 'risk exposure', 'exposure amount', 'exposure USD')
    COMMENT = 'Total exposure amount in USD. Aggregate via SUM to get total portfolio exposure.',
  
  facts.commitment AS commitment
    WITH SYNONYMS = ('committed amount', 'commitment amount', 'committed capital')
    COMMENT = 'Committed capital amount in USD. Aggregate via SUM to get total commitments.',
  
  facts.fair_value AS fair_value
    WITH SYNONYMS = ('FV', 'market value', 'valuation', 'fair value USD')
    COMMENT = 'Fair value of position in USD. Aggregate via SUM to get total portfolio value.',
  
  facts.funded_par AS funded_par
    WITH SYNONYMS = ('drawn amount', 'outstanding balance', 'funded amount')
    COMMENT = 'Funded par value in USD. Aggregate via SUM to get total funded positions.',
  
  facts.unfunded_par AS unfunded_par
    WITH SYNONYMS = ('undrawn commitment', 'available capacity', 'unfunded commitment')
    COMMENT = 'Unfunded commitment amount in USD. Aggregate via SUM to get total available capacity.',
  
  facts.cost AS cost
    WITH SYNONYMS = ('cost basis', 'original cost', 'investment cost')
    COMMENT = 'Cost basis of position in USD. Aggregate via SUM to get total investment cost.',
  
  facts.mark AS mark
    WITH SYNONYMS = ('pricing mark', 'price', 'valuation mark', 'mark to market')
    COMMENT = 'Pricing mark as decimal (1.0000 = par). Aggregate via AVG to get portfolio average mark.'
)

DIMENSIONS (
  -- Company dimensions
  companies.company_name AS company_name
    WITH SYNONYMS = ('company', 'issuer name', 'borrower name', 'credit name', 'portfolio company name')
    COMMENT = 'Name of the portfolio company or issuer (e.g., HealthTech Solutions)',
  
  companies.industry AS industry
    WITH SYNONYMS = ('sector', 'industry group', 'vertical', 'industry classification')
    COMMENT = 'Industry classification of the company',
  
  companies.region AS region
    WITH SYNONYMS = ('geography', 'location', 'geographic region')
    COMMENT = 'Geographic region of company headquarters',
  
  -- Deal dimensions
  deals.deal_name AS deal_name
    WITH SYNONYMS = ('deal', 'transaction name', 'facility name', 'credit name')
    COMMENT = 'Name of the credit deal or transaction',
  
  deals.watchlist AS watchlist
    WITH SYNONYMS = ('watch list', 'monitoring list', 'problem credits', 'watchlist status', 'risk status')
    COMMENT = 'Watchlist status indicating elevated monitoring: None, Watchlist, or Intensive Care',
  
  deals.rating AS rating
    WITH SYNONYMS = ('credit rating', 'risk rating', 'grade', 'internal rating')
    COMMENT = 'Internal credit rating from 1 (best) to 5 (worst)',
  
  deals.originator1 AS originator1
    WITH SYNONYMS = ('originator', 'deal originator', 'relationship manager', 'RM')
    COMMENT = 'Primary originator of the deal (e.g., John Williams, Jennifer Martinez)',
  
  deals.preparer AS preparer
    WITH SYNONYMS = ('deal preparer', 'analyst', 'prepared by')
    COMMENT = 'Person who prepared the deal documentation',
  
  deals.deal_date AS deal_date
    WITH SYNONYMS = ('origination date', 'deal origination date', 'transaction date')
    COMMENT = 'Date the deal was originated',
  
  -- Asset dimensions
  assets.asset_name AS asset_name
    WITH SYNONYMS = ('facility name', 'instrument name', 'security name')
    COMMENT = 'Name of the individual asset or facility',
  
  assets.facility_type AS facility_type
    WITH SYNONYMS = ('loan type', 'facility', 'product type')
    COMMENT = 'Type of facility: Term Loan, Revolver, Second Lien, Delayed Draw',
  
  assets.security_type AS security_type
    WITH SYNONYMS = ('lien type', 'security', 'collateral type')
    COMMENT = 'Security classification: First Lien, Second Lien, Unitranche, Unsecured',
  
  -- Fund dimensions
  funds.fund_name AS fund_name
    WITH SYNONYMS = ('fund', 'investment fund name', 'vehicle name')
    COMMENT = 'Name of the investment fund',
  
  funds.fund_family AS fund_family
    WITH SYNONYMS = ('fund group', 'fund sponsor', 'ACME', 'fund family name')
    COMMENT = 'Fund family or sponsor group (e.g., ACME, Summit Credit)',
  
  funds.strategy_type AS strategy_type
    WITH SYNONYMS = ('fund strategy', 'investment strategy', 'strategy')
    COMMENT = 'Investment strategy: Direct Lending, Opportunistic, Core+, Mezzanine',
  
  -- Sponsor dimensions
  sponsors.sponsor_name AS sponsor_name
    WITH SYNONYMS = ('PE firm name', 'sponsor', 'financial sponsor name')
    COMMENT = 'Name of the private equity sponsor',
  
  -- Date dimensions
  dates.calendar_date AS calendar_date
    WITH SYNONYMS = ('date', 'as of date', 'snapshot date', 'reporting date')
    COMMENT = 'Calendar date of the position snapshot',
  
  dates.month_end_date AS month_end_date
    WITH SYNONYMS = ('month end', 'period end', 'month-end date')
    COMMENT = 'Last day of the month for period reporting',
  
  dates.is_month_end AS is_month_end
    WITH SYNONYMS = ('month end flag', 'period end flag')
    COMMENT = 'TRUE if this date is a month-end date',
  
  dates.year AS year
    WITH SYNONYMS = ('calendar year')
    COMMENT = 'Calendar year',
  
  dates.quarter AS quarter
    WITH SYNONYMS = ('fiscal quarter', 'calendar quarter')
    COMMENT = 'Calendar quarter (1-4)',
  
  dates.month AS month
    WITH SYNONYMS = ('calendar month', 'month number')
    COMMENT = 'Calendar month (1-12)'
)

METRICS (
  facts.total_exposure AS SUM(exposure)
    WITH SYNONYMS = ('aggregate exposure', 'portfolio exposure', 'sum of exposure')
    COMMENT = 'Total exposure across selected positions. Calculated as sum of EXPOSURE.',
  
  facts.total_commitment AS SUM(commitment)
    WITH SYNONYMS = ('aggregate commitment', 'total committed capital', 'sum of commitments')
    COMMENT = 'Total committed capital across selected positions. Calculated as sum of COMMITMENT.',
  
  facts.total_fair_value AS SUM(fair_value)
    WITH SYNONYMS = ('aggregate fair value', 'portfolio value', 'total value')
    COMMENT = 'Total fair value across selected positions. Calculated as sum of FAIR_VALUE.',
  
  facts.total_funded_par AS SUM(funded_par)
    WITH SYNONYMS = ('aggregate funded', 'total funded', 'total drawn')
    COMMENT = 'Total funded par across selected positions. Calculated as sum of FUNDED_PAR.',
  
  facts.total_unfunded_par AS SUM(unfunded_par)
    WITH SYNONYMS = ('aggregate unfunded', 'total unfunded', 'total available')
    COMMENT = 'Total unfunded par across selected positions. Calculated as sum of UNFUNDED_PAR.',
  
  facts.deal_count AS COUNT(DISTINCT deal_id)
    WITH SYNONYMS = ('number of deals', 'transaction count', 'count of deals')
    COMMENT = 'Count of distinct deals. Calculated as COUNT(DISTINCT DEAL_ID).',
  
  facts.company_count AS COUNT(DISTINCT company_id)
    WITH SYNONYMS = ('number of companies', 'issuer count', 'count of companies')
    COMMENT = 'Count of distinct companies. Calculated as COUNT(DISTINCT COMPANY_ID).',
  
  facts.average_mark AS AVG(mark)
    WITH SYNONYMS = ('average price', 'mean mark', 'avg pricing')
    COMMENT = 'Average pricing mark. Calculated as AVG(MARK).',
  
  facts.average_exposure AS AVG(exposure)
    WITH SYNONYMS = ('mean exposure', 'avg exposure per position')
    COMMENT = 'Average exposure per position. Calculated as AVG(EXPOSURE).'
)
COMMENT = 'Semantic view for credit portfolio management enabling natural language queries about deals, exposures, commitments, companies, and portfolio composition. Supports queries for HealthTech Solutions metrics, originator deal analysis, ACME fund analysis, and commitment change tracking.';

/*******************************************************************************
 * VERIFIED QUERIES
 * These queries validate the semantic view structure and map to the 6
 * business questions. Execute these after deployment to confirm data quality.
 ******************************************************************************/

-- Query 1: Financial metrics for HealthTech Solutions
-- Business Question: "Create a table of financial metrics for HealthTech Solutions"
-- Expected: Exposure, commitment, fair value for HealthTech Solutions across all dates
SELECT
    d.calendar_date,
    c.company_name,
    SUM(f.exposure) AS total_exposure,
    SUM(f.commitment) AS total_commitment,
    SUM(f.fair_value) AS total_fair_value,
    AVG(f.mark) AS average_mark
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY c ON f.company_id = c.company_id
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
WHERE c.company_name = 'HealthTech Solutions'
  AND d.is_month_end = TRUE
  AND d.calendar_date >= '2024-01-01'
GROUP BY d.calendar_date, c.company_name
ORDER BY d.calendar_date DESC
LIMIT 12;

-- Query 2: John Williams's deals in the watchlist
-- Business Question: "Show me all of John Williams's deals in the watchlist"
-- Expected: 2-3 deals where originator1='John Williams' AND watchlist IN ('Watchlist', 'Intensive Care')
SELECT
    deal_name,
    watchlist,
    rating,
    originator1,
    deal_date,
    c.company_name
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL d
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY c ON d.company_id = c.company_id
WHERE d.originator1 = 'John Williams'
  AND d.watchlist IN ('Watchlist', 'Intensive Care')
ORDER BY d.deal_date DESC;

-- Query 3: Deals with commitment changes >2% between March 31 and current
-- Business Question: "List deals where commitment changed more than 2% between now and March 31st"
-- Expected: Deals showing meaningful commitment variance
WITH march_commitments AS (
    SELECT
        deal_id,
        SUM(commitment) AS march_commitment
    FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
    JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
    WHERE d.calendar_date = '2024-03-31'
    GROUP BY deal_id
),
current_commitments AS (
    SELECT
        deal_id,
        SUM(commitment) AS current_commitment
    FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
    JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
    WHERE d.calendar_date = CURRENT_DATE()
    GROUP BY deal_id
)
SELECT
    deals.deal_name,
    companies.company_name,
    march.march_commitment,
    curr.current_commitment,
    curr.current_commitment - march.march_commitment AS commitment_change,
    ROUND(((curr.current_commitment - march.march_commitment) / march.march_commitment) * 100, 2) AS pct_change
FROM march_commitments march
JOIN current_commitments curr ON march.deal_id = curr.deal_id
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL deals ON march.deal_id = deals.deal_id
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY companies ON deals.company_id = companies.company_id
WHERE ABS(((curr.current_commitment - march.march_commitment) / march.march_commitment)) > 0.02
ORDER BY ABS(pct_change) DESC
LIMIT 20;

-- Query 4: Monthly exposure totals for current year
-- Business Question: "For each month-end starting from the beginning of the current year, what is the total exposure?"
-- Expected: 12 rows (or current month count) showing monthly exposure trend
SELECT
    d.month_end_date,
    d.year,
    d.month,
    SUM(f.exposure) AS total_exposure,
    COUNT(DISTINCT f.deal_id) AS deal_count
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
WHERE d.is_month_end = TRUE
  AND d.year = YEAR(CURRENT_DATE())
GROUP BY d.month_end_date, d.year, d.month
ORDER BY d.month_end_date;

-- Query 5: Total count of deals for ACME
-- Business Question: "Total count of deals for ACME"
-- Expected: Count of distinct deals associated with ACME fund family
SELECT
    funds.fund_family,
    COUNT(DISTINCT f.deal_id) AS deal_count,
    SUM(f.exposure) AS total_exposure,
    SUM(f.fair_value) AS total_fair_value
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_FUND funds ON f.fund_id = funds.fund_id
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
WHERE funds.fund_family = 'ACME'
  AND d.calendar_date = CURRENT_DATE()
GROUP BY funds.fund_family;

-- Query 6: Top 10 deals by fair value
-- Business Question: "What is the total fair value for top 10 deals"
-- Expected: Top 10 deals ranked by total fair value
SELECT
    deals.deal_name,
    companies.company_name,
    SUM(f.fair_value) AS total_fair_value,
    SUM(f.exposure) AS total_exposure,
    AVG(f.mark) AS average_mark,
    deals.rating,
    deals.watchlist
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL deals ON f.deal_id = deals.deal_id
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY companies ON deals.company_id = companies.company_id
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
WHERE d.calendar_date = CURRENT_DATE()
GROUP BY deals.deal_name, companies.company_name, deals.rating, deals.watchlist
ORDER BY total_fair_value DESC
LIMIT 10;
