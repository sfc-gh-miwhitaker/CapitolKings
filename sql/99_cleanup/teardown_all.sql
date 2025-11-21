/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 99_cleanup/teardown_all.sql
 *
 * PURPOSE:
 *   Remove all credit portfolio demo artifacts while preserving shared
 *   infrastructure that may be used by other demos.
 *
 * SAFETY FEATURES:
 *   - All DROP statements use IF EXISTS (no errors if objects missing)
 *   - Fully qualified object names (no USE DATABASE/SCHEMA context needed)
 *   - Safe to rerun multiple times until cleanup succeeds
 *   - Idempotent: Running twice has same effect as running once
 *
 * PROTECTED INFRASTRUCTURE (DO NOT DROP):
 *   - SNOWFLAKE_EXAMPLE database itself (shared across demos)
 *   - SNOWFLAKE_EXAMPLE.GIT_REPOS schema (shared Git repositories)
 *   - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS schema (shared semantic views - only drop our view)
 *   - SFE_CAPITOLKINGS_GIT_API_INTEGRATION (shared API integration)
 *
 * CLEANUP ORDER:
 *   1. Application layer (Streamlit, Agents)
 *   2. Semantic views (our view only)
 *   3. Views and helper objects
 *   4. Star schema tables (dimensions and facts)
 *   5. Schemas (CASCADE to catch any remaining objects)
 *   6. Dedicated warehouse
 *
 * USAGE:
 *   Copy/paste entire script into Snowsight worksheet
 *   Ensure role is ACCOUNTADMIN
 *   Click "Run All"
 ******************************************************************************/

-- Safe to rerun: All commands use IF EXISTS and fully qualified names
USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- LAYER 1: Application Components
-- ============================================================================

-- Drop Streamlit app (fully qualified name, no context needed)
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.SFE_CREDIT_PORTFOLIO_APP;

-- Drop Cortex Agent (account-level object)
DROP AGENT IF EXISTS snowflake_intelligence.agents.CREDIT_PORTFOLIO_ANALYST;

-- ============================================================================
-- LAYER 2: Semantic Views (our view only, preserve schema)
-- ============================================================================

DROP SEMANTIC VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_CREDIT_PORTFOLIO_OVERVIEW;

-- ============================================================================
-- LAYER 3: Helper Views
-- ============================================================================

DROP VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.V_CURRENT_PORTFOLIO_SUMMARY;
DROP VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.V_WATCHLIST_DEALS;
DROP VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.V_MONTHLY_EXPOSURE_TRENDS;

-- ============================================================================
-- LAYER 4: Star Schema Tables (Dimensions and Facts)
-- ============================================================================

-- Drop fact table
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT;

-- Drop dimension tables
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE;
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY;
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL;
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_ASSET;
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_FUND;
DROP TABLE IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_SPONSOR;

-- ============================================================================
-- LAYER 5: Schemas (CASCADE to ensure complete cleanup)
-- ============================================================================

DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT CASCADE;

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

-- Note: SHOW TABLES will fail if schema doesn't exist (expected after cleanup)
-- If you want to verify, check that these return no results:
-- SHOW WAREHOUSES LIKE 'SFE_CREDIT_PORTFOLIO_WH';
-- SHOW SCHEMAS LIKE 'SFE_ANALYTICS_CREDIT' IN DATABASE SNOWFLAKE_EXAMPLE;
