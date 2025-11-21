/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 02_data/01_create_tables.sql
 *
 * PURPOSE:
 *   Define star schema dimensional model for credit portfolio analytics.
 *   6 dimension tables + 1 fact table for position snapshots.
 *
 * OBJECTS CREATED:
 *   Dimensions:
 *   - SFE_ANALYTICS_CREDIT.DIM_DATE
 *   - SFE_ANALYTICS_CREDIT.DIM_COMPANY
 *   - SFE_ANALYTICS_CREDIT.DIM_DEAL
 *   - SFE_ANALYTICS_CREDIT.DIM_ASSET
 *   - SFE_ANALYTICS_CREDIT.DIM_FUND
 *   - SFE_ANALYTICS_CREDIT.DIM_SPONSOR
 *   Facts:
 *   - SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SFE_ANALYTICS_CREDIT;

-- ============================================================================
-- DIMENSION TABLES
-- ============================================================================

-- Date Dimension: Date spine with month-end flags
CREATE OR REPLACE TABLE DIM_DATE (
    date_key            NUMBER        PRIMARY KEY COMMENT 'Surrogate key: YYYYMMDD format',
    calendar_date       DATE          NOT NULL COMMENT 'Actual calendar date',
    year                NUMBER(4)     NOT NULL COMMENT 'Calendar year',
    quarter             NUMBER(1)     NOT NULL COMMENT 'Calendar quarter (1-4)',
    month               NUMBER(2)     NOT NULL COMMENT 'Calendar month (1-12)',
    day_of_month        NUMBER(2)     NOT NULL COMMENT 'Day of month (1-31)',
    month_end_date      DATE          NOT NULL COMMENT 'Last day of the month for period reporting',
    is_month_end        BOOLEAN       NOT NULL COMMENT 'TRUE if this date is a month-end date'
) COMMENT = 'DEMO: credit-portfolio - Date dimension for time-based analysis | Author: SE Community | Expires: 2025-12-21';

-- Company Dimension: Portfolio companies
CREATE OR REPLACE TABLE DIM_COMPANY (
    company_id          NUMBER        PRIMARY KEY COMMENT 'Surrogate key for company',
    company_name        VARCHAR(200)  NOT NULL COMMENT 'Name of the portfolio company (e.g., HealthTech Solutions)',
    industry            VARCHAR(100)  NOT NULL COMMENT 'Industry classification',
    region              VARCHAR(50)   NOT NULL COMMENT 'Geographic region of headquarters'
) COMMENT = 'DEMO: credit-portfolio - Portfolio companies receiving credit facilities | Author: SE Community | Expires: 2025-12-21';

-- Deal Dimension: Credit deals and transactions
CREATE OR REPLACE TABLE DIM_DEAL (
    deal_id             NUMBER        PRIMARY KEY COMMENT 'Surrogate key for deal',
    deal_name           VARCHAR(200)  NOT NULL COMMENT 'Name of the credit deal or transaction',
    company_id          NUMBER        NOT NULL COMMENT 'Foreign key to DIM_COMPANY',
    deal_date           DATE          NOT NULL COMMENT 'Date the deal was originated',
    watchlist           VARCHAR(50)   COMMENT 'Watchlist status: None, Watchlist, Intensive Care',
    rating              NUMBER(1)     COMMENT 'Internal credit rating from 1 (best) to 5 (worst)',
    originator1         VARCHAR(100)  COMMENT 'Primary originator of the deal (e.g., John Williams, Jennifer Martinez)',
    preparer            VARCHAR(100)  COMMENT 'Person who prepared the deal documentation'
) COMMENT = 'DEMO: credit-portfolio - Credit deal transactions and characteristics | Author: SE Community | Expires: 2025-12-21';

-- Asset Dimension: Individual assets within deals
CREATE OR REPLACE TABLE DIM_ASSET (
    asset_id            NUMBER        PRIMARY KEY COMMENT 'Surrogate key for asset',
    asset_name          VARCHAR(200)  NOT NULL COMMENT 'Name of the asset or facility',
    deal_id             NUMBER        NOT NULL COMMENT 'Foreign key to DIM_DEAL',
    facility_type       VARCHAR(50)   NOT NULL COMMENT 'Term Loan, Revolver, Second Lien, Delayed Draw',
    security_type       VARCHAR(50)   NOT NULL COMMENT 'First Lien, Second Lien, Unitranche, Unsecured',
    maturity_date       DATE          COMMENT 'Maturity date of the asset'
) COMMENT = 'DEMO: credit-portfolio - Individual assets and facilities within deals | Author: SE Community | Expires: 2025-12-21';

-- Fund Dimension: Investment funds
CREATE OR REPLACE TABLE DIM_FUND (
    fund_id             NUMBER        PRIMARY KEY COMMENT 'Surrogate key for fund',
    fund_name           VARCHAR(200)  NOT NULL COMMENT 'Name of the investment fund',
    fund_family         VARCHAR(100)  COMMENT 'Fund family or sponsor group (e.g., ACME)',
    strategy_type       VARCHAR(100)  NOT NULL COMMENT 'Direct Lending, Opportunistic, Core+, Mezzanine',
    vintage_year        NUMBER(4)     COMMENT 'Year the fund was established'
) COMMENT = 'DEMO: credit-portfolio - Investment funds holding portfolio positions | Author: SE Community | Expires: 2025-12-21';

-- Sponsor Dimension: Private equity sponsors
CREATE OR REPLACE TABLE DIM_SPONSOR (
    sponsor_id          NUMBER        PRIMARY KEY COMMENT 'Surrogate key for sponsor',
    sponsor_name        VARCHAR(200)  NOT NULL COMMENT 'Name of the private equity sponsor',
    sponsor_type        VARCHAR(50)   COMMENT 'Type of sponsor: Mega-cap, Large-cap, Mid-market, Small-cap'
) COMMENT = 'DEMO: credit-portfolio - Private equity sponsors backing portfolio companies | Author: SE Community | Expires: 2025-12-21';

-- ============================================================================
-- FACT TABLE
-- ============================================================================

-- Position Snapshot Fact: Daily portfolio position snapshots
CREATE OR REPLACE TABLE FACT_POSITION_SNAPSHOT (
    snapshot_fact_id    NUMBER        PRIMARY KEY COMMENT 'Surrogate key for fact record',
    date_id             NUMBER        NOT NULL COMMENT 'Foreign key to DIM_DATE',
    company_id          NUMBER        NOT NULL COMMENT 'Foreign key to DIM_COMPANY',
    deal_id             NUMBER        NOT NULL COMMENT 'Foreign key to DIM_DEAL',
    asset_id            NUMBER        NOT NULL COMMENT 'Foreign key to DIM_ASSET',
    fund_id             NUMBER        NOT NULL COMMENT 'Foreign key to DIM_FUND',
    sponsor_id          NUMBER        NOT NULL COMMENT 'Foreign key to DIM_SPONSOR',
    
    -- Financial measures
    exposure            NUMBER(15,2)  NOT NULL COMMENT 'Total exposure amount in USD',
    commitment          NUMBER(15,2)  NOT NULL COMMENT 'Committed capital amount in USD',
    fair_value          NUMBER(15,2)  NOT NULL COMMENT 'Fair value of position in USD',
    funded_par          NUMBER(15,2)  NOT NULL COMMENT 'Funded par value in USD',
    unfunded_par        NUMBER(15,2)  NOT NULL COMMENT 'Unfunded commitment amount in USD',
    cost                NUMBER(15,2)  COMMENT 'Cost basis in USD',
    mark                NUMBER(6,4)   COMMENT 'Pricing mark as decimal (e.g., 1.0000 = par)'
) COMMENT = 'DEMO: credit-portfolio - Daily portfolio position snapshots with financial metrics | Author: SE Community | Expires: 2025-12-21';
