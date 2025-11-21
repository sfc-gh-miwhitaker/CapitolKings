/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 05_streamlit/01_create_streamlit.sql
 *
 * PURPOSE:
 *   Deploy the Streamlit in Snowflake app that visualizes credit portfolio
 *   metrics from the star schema dimensional model.
 *
 * OBJECTS CREATED:
 *   - SFE_CREDIT_PORTFOLIO_APP (Streamlit app)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SFE_ANALYTICS_CREDIT;

CREATE OR REPLACE STREAMLIT SFE_CREDIT_PORTFOLIO_APP
  ROOT_LOCATION = '@SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/05_streamlit/app'
  MAIN_FILE = 'app.py'
  QUERY_WAREHOUSE = SFE_CREDIT_PORTFOLIO_WH
  COMMENT = 'DEMO: credit-portfolio - Streamlit dashboard for credit portfolio analytics | Author: SE Community | Expires: 2025-12-21';
