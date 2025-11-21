/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 01_setup/03_create_warehouse.sql
 *
 * PURPOSE:
 *   Create dedicated warehouse for credit portfolio demo workloads.
 *
 * OBJECTS CREATED:
 *   - SFE_CREDIT_PORTFOLIO_WH (X-SMALL warehouse)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE IF NOT EXISTS SFE_CREDIT_PORTFOLIO_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'DEMO: credit-portfolio - Dedicated warehouse for credit portfolio analytics and Cortex Intelligence';

