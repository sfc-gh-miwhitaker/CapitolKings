/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 99_cleanup/teardown_all.sql
 *
 * PURPOSE:
 *   Remove all credit portfolio demo artifacts while preserving shared
 *   infrastructure that may be used by other demos.
 *
 * PROTECTED INFRASTRUCTURE (DO NOT DROP):
 *   - SNOWFLAKE_EXAMPLE database itself (shared across demos)
 *   - SNOWFLAKE_EXAMPLE.GIT_REPOS schema (shared Git repositories)
 *   - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS schema (shared semantic views - only drop our view)
 *   - All SFE_* API integrations (if shared by other demos)
 *
 * CLEANUP ORDER:
 *   1. Application layer (Streamlit, Agents)
 *   2. Semantic views (our view only)
 *   3. Views and helper objects
 *   4. Star schema tables (dimensions and facts)
 *   5. Schemas (CASCADE to catch any remaining objects)
 *   6. Dedicated warehouse
 *
 * Re-run this script until it succeeds; statements are idempotent.
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;

-- ============================================================================
-- LAYER 1: Application Components
-- ============================================================================

-- Drop Streamlit app
DROP STREAMLIT IF EXISTS SFE_ANALYTICS_CREDIT.SFE_CREDIT_PORTFOLIO_APP;

-- Drop Cortex Agent
DROP AGENT IF EXISTS snowflake_intelligence.agents.CREDIT_PORTFOLIO_ANALYST;

-- ============================================================================
-- LAYER 2: Semantic Views (our view only, preserve schema)
-- ============================================================================

DROP SEMANTIC VIEW IF EXISTS SEMANTIC_MODELS.SV_CREDIT_PORTFOLIO_OVERVIEW;

-- ============================================================================
-- LAYER 3: Helper Views
-- ============================================================================

DROP VIEW IF EXISTS SFE_ANALYTICS_CREDIT.V_CURRENT_PORTFOLIO_SUMMARY;
DROP VIEW IF EXISTS SFE_ANALYTICS_CREDIT.V_WATCHLIST_DEALS;
DROP VIEW IF EXISTS SFE_ANALYTICS_CREDIT.V_MONTHLY_EXPOSURE_TRENDS;

-- ============================================================================
-- LAYER 4: Star Schema Tables (Dimensions and Facts)
-- ============================================================================

-- Drop fact table
DROP TABLE IF EXISTS SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT;

-- Drop dimension tables
DROP TABLE IF EXISTS SFE_ANALYTICS_CREDIT.DIM_DATE;
DROP TABLE IF EXISTS SFE_ANALYTICS_CREDIT.DIM_COMPANY;
DROP TABLE IF EXISTS SFE_ANALYTICS_CREDIT.DIM_DEAL;
DROP TABLE IF EXISTS SFE_ANALYTICS_CREDIT.DIM_ASSET;
DROP TABLE IF EXISTS SFE_ANALYTICS_CREDIT.DIM_FUND;
DROP TABLE IF EXISTS SFE_ANALYTICS_CREDIT.DIM_SPONSOR;

-- ============================================================================
-- LAYER 5: Schemas (CASCADE to ensure complete cleanup)
-- ============================================================================

DROP SCHEMA IF EXISTS SFE_ANALYTICS_CREDIT CASCADE;

-- ============================================================================
-- LAYER 6: Dedicated Warehouse
-- ============================================================================

DROP WAREHOUSE IF EXISTS SFE_CREDIT_PORTFOLIO_WH;

-- ============================================================================
-- PROTECTED INFRASTRUCTURE (NOT DROPPED)
-- ============================================================================

-- ✓ SNOWFLAKE_EXAMPLE database (preserved for other demos)
-- ✓ SNOWFLAKE_EXAMPLE.GIT_REPOS schema (shared Git repositories)
-- ✓ SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS schema (shared, only our view dropped)
-- ✓ SFE_* API integrations (if shared by other demos)

-- ============================================================================
-- VALIDATION
-- ============================================================================

-- Verify cleanup completed
SELECT 'Credit Portfolio Demo Cleanup Complete' AS status;

-- Check for any remaining objects (should return no rows)
SHOW TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT;
