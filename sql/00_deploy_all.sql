/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * HOW TO RUN IN SNOWSIGHT
 *   1. Copy/paste this entire script into a Snowsight worksheet.
 *   2. Set role to ACCOUNTADMIN.
 *   3. Click **Run All**.
 *   4. Total runtime: ~5-10 minutes on X-SMALL warehouse.
 *
 * PURPOSE:
 *   Deploy complete credit portfolio analytics demo end-to-end:
 *   - Star schema dimensional model (6 dimensions + 1 fact table)
 *   - Synthetic data with specific entities (HealthTech Solutions, ACME, John Williams)
 *   - Semantic view for Cortex Analyst (with SYSADMIN ownership)
 *   - Cortex Agent for natural language queries
 *   - Streamlit dashboard
 *
 * DEPLOYMENT ORDER:
 *   Phase 1: Database + Git integration
 *   Phase 2: Schemas + Warehouse
 *   Phase 3: Star schema tables
 *   Phase 4: Synthetic data
 *   Phase 5: Helper views
 *   Phase 6: Semantic view + Agent
 *   Phase 7: Streamlit app
 *
 * WHAT GETS CREATED:
 *   - Database: SNOWFLAKE_EXAMPLE (if not exists)
 *   - Schemas: GIT_REPOS, SFE_ANALYTICS_CREDIT, SEMANTIC_MODELS
 *   - Warehouse: SFE_CREDIT_PORTFOLIO_WH (X-SMALL)
 *   - Git: SFE_CAPITOLKINGS_REPO (code repository mirror)
 *   - Dimensions: DIM_DATE, DIM_COMPANY, DIM_DEAL, DIM_ASSET, DIM_FUND, DIM_SPONSOR
 *   - Fact: FACT_POSITION_SNAPSHOT
 *   - Semantic View: SV_CREDIT_PORTFOLIO_OVERVIEW (owned by SYSADMIN)
 *   - Agent: CREDIT_PORTFOLIO_ANALYST
 *   - Streamlit: SFE_CREDIT_PORTFOLIO_APP
 *
 * CLEANUP:
 *   Run sql/99_cleanup/teardown_all.sql to remove all demo objects
 *   (Preserves SNOWFLAKE_EXAMPLE database and shared infrastructure)
 *
 * TROUBLESHOOTING:
 *   - Git fetch fails? Verify HTTPS access to github.com and rerun Git block
 *   - Object already exists? Scripts are idempotent - safe to rerun
 *   - Warehouse errors? Ensure sufficient credits and appropriate role
 *
 * ESTIMATED COST:
 *   ~$0.50 one-time deployment (Standard Edition, X-SMALL warehouse, 10 min)
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- EXPIRATION CHECK (PUBLIC DEMO REQUIREMENT)
-- ============================================================================

-- This demo expires 30 days after publication (2025-11-21 + 30 days = 2025-12-21)
-- After expiration, Snowflake features and syntax may have changed.

SET EXPIRATION_DATE = '2025-12-21';

SELECT CASE 
  WHEN CURRENT_DATE() > TO_DATE($EXPIRATION_DATE)
  THEN '⚠️ WARNING: This demo expired on ' || $EXPIRATION_DATE || '. ' ||
       'Snowflake features and syntax may have changed since November 2025. ' ||
       'Verify syntax against current Snowflake documentation before proceeding. ' ||
       'See https://github.com/sfc-gh-miwhitaker/CapitolKings for updated versions.'
  WHEN CURRENT_DATE() = TO_DATE($EXPIRATION_DATE)
  THEN '⚠️ NOTICE: This demo expires TODAY (' || $EXPIRATION_DATE || '). ' ||
       'This may be the last day this deployment works as-is.'
  ELSE '✅ Demo is current (expires ' || $EXPIRATION_DATE || '). Proceeding with deployment...'
END AS expiration_status;

-- Note: This is a soft warning. Deployment will continue.
-- For production use, uncomment the following to block deployment after expiration:
--
-- IF (CURRENT_DATE() > TO_DATE($EXPIRATION_DATE)) THEN
--   RETURN 'ERROR: Demo expired. Deployment blocked.';
-- END IF;

-- ============================================================================
-- PHASE 1: Foundation Setup (Database First!)
-- ============================================================================

-- Create database first (required before creating any schemas)
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
  COMMENT = 'DEMO: Repository for example/demo projects - NOT FOR PRODUCTION | Author: SE Community | Expires: 2025-12-21';

-- Create Git repositories schema if not exists
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS
  COMMENT = 'DEMO: Shared Git repository storage for demos | Author: SE Community | Expires: 2025-12-21';

-- Create API integration for GitHub access
CREATE OR REPLACE API INTEGRATION SFE_CAPITOLKINGS_GIT_API_INTEGRATION
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = (
      'https://github.com/sfc-gh-miwhitaker/CapitolKings',
      'https://github.com/sfc-gh-miwhitaker/CapitolKings.git'
  )
  ENABLED = TRUE
  COMMENT = 'DEMO: credit-portfolio - Git access for Capitol Kings repository | Author: SE Community | Expires: 2025-12-21';

-- Create Git repository and fetch latest
CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO
  API_INTEGRATION = SFE_CAPITOLKINGS_GIT_API_INTEGRATION
  ORIGIN = 'https://github.com/sfc-gh-miwhitaker/CapitolKings.git'
  COMMENT = 'DEMO: credit-portfolio - Capitol Kings repo mirror | Author: SE Community | Expires: 2025-12-21';

ALTER GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO FETCH;

SELECT '✅ Foundation setup complete (database + Git integration)' AS phase_1_status;

-- ============================================================================
-- PHASE 2: Schemas and Warehouse
-- ============================================================================

-- Create schemas for star schema and semantic models
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/01_setup/02_create_schemas.sql;

-- Create dedicated warehouse
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/01_setup/03_create_warehouse.sql;

-- Set context for remaining operations
USE WAREHOUSE SFE_CREDIT_PORTFOLIO_WH;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SFE_ANALYTICS_CREDIT;

SELECT '✅ Schemas and warehouse created' AS phase_2_status;

-- ============================================================================
-- PHASE 3: Star Schema Creation (Dimensions + Fact)
-- ============================================================================

-- Create all dimension tables and fact table
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/02_data/01_create_tables.sql;

SELECT '✅ Star schema tables created (6 dimensions + 1 fact)' AS phase_3_status;

-- ============================================================================
-- PHASE 4: Data Population (Synthetic Data with Required Entities)
-- ============================================================================

-- Populate dimensions and fact with synthetic data
-- Includes: HealthTech Solutions (company), ACME (fund family), John Williams (originator)
-- Includes: March 31, 2024 snapshot for commitment change queries
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/02_data/02_load_sample_data.sql;

SELECT '✅ Synthetic data loaded (HealthTech Solutions, ACME, John Williams confirmed)' AS phase_4_status;

-- ============================================================================
-- PHASE 5: Helper Views
-- ============================================================================

-- Create convenience views over star schema
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/03_transformations/03_create_views.sql;

SELECT '✅ Helper views created' AS phase_5_status;

-- ============================================================================
-- PHASE 6: Cortex Intelligence Layer
-- ============================================================================

-- Create semantic view for Cortex Analyst
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/04_cortex/01_create_semantic_view.sql;

-- Create Cortex Agent with 6 sample questions
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/04_cortex/04_create_agent.sql;

SELECT '✅ Cortex Intelligence layer deployed (semantic view + agent)' AS phase_6_status;

-- ============================================================================
-- PHASE 7: Streamlit Dashboard
-- ============================================================================

-- Create Streamlit in Snowflake application
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/05_streamlit/01_create_streamlit.sql;

SELECT '✅ Streamlit dashboard deployed' AS phase_7_status;

-- ============================================================================
-- DEPLOYMENT COMPLETE
-- ============================================================================

SELECT '✅ Deployment complete. See docs/02-USAGE.md for next steps.' AS status;
