/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Credit Portfolio Demo
 * Script: 02_create_schemas.sql
 *
 * PURPOSE:
 *   Create schemas for credit portfolio star schema dimensional model.
 *
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT (star schema: dimensions + facts)
 *   - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS (semantic views for Cortex Analyst)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;

-- Star schema layer: Dimensions and Facts
CREATE SCHEMA IF NOT EXISTS SFE_ANALYTICS_CREDIT
  COMMENT = 'DEMO: credit-portfolio - Star schema with dimensions and facts for credit portfolio analytics';

-- Semantic views layer: Cortex Analyst models
CREATE SCHEMA IF NOT EXISTS SEMANTIC_MODELS
  COMMENT = 'DEMO: Semantic views for Cortex Analyst - shared across demos';
