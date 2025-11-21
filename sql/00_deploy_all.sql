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
 *   - Semantic view for Cortex Analyst
 *   - Cortex Agent for natural language queries
 *   - Streamlit dashboard
 *
 * WHAT GETS CREATED:
 *   - Database: SNOWFLAKE_EXAMPLE (if not exists)
 *   - Schemas: SFE_ANALYTICS_CREDIT, SEMANTIC_MODELS
 *   - Warehouse: SFE_CREDIT_PORTFOLIO_WH (X-SMALL)
 *   - Dimensions: DIM_DATE, DIM_COMPANY, DIM_DEAL, DIM_ASSET, DIM_FUND, DIM_SPONSOR
 *   - Fact: FACT_POSITION_SNAPSHOT
 *   - Semantic View: SV_CREDIT_PORTFOLIO_OVERVIEW
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
-- PHASE 1: Git Integration Setup
-- ============================================================================

-- Create Git repositories schema if not exists
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.GIT_REPOS
  COMMENT = 'DEMO: Shared Git repository storage for demos';

-- Create API integration for GitHub access
CREATE OR REPLACE API INTEGRATION SFE_CAPITOLKINGS_GIT_API_INTEGRATION
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = (
      'https://github.com/sfc-gh-miwhitaker/CapitolKings',
      'https://github.com/sfc-gh-miwhitaker/CapitolKings.git'
  )
  ENABLED = TRUE
  COMMENT = 'DEMO: credit-portfolio - Git access for Capitol Kings repository';

-- Create Git repository and fetch latest
CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO
  API_INTEGRATION = SFE_CAPITOLKINGS_GIT_API_INTEGRATION
  ORIGIN = 'https://github.com/sfc-gh-miwhitaker/CapitolKings.git'
  COMMENT = 'DEMO: credit-portfolio - Capitol Kings repo mirror';

ALTER GIT REPOSITORY SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO FETCH;

SELECT '✅ Git integration configured and repository fetched' AS phase_1_status;

-- ============================================================================
-- PHASE 2: Foundation Setup (Database, Schemas, Warehouse)
-- ============================================================================

-- Create database (if not exists)
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/01_setup/01_create_database.sql;

-- Create schemas for star schema and semantic models
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/01_setup/02_create_schemas.sql;

-- Create dedicated warehouse
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/01_setup/03_create_warehouse.sql;

-- Set context for remaining operations
USE WAREHOUSE SFE_CREDIT_PORTFOLIO_WH;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SFE_ANALYTICS_CREDIT;

SELECT '✅ Foundation setup complete (database, schemas, warehouse)' AS phase_2_status;

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
