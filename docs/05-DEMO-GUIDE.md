# Capitol Kings Demo Guide

## Overview

This guide provides a structured approach for demonstrating the Capitol Kings credit portfolio analytics solution. The demo showcases Snowflake Intelligence (Cortex Analyst + Agents + Streamlit) using a star schema dimensional model.

**Duration:** 30-45 minutes  
**Audience:** Technical and business stakeholders evaluating Snowflake Intelligence for credit portfolio analytics

---

## Pre-Demo Checklist

### 24 Hours Before Demo
- [ ] Run full deployment: Copy/paste `sql/00_deploy_all.sql` into Snowsight
- [ ] Test all 6 sample questions in Cortex Agent UI
- [ ] Verify Streamlit app loads with current data
- [ ] Confirm warehouse `SFE_CREDIT_PORTFOLIO_WH` is running
- [ ] Review architecture diagrams in `diagrams/` directory

### 30 Minutes Before Demo
- [ ] Confirm screen sharing works (test Snowsight + Streamlit side-by-side)
- [ ] Open Snowsight tabs: Agent, Semantic View, Streamlit App
- [ ] Have backup queries ready in case agent fails live
- [ ] Check query latency (<2 sec expected for sample queries)

---

## 5-Act Demo Script (30 Minutes)

### Act 1: Context & Architecture (5 min)

**GOAL:** Establish use case and introduce star schema foundation

**Key Points:**
- Credit portfolio management for alternative asset managers
- Demonstrates Snowflake Intelligence as enterprise text-to-SQL solution
- 100% native Snowflake architecture (no external dependencies)

**Show:** `diagrams/data-model.md` - Star schema with 6 dimensions + 1 fact table

**Key Message:**  
"Star schema dimensional modeling enables natural language mapping. Business users understand dimensions (companies, deals, funds) and metrics (exposure, commitment, fair value) without SQL knowledge."

---

### Act 2: Semantic View Construction (7 min)

**GOAL:** Demonstrate how semantic layer bridges data and business language

**Show:** `sql/04_cortex/01_create_semantic_view.sql`

**Walk Through:**
1. **TABLES**: Maps star schema to business aliases
2. **RELATIONSHIPS**: Declares FK relationships for query optimizer
3. **DIMENSIONS**: Maps columns to business terms with synonyms
4. **FACTS**: Defines measures with aggregation methods
5. **METRICS**: Pre-computed calculations
6. **VERIFIED QUERIES**: 6 business questions with validated SQL

**Demo Query:**
```sql
-- Show underlying star schema data
SELECT 
    companies.company_name,
    deals.deal_name,
    deals.watchlist,
    deals.originator1,
    SUM(facts.exposure) AS total_exposure
FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT facts
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY companies 
    ON facts.company_id = companies.company_id
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL deals 
    ON facts.deal_id = deals.deal_id
JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE dates 
    ON facts.date_id = dates.date_key
WHERE dates.calendar_date = CURRENT_DATE()
GROUP BY 1, 2, 3, 4
ORDER BY total_exposure DESC
LIMIT 10;
```

**Key Message:**  
"Semantic view excellence requires rich descriptions, thoughtful synonyms, and verified queries. This creates a self-documenting layer that both humans and AI can understand."

---

### Act 3: Cortex Agent Demonstration (10 min)

**GOAL:** Show agentic AI answering complex business questions

**Navigate to:** Snowsight → AI & ML → Cortex Agents → `CREDIT_PORTFOLIO_ANALYST`

**Run All 6 Sample Questions:**

1. **"Create a table of financial metrics for HealthTech Solutions"**
   - Expected: Monthly exposure, commitment, fair value
   - Teaching Point: Company name synonym matching

2. **"Show me all of John Williams's deals in the watchlist"**
   - Expected: 2-3 deals with watchlist status
   - Teaching Point: Multi-attribute filtering

3. **"List deals where commitment changed more than 2% between now and March 31st"**
   - Expected: Deals with meaningful variance
   - Teaching Point: Time-series comparison

4. **"For each month-end starting from the beginning of the current year, what is the total exposure?"**
   - Expected: Monthly trend (Jan-current month)
   - Teaching Point: Time dimension with month-end flags

5. **"Total count of deals for ACME"**
   - Expected: Deal count for ACME fund family
   - Teaching Point: Fund family dimension filtering

6. **"What is the total fair value for top 10 deals"**
   - Expected: Ranked list by fair value
   - Teaching Point: Aggregation + ranking

**Highlight for Each Query:**
- **Latency:** <2 seconds per query
- **Accuracy:** Agent understands business context
- **Transparency:** Agent explains its reasoning
- **Citations:** References semantic view tools used

**Key Message:**  
"This agentic approach enables multi-step reasoning. The agent doesn't just generate SQL—it understands your question, plans its approach, queries the semantic view, and synthesizes an answer with citations."

---

### Act 4: Streamlit Dashboard (6 min)

**GOAL:** Show business insights for investment decision-making

**Navigate to:** Apps → `SFE_CREDIT_PORTFOLIO_APP`

**Demo Flow:**
1. **Overview Tab:**
   - Key metrics: Total exposure, deal count, average spread
   - Portfolio summary table

2. **Deal Analysis Tab:**
   - Filter by watchlist status, originator, fund family
   - Drill-down to deal-level details

3. **Time Series Tab:**
   - Exposure trends over time
   - Commitment vs exposure analysis

4. **Cortex Chat Tab:**
   - Interactive agent embedded in dashboard
   - Ask questions directly from business context

**Key Message:**  
"Streamlit dashboards powered by the same semantic view provide both pre-built analytics and ad-hoc exploration. Business users get self-service without compromising governance."

---

### Act 5: Architecture & Next Steps (2 min)

**GOAL:** Summarize value proposition and discuss implementation

**Key Takeaways:**
1. **Star schema** enables natural language mapping
2. **Semantic view** bridges data and business terminology
3. **Cortex Agent** provides multi-step reasoning with citations
4. **Streamlit** delivers governed self-service analytics
5. **100% native Snowflake** - no external dependencies or data movement

**Architecture Highlights:**
- **Performance:** Sub-2-second query latency
- **Scalability:** Elastic multi-cluster warehouses
- **Governance:** Native RBAC, full audit trail
- **Cost:** Consumption-based (X-SMALL warehouse = 1 credit/hour × $2/credit = $2/hour on Standard Edition)

**Next Steps:**
1. Review semantic view structure (`sql/04_cortex/01_create_semantic_view.sql`)
2. Test with your data model (parallel deployment recommended)
3. Create verified queries for your key business questions
4. Iterate on synonyms based on user language patterns
5. Define success metrics (latency, adoption, accuracy)

---

## Backup Plans (If Things Go Wrong)

### Agent Doesn't Respond or Errors Out
**Fallback:** Show pre-executed query results
- Have 3-5 queries pre-run with results cached in Snowsight worksheet
- Say: "Let me show you the query the agent would have generated..."
- Execute manually to still demonstrate semantic view value

### Streamlit App Won't Load
**Fallback:** Query views directly
- Open `sql/03_transformations/03_create_views.sql`
- Run queries against consumption views to show same data
- Emphasize: "Dashboard is just a visualization layer—data is the foundation"

### Warehouse Suspended / Cold Start Delay
**Prevention:** Resume warehouse 5 minutes before demo
```sql
ALTER WAREHOUSE SFE_CREDIT_PORTFOLIO_WH RESUME;
-- Execute a dummy query to warm up compute
SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY;
```

### Query Latency Higher Than Expected
**Explanation:** Snowflake result cache
- First query: ~2-3 seconds (cold cache)
- Subsequent queries: ~0.5 seconds (cached)
- Emphasize: "Production would benefit from cache across all users"

---

## Key Talking Points by Theme

### Performance
"Semantic layer pre-computation enables sub-2-second query latency. The agent doesn't generate SQL from scratch—it references pre-validated business metrics defined in the semantic view."

### Agentic Approach
"Unlike text-to-SQL tools that generate a single query, Snowflake Intelligence agents orchestrate multi-step workflows: structured query → analysis → synthesis. This enables complex reasoning that simple SQL generation cannot achieve."

### Data Governance
"100% of data stays within Snowflake's governance perimeter. Semantic views enforce RBAC at the metric level, ensuring business users have natural language access only to data they're authorized to see."

### Scalability
"Elastic multi-cluster warehouses scale automatically based on query demand. During peak usage (e.g., quarterly reporting), Snowflake spins up additional compute clusters and scales back down during lulls."

### Total Cost of Ownership
"No licensing fees, no external infrastructure, no DevOps overhead. You're paying for Snowflake compute credits you're already using, just with an intelligence layer on top."

---

## Validation Queries (Run Pre-Demo)

```sql
-- Validate HealthTech Solutions exists
SELECT company_name FROM DIM_COMPANY WHERE company_name = 'HealthTech Solutions';
-- Expected: 1 row

-- Validate ACME fund family exists
SELECT fund_family FROM DIM_FUND WHERE fund_family = 'ACME';
-- Expected: 3 rows (3 ACME funds)

-- Validate John Williams deals
SELECT COUNT(*) FROM DIM_DEAL WHERE originator1 = 'John Williams';
-- Expected: 8 deals

-- Validate John Williams watchlist deals
SELECT COUNT(*) FROM DIM_DEAL 
WHERE originator1 = 'John Williams' 
AND watchlist IN ('Watchlist', 'Intensive Care');
-- Expected: 3 deals

-- Validate March 31 snapshot
SELECT COUNT(*) FROM FACT_POSITION_SNAPSHOT f
JOIN DIM_DATE d ON f.date_id = d.date_key
WHERE d.calendar_date = '2024-03-31';
-- Expected: >0 rows

-- Validate monthly snapshots
SELECT COUNT(DISTINCT d.month_end_date)
FROM FACT_POSITION_SNAPSHOT f
JOIN DIM_DATE d ON f.date_id = d.date_key
WHERE d.is_month_end = TRUE AND d.year = 2024;
-- Expected: 11-12 months (depends on current month)
```

---

## Troubleshooting Reference

| Issue | Fix |
|-------|-----|
| Agent returns no results | Check synonym mapping in semantic view |
| Commitment change query returns empty | Verify March 31, 2024 snapshot exists |
| Monthly trend only shows 1-2 months | Check date range in DIM_DATE table |
| Streamlit app loads but queries fail | Verify `SFE_CREDIT_PORTFOLIO_WH` is running |
| High query latency on first run | Expected for cold cache; warm up with test query |

---

## Post-Demo Follow-Up

**Send these artifacts:**
1. Link to GitHub repo: `https://github.com/sfc-gh-miwhitaker/CapitolKings`
2. Deployment guide: `docs/01-SETUP.md`
3. Semantic view SQL: `sql/04_cortex/01_create_semantic_view.sql`
4. Vanna.AI comparison: `docs/04-VANNA-COMPARISON.md`

**Offer:**
- Follow-up session to apply to their actual data model
- Review of their existing analytics stack for migration planning
- Assistance with semantic view design for their schema
- 4-6 week parallel deployment pilot program

---

## Demo Rehearsal Checklist

### Solo Rehearsal (Do 2-3 Times Before Live Demo)
- [ ] Time each act (should hit: 5/12/22/28/30 minute marks)
- [ ] Practice transitions between acts (smooth, no awkward pauses)
- [ ] Test all queries in agent (confirm no errors)
- [ ] Navigate Snowsight UI without hesitation
- [ ] Practice explanations without reading notes

### Peer Review (Recommended)
- [ ] Run full demo for colleague
- [ ] Ask for feedback: "Where did I lose you?" "What was unclear?"
- [ ] Refine talking points based on feedback
- [ ] Practice answering curveball questions

### Final Confidence Check
- [ ] Can you explain agent orchestration without notes?
- [ ] Can you recover gracefully if agent fails live?
- [ ] Do you feel confident explaining semantic views to non-technical audience?
- [ ] Can you answer "Why Snowflake vs Vanna.AI?" in 30 seconds?

**If you answered "No" to any of the above, rehearse again.**

---

## Quick Reference Card (Print This)

**5 Acts in 30 Minutes:**
- Act 1 (5 min): Context + star schema
- Act 2 (7 min): Semantic view construction
- Act 3 (10 min): Agent orchestration
- Act 4 (6 min): Streamlit dashboard
- Act 5 (2 min): Architecture + next steps

**Must-Mention Points:**
1. "Star schema enables natural language mapping"
2. "Sub-2-second latency vs 8-12 seconds for external tools"
3. "No data egress – 100% governed within Snowflake"
4. "Agentic approach: multi-step reasoning, not just SQL generation"
5. "Consumption-based pricing – no licensing fees"

**Backup Plan if Agent Fails:**
- Show pre-executed queries from worksheet
- Query semantic view manually with SQL
- Still demonstrates value of semantic layer

**Post-Demo Next Steps:**
- Technical deep-dive workshop
- Sandbox environment for testing with their data
- Migration timeline development

