# 03 – Cleanup Guide

## Goal
Remove every Capitol Kings demo artifact while preserving the shared `SNOWFLAKE_EXAMPLE` database and any reusable `SFE_*` integrations.

## Fast Path (Recommended)
1. Open Snowsight with a high-privilege role (ACCOUNTADMIN).
2. Paste and run `sql/99_cleanup/teardown_all.sql`.
3. Confirm that only the protected assets remain:
   ```sql
   SHOW WAREHOUSES LIKE 'SFE_CAPITOLKINGS_WH'; -- should return 0 rows
   SHOW AGENTS LIKE 'CAPITOLKINGS_INTELLIGENCE_AGENT'; -- should return 0 rows
   SHOW STREAMLITS LIKE 'SFE_INVESTMENT_INTEL_APP'; -- should return 0 rows
   ```

## Manual Checklist
If you prefer discrete steps, run the following in order:
1. Drop Streamlit + Streamlit supporting objects (schemas stay intact).
2. Drop Cortex agent, semantic view, and search service.
3. Drop dynamic tables, views, staging tables, and raw tables.
4. Drop SFE-prefixed schemas (`RAW`, `STG`, `ANALYTICS`, `CONSUMPTION`, `ORCHESTRATION`).
5. Drop the warehouse `SFE_CAPITOLKINGS_WH`.
6. Optionally drop the Git repository stage **only** if no other demos share it.

Every object in the scripts includes `COMMENT = 'DEMO: Capitol Kings – ...'`, so you can also run:
```sql
SELECT database_name, schema_name, name, comment
FROM SNOWFLAKE.ACCOUNT_USAGE.OBJECTS
WHERE comment ILIKE 'DEMO: Capitol Kings%';
```
to verify nothing lingered.

## Protected Assets
- `SNOWFLAKE_EXAMPLE` database (never drop; other demos rely on it).
- Any shared `SFE_*` API integrations or secrets used across demo projects.

## After Cleanup
- Suspend or drop unused roles if you created temporary ones.
- Delete any `.pids/*` files produced by the helper scripts (handled automatically if you ran `tools/04_stop.*`).
- Capture lessons learned in `.cursornotes/` (kept out of Git).
