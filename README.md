# Capitol Kings Credit Portfolio Demo

Capitol Kings is a Snowflake-native reference implementation showcasing Snowflake Intelligence (Cortex Analyst, Cortex Agents, Streamlit) for credit portfolio analytics. Built on a star schema dimensional model, this demo enables natural language queries over deals, exposures, commitments, and portfolio performance using only governed data in `SNOWFLAKE_EXAMPLE`.

## 👋 First Time Here?

Follow these steps in order:

1. `docs/01-SETUP.md` - Confirm roles and prerequisites (5 min)
2. `sql/00_deploy_all.sql` - Copy/paste into Snowsight, click **Run All** (5-10 min)
3. `docs/02-USAGE.md` - Test 6 business questions with the agent (10 min)
4. `docs/03-CLEANUP.md` - Drop all demo objects when finished (1 min)

**Total time:** ~20-25 minutes

## Quick Start

### Deploy (5-10 minutes)

1. **Open Snowsight** and create a new SQL worksheet
2. **Copy/paste** the entire contents of `sql/00_deploy_all.sql`
3. **Click "Run All"** and wait for deployment to complete
4. **Verify deployment:**

```sql
-- Check that agent was created
SHOW AGENTS IN SCHEMA snowflake_intelligence.agents;

-- Check that semantic view exists
SHOW VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS;
```

### Test the Agent (2 ways)

**Method 1: Snowsight UI (Recommended)**

1. In Snowsight, navigate to **AI & ML** > **Agents**
2. Find and click **CREDIT_PORTFOLIO_ANALYST**
3. Click **Open Chat** or **Chat**
4. Try a sample question:
   - *"Create a table of financial metrics for HealthTech Solutions"*
   - *"Show me all of John Williams's deals in the watchlist"*
   - *"What is the total fair value for top 10 deals"*

**Method 2: REST API**

```bash
curl -X POST "https://<account>.snowflakecomputing.com/api/v2/databases/snowflake_intelligence/schemas/agents/agents/CREDIT_PORTFOLIO_ANALYST:run" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user",
      "content": "Create a table of financial metrics for HealthTech Solutions"
    }]
  }'
```

See `docs/02-USAGE.md` for complete testing instructions and all 6 business questions.

## Architecture Overview

### Star Schema Dimensional Model

**6 Dimensions + 1 Fact Table:**
- `DIM_DATE` - Date spine with month-end flags
- `DIM_COMPANY` - Portfolio companies (includes HealthTech Solutions)
- `DIM_DEAL` - Credit deals with watchlist status and originator tracking
- `DIM_ASSET` - Individual facilities (term loans, revolvers, second liens)
- `DIM_FUND` - Investment funds (includes ACME fund family)
- `DIM_SPONSOR` - Private equity sponsors
- `FACT_POSITION_SNAPSHOT` - Daily position snapshots with financial metrics

**Key Objects:**
- **Warehouse:** `SFE_CREDIT_PORTFOLIO_WH` (X-SMALL)
- **Schema:** `SFE_ANALYTICS_CREDIT` (star schema)
- **Semantic View:** `SV_CREDIT_PORTFOLIO_OVERVIEW` (Cortex Analyst)
- **Agent:** `CREDIT_PORTFOLIO_ANALYST` (natural language queries)
- **Streamlit:** `SFE_CREDIT_PORTFOLIO_APP` (interactive dashboard)

### Data Included

**Synthetic data with specific entities:**
- **HealthTech Solutions** - Healthcare technology company
- **ACME** - Fund family with 3 funds (Direct Lending, Opportunistic, Core+)
- **Multiple originators** - Including John Williams with 8 deals (3 on watchlist)
- **March 31, 2024** - Snapshot date for commitment change analysis
- **Monthly snapshots** - Jan 2024 through current month

## Business Use Case

### Target Audience

Alternative asset managers (private equity, credit funds) evaluating Snowflake Intelligence as replacement for external text-to-SQL tools like Vanna.AI.

### Pain Points Addressed

1. **Performance Bottlenecks** - Vanna.AI: 8-12 sec latency | Snowflake: <2 sec
2. **Limited Orchestration** - Vanna.AI: Single SQL query | Snowflake: Multi-step agentic workflows
3. **Data Egress Risk** - Vanna.AI: Training data leaves Snowflake | Snowflake: 100% governed data
4. **Scalability Limits** - Vanna.AI: Single-threaded service | Snowflake: Parallel warehouse execution

### 6 Business Questions Supported

The agent can answer these natural language queries:

1. **"Create a table of financial metrics for HealthTech Solutions"**
   - Returns exposure, commitment, fair value by month

2. **"Show me all of John Williams's deals in the watchlist"**
   - Returns deals where originator=John Williams AND watchlist status elevated

3. **"List deals where commitment changed more than 2% between now and March 31st"**
   - Compares snapshots across dates, calculates % change

4. **"For each month-end starting from the beginning of the current year, what is the total exposure?"**
   - Returns monthly exposure trend (Jan-Nov 2024)

5. **"Total count of deals for ACME"**
   - Returns deal count for ACME fund family

6. **"What is the total fair value for top 10 deals"**
   - Returns ranked list by fair value

## Demo Flow (For Working Sessions)

### Act 1: Star Schema Rationale (10 min)
- Show `diagrams/data-model.md` - ERD with 6 dimensions radiating from fact table
- Explain why star schema enables natural language mapping
- Contrast with flat table approach

### Act 2: Semantic View Construction (15 min)
- Show `sql/04_cortex/01_create_semantic_view.sql`
- Walk through TABLES, RELATIONSHIPS, DIMENSIONS, FACTS, METRICS
- Highlight synonym strategy for natural language matching

### Act 3: Agent Demonstration (20 min)
- Run all 6 business questions
- Show latency (<2 sec per query)
- Demonstrate multi-step reasoning capabilities

### Act 4: Streamlit Dashboard (10 min)
- Show `SFE_CREDIT_PORTFOLIO_APP`
- 4 tabs: Portfolio Summary, Deal Analysis, Time Series, Cortex Chat
- Real-time data from star schema

### Act 5: Q&A (5 min)
- Compare to Vanna.AI architecture
- Discuss migration path
- Next steps for customer implementation

## Technical Highlights

### Native Snowflake Architecture
- 100% serverless (no external infrastructure)
- Git-integrated deployment (code versioning in Snowflake)
- Governed data access (semantic view + RBAC)
- Scalable compute (warehouse auto-suspend after 60 sec)

### Query Performance
- Star schema optimized for analytical queries
- Semantic view leverages query pruning
- Typical query latency: <2 seconds
- Warehouse: X-SMALL (scales as needed)

### Cost Optimization
- Synthetic data: <1 GB storage
- Warehouse auto-suspend: 60 seconds
- Query result caching
- No data egress charges

## Estimated Demo Costs

| Component | Size | Duration | Credits | Cost (Standard) |
|-----------|------|----------|---------|-----------------|
| One-time deployment | X-SMALL | 10 min | 0.17 | ~$0.34 |
| Per demo rehearsal | X-SMALL | 15 min | 0.25 | ~$0.50 |
| Streamlit session | Uses warehouse | Included | 0.00 | $0.00 |
| Storage (synthetic data) | <1 GB | Monthly | Negligible | <$0.05 |

**Total estimated cost per month:** ~$1.89 (one deployment + 3 rehearsals: $0.34 + 3×$0.50 + $0.05)

**Note:** Pricing based on [Snowflake Credit Consumption Table](https://www.snowflake.com/legal-files/CreditConsumptionTable.pdf). X-SMALL warehouse = 1 credit/hour. Standard Edition ($2/credit), Enterprise Edition ($3/credit), Business Critical ($4/credit).

## Competitive Positioning

### vs. Vanna.AI

| Feature | Vanna.AI | Snowflake Intelligence |
|---------|----------|------------------------|
| Query Latency | 8-12 seconds | <2 seconds (4-6x faster) |
| Orchestration | Text-to-SQL only | Multi-step agentic workflows |
| Data Governance | External service | 100% governed within Snowflake |
| Infrastructure | External deployment | Fully managed serverless |
| Cost | SaaS license + infra | Credits only (no license) |
| Scalability | Single-threaded | Parallel warehouse execution |

### vs. Custom Data Science Pipelines

- ✅ **Zero DevOps overhead** - Fully managed service
- ✅ **Built-in governance** - Semantic views + RBAC
- ✅ **Faster time-to-value** - Weeks vs months
- ✅ **Native integration** - No external tools needed

## Migration Path from Vanna.AI

1. **Week 1-2:** Parallel deployment (Snowflake Intelligence + Vanna.AI)
2. **Week 3-4:** Pilot with power users (25% adoption)
3. **Week 5-8:** Full rollout, sunset Vanna.AI
4. **Month 3+:** Add advanced features (custom ML tools, additional semantic views)

## File Structure

```
/
├── README.md (this file)
├── sql/
│   ├── 00_deploy_all.sql (copy/paste into Snowsight)
│   ├── 01_setup/ (database, schemas, warehouse)
│   ├── 02_data/ (star schema + synthetic data)
│   ├── 03_transformations/ (helper views)
│   ├── 04_cortex/ (semantic view + agent)
│   ├── 05_streamlit/ (dashboard app)
│   └── 99_cleanup/ (teardown script)
├── docs/
│   ├── 01-SETUP.md (prerequisites)
│   ├── 02-USAGE.md (6 business questions)
│   ├── 03-CLEANUP.md (teardown instructions)
│   ├── 04-VANNA-COMPARISON.md (competitive analysis)
│   └── 05-DEMO-TALKING-POINTS.md (session guide)
├── diagrams/
│   ├── data-model.md (star schema ERD)
│   ├── data-flow.md (synthetic data → semantic view)
│   ├── network-flow.md (Snowflake architecture)
│   └── auth-flow.md (RBAC and access patterns)
└── tools/
    └── (Informational scripts for Snowsight workflow)
```

## Support & Next Steps

**For Working Sessions:**
- Review `.cursor/WORKING_SESSION_GUIDE.md` for 60-minute session flow
- Includes validation checklist, teaching points, troubleshooting

**For Implementation:**
- Customize semantic view for your schema
- Map your business questions to verified queries
- Iterate on synonyms based on user language patterns

**For Questions:**
- Capture notes in `.cursor/` (git-ignored for privacy)
- Reference architecture diagrams in `diagrams/`

## License & Attribution

**Status:** Reference Implementation - NOT FOR PRODUCTION USE

This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

**Snowflake Edition Required:** Standard or higher (for Cortex Intelligence features)
