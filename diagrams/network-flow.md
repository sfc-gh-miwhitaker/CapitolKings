# Network Flow - Capitol Kings Intelligence Demo

Author: SE Community  
Last Updated: 2025-11-21  
Expires: 2025-12-21 (30 days from creation)  
Status: Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

**Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview
Connectivity diagram showing how Snowsight users, GitHub, and Snowflake services interact for the Capitol Kings demo.

```mermaid
graph TB
  subgraph External
    User["Demo Presenter\nBrowser"]
    GitHub["GitHub Repo\nhttps://github.com/sfc-gh-miwhitaker/CapitolKings"]
  end
  subgraph Snowflake Account
    Snowsight["Snowsight Worksheets\nHTTPS :443"]
    Warehouse["SFE_CAPITOLKINGS_WH\nVirtual Warehouse"]
    GitRepo["SNOWFLAKE_EXAMPLE.GIT_REPOS.SFE_CAPITOLKINGS_REPO"]
    Schemas["SFE_* Schemas\nRAW/STG/ANALYTICS/CONSUMPTION"]
    StreamlitApp["SFE_INVESTMENT_INTEL_APP"]
    Agent["CAPITOLKINGS_INTELLIGENCE_AGENT"]
  end

  User -->|HTTPS :443| Snowsight
  Snowsight -->|git_https_api| GitHub
  Snowsight -->|SQL over HTTPS| Warehouse
  Warehouse --> Schemas
  GitRepo --> Snowsight
  Snowsight --> StreamlitApp
  Agent --> Warehouse
  Agent --> Schemas
```

## Component Descriptions
- **User / Browser**: Analyst or SE running the demo via Snowsight over TLS.
- **GitHub**: Public repo fetched through `SFE_CAPITOLKINGS_GIT_API_INTEGRATION` using `git_https_api`.
- **SFE_CAPITOLKINGS_WH**: Executes SQL, dynamic tables, semantic view queries, and Streamlit session compute.
- **SFE_* Schemas**: Store RAW/STG/ANALYTICS/CONSUMPTION objects plus stored procedures.
- **Streamlit App**: Runs entirely within Snowflake; relies on the same warehouse for queries.
- **Cortex Agent**: Routes across the semantic view, search service, and ML stored procedure while staying inside account boundaries.

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.
