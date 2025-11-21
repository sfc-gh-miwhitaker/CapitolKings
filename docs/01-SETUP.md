# 01 – Setup Checklist

## Goal
Prepare your Snowflake account for the Capitol Kings Intelligence demo: confirm required roles, enable Git access, and verify Snowsight + Streamlit permissions.

## Prerequisites
- Snowflake role with `ACCOUNTADMIN` or equivalent privileges to create `SFE_*` integrations, warehouses, and schemas inside `SNOWFLAKE_EXAMPLE`.
- Ability to run Snowsight worksheets and Streamlit apps in the desired region.
- Public network egress to `https://github.com/sfc-gh-miwhitaker/CapitolKings` (for Git repository stage pulls).
- Optional: accept the Snowflake Anaconda terms so the Streamlit app can use default packages.

## Steps
1. **Confirm database policy**  
   - Run `SHOW DATABASES LIKE 'SNOWFLAKE_EXAMPLE';` and ensure it exists (this repo never drops it).  
   - If the database is missing, create it once:  
     ```sql
     CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE COMMENT = 'DEMO: Repository for Snowflake Intelligence reference apps';
     ```
2. **Validate roles & network**  
   - Use `USE ROLE ACCOUNTADMIN;` and verify you can create API integrations.  
   - Confirm outbound HTTPS access to GitHub by running `SYSTEM$ATTEMPT_GIT_REACHABILITY('https://github.com');`.
3. **Snowsight/Streamlit permissions**  
   - Ensure your role has `USAGE` on `SNOWFLAKE_EXAMPLE` and `CREATE STREAMLIT` on a schema where you will host the app (this project uses `SNOWFLAKE_EXAMPLE.SFE_CONSUMPTION_FINANCIAL`).
4. **Clone or pull this repo**  
   - `git clone https://github.com/sfc-gh-miwhitaker/CapitolKings.git`  
   - Keep the repo path handy; Snowsight will read SQL files directly from Git after build.
5. **Review security requirements**  
   - All account-level objects (warehouses, API integrations, Git repos) use the `SFE_` prefix.  
   - This repo never stores credentials; supply them via Snowflake secrets if you later add private integrations.

## Troubleshooting
- **Cannot create API integration:** Switch to a higher-privilege role (ACCOUNTADMIN) and ensure the organization has allowed `git_https_api`.
- **Git reachability errors:** Confirm corporate proxies allow `github.com` outbound on port 443.
- **Streamlit blocked:** Roles need `USAGE` on the warehouse and `CREATE STREAMLIT` on the schema. Run `SHOW GRANTS TO ROLE <role>;` to verify.

## Next
Proceed to `sql/00_deploy_all.sql` and follow the copy/paste instructions in Snowsight.
