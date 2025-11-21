# 02 – Deployment & Demo Runbook

## Goal
Deploy the Capitol Kings intelligence stack, hydrate 12 months of synthetic portfolio data, and validate every experience (semantic view, Cortex agent, Streamlit dashboard, and the ML-powered custom tool).

## Deployment Steps
1. **Open Snowsight**  
   - Role: `ACCOUNTADMIN` (or equivalent).  
   - Warehouse: leave blank; the script creates `SFE_CAPITOLKINGS_WH` automatically.
2. **Paste `sql/00_deploy_all.sql`**  
   - Copy the entire file, paste into a new worksheet, and click **Run All**.  
   - The script performs: API integration, Git repo registration, schema creation, sample data load, transformations, Cortex objects, Streamlit app, and cleanup hooks.  
   - Total runtime: ~10 minutes on an X-SMALL warehouse.
3. **Watch for the success banner**  
   - The script prints ✅ messages per phase.  
   - If a statement fails, resolve the error, then re-run from the failing block (script is idempotent).

## Manual Refresh Checklist (On-Demand Requirement)
1. **Reload synthetic data** *(recommended before every meeting)*  
   ```sql
   EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/02_data/02_load_sample_data.sql;
   ```
2. **Refresh staging & analytics tables**  
   ```sql
   CALL SNOWFLAKE_EXAMPLE.SFE_ORCHESTRATION_FINANCIAL.SP_REFRESH_ANALYTICS();
   ```
3. **Resume and refresh dynamic table**  
   ```sql
   ALTER DYNAMIC TABLE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_FINANCIAL.SFE_DT_PORTFOLIO_METRICS RESUME;
   ALTER DYNAMIC TABLE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_FINANCIAL.SFE_DT_PORTFOLIO_METRICS REFRESH;
   ALTER DYNAMIC TABLE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_FINANCIAL.SFE_DT_PORTFOLIO_METRICS SUSPEND;
   ```
   (Keeps costs near zero while preserving on-demand freshness control.)
4. **Rebuild Cortex Search service**  
   ```sql
   ALTER CORTEX SEARCH SERVICE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_FINANCIAL.SFE_RESEARCH_MEMO_SEARCH REFRESH;
   ```
5. **Retrain or warm the ML-powered custom tool (optional)**  
   ```sql
   CALL SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_FINANCIAL.SP_RUN_RISK_REVIEW('PORTFOLIO-003');
   ```
   The procedure reuses the latest classification model and returns JSON ready for the Cortex agent custom tool.

## Pre-Demo Rehearsal Checklist

### 24 Hours Before Demo
Complete these steps to ensure a smooth live demonstration:

1. **Data Refresh (MANDATORY)**
   ```sql
   -- Reload synthetic data with current timestamps
   EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO/branches/main/sql/02_data/02_load_sample_data.sql;
   ```

2. **Analytics Refresh**
   ```sql
   -- Rebuild staging tables and refresh dynamic table
   CALL SNOWFLAKE_EXAMPLE.SFE_ORCHESTRATION_FINANCIAL.SP_REFRESH_ANALYTICS();
   ```

3. **Cortex Search Service Refresh**
   ```sql
   -- Rebuild memo index
   ALTER CORTEX SEARCH SERVICE SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_FINANCIAL.SFE_RESEARCH_MEMO_SEARCH REFRESH;
   ```

4. **Test Agent Sample Questions**
   - Navigate to: Snowsight → AI & ML → Cortex Agents → `CAPITOLKINGS_INTELLIGENCE_AGENT`
   - Test all 5 sample questions and verify responses are accurate
   - Confirm latency is <3 seconds per query
   - **Expected Results:**
     - "Show me portfolio companies..." → Table with 3-5 portfolios and spreads
     - "Which portfolios have widest spreads..." → Ranked list with macro signals
     - "Compare PORTFOLIO-002 and PORTFOLIO-005..." → Side-by-side trend analysis
     - "Trigger ML risk review for PORTFOLIO-005..." → JSON prediction with confidence scores
     - "What does analyst commentary say..." → Memo excerpts with citations

5. **Warm Up ML Model**
   ```sql
   -- Pre-train classification model to avoid cold start during demo
   CALL SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_FINANCIAL.SP_RUN_RISK_REVIEW('PORTFOLIO-005');
   ```
   Expected: JSON response with `prediction: "Action"`, `confidence: ~0.87`

6. **Validate Streamlit App**
   - Open: Apps → `SFE_INVESTMENT_INTEL_APP`
   - Select each portfolio and verify KPIs load
   - Test comparison mode with 2 portfolios
   - Confirm analyst memos display correctly
   - Test "Refresh Data" button

### 30 Minutes Before Demo
Final technical validation:

- [ ] **Warehouse Status:** `SHOW WAREHOUSES LIKE 'SFE_CAPITOLKINGS_WH';` → Should be STARTED
- [ ] **Resume Warehouse:** `ALTER WAREHOUSE SFE_CAPITOLKINGS_WH RESUME;` (prevent cold start)
- [ ] **Test Query Latency:** Run semantic view query and time it (target: <2 seconds)
   ```sql
   SELECT portfolio_code, metrics.avg_exposure_usd
   FROM SEMANTIC_VIEW(
       SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_INVESTMENT_INTELLIGENCE
       DIMENSIONS portfolio.portfolio_code
       METRICS metrics.avg_exposure_usd
   )
   LIMIT 5;
   ```
- [ ] **Verify Data Freshness:** Check max date in `V_PORTFOLIO_RISK_SUMMARY` → Should be today or yesterday
- [ ] **Screen Sharing Test:** Confirm Snowsight + Streamlit tabs are visible and shareable
- [ ] **Browser Zoom:** Set to 90-100% for optimal visibility during screen share

### Demo Environment Prep
- [ ] Close unnecessary browser tabs (reduce visual clutter)
- [ ] Open these Snowsight tabs in sequence:
  1. Semantic View query worksheet (for Act 2)
  2. Cortex Agent UI (for Act 3)
  3. Streamlit app (for Act 4)
- [ ] Have backup worksheet with pre-executed queries (in case agent fails live)
- [ ] Review `docs/05-DEMO-TALKING-POINTS.md` for 5-act script

### If Agent Fails During Live Demo
**Backup Plan:** Show pre-executed queries from worksheet
1. Say: "Let me show you the query the agent would have generated..."
2. Execute semantic view query manually with SQL
3. Still demonstrates semantic layer value even without agent orchestration
4. Proceed to Streamlit dashboard (Act 4) which doesn't depend on agent

## Validations
- **Semantic view:**
```sql
SELECT
    portfolio_code,
    metrics.avg_exposure_usd
FROM SEMANTIC_VIEW(
    SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_INVESTMENT_INTELLIGENCE
    DIMENSIONS portfolio.portfolio_code
    METRICS metrics.avg_exposure_usd
)
WHERE portfolio_code = 'PORTFOLIO-001';
```
- **Cortex agent:** In Snowsight → AI & ML → Cortex Agents → `CAPITOLKINGS_INTELLIGENCE_AGENT`. Test prompts:  
  - “Which portfolio has the highest credit spread relative to its benchmark?”  
  - “Trigger a ML risk review for PORTFOLIO-005 and summarize the prediction.”
- **Streamlit:** Apps → `SFE_INVESTMENT_INTEL_APP`, then select any portfolio code. The tiles and charts update based on the dynamic table view.

## Troubleshooting
| Symptom | Fix |
| --- | --- |
| API integration creation fails | Ensure `git_https_api` provider is enabled and reachable. Re-run that block only. |
| Dynamic table stuck in `SUSPENDED_AUTO` | Resume (`ALTER ... RESUME`) before refreshing; investigate upstream tables for errors. |
| Streamlit app loads but queries fail | Verify `SFE_CAPITOLKINGS_WH` is running and you have `USAGE` on it. |
| Agent custom tool errors | The stored procedure does not accept OBJECT parameters. Verify inputs are VARCHAR/NUMBER only. |

## Next
Demo complete? Clean everything up using `docs/03-CLEANUP.md`.
