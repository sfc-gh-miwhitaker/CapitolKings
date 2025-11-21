/*******************************************************************************
 * DEMO PROJECT: Capitol Kings Intelligence Demo
 * Script: 01_create_database.sql
 *
 * ⚠️  NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Ensure the shared SNOWFLAKE_EXAMPLE database and semantic schema exist
 *   before downstream scripts create SFE_* objects.
 *
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE (Database)
 *   - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS (Schema)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
  COMMENT = 'DEMO: Repository for Snowflake Intelligence reference implementations - NOT FOR PRODUCTION';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS
  COMMENT = 'DEMO: Semantic views for Cortex Analyst agents';
