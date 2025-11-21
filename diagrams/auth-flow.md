# Auth Flow - Capitol Kings Intelligence Demo
Author: Michael Whitaker  
Last Updated: 2025-11-19  
Status: Reference Impl
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
Reference Impl: This code demonstrates prod-grade architectural patterns and best practice. review and customize security, networking, logic for your organization's specific requirements before deployment.

## Overview
Authentication and authorization sequence for operators using Snowsight, Streamlit, and the Cortex agent.

```mermaid
sequenceDiagram
  actor User
  participant Snowsight
  participant Role as ACCOUNTADMIN Role
  participant Warehouse as SFE_CAPITOLKINGS_WH
  participant Schemas as SNOWFLAKE_EXAMPLE.SFE_*
  participant Agent as CAPITOLKINGS_INTELLIGENCE_AGENT

  User->>Snowsight: Login with SSO / MFA
  Snowsight->>Role: USE ROLE ACCOUNTADMIN
  Role-->>Snowsight: Grants CREATE STREAMLIT, CREATE AGENT, etc.
  Snowsight->>Warehouse: USE WAREHOUSE SFE_CAPITOLKINGS_WH
  Warehouse-->>Snowsight: Session established
  Snowsight->>Schemas: Run sql/00_deploy_all.sql (DDL + DML)
  User->>Streamlit: Launch SFE_INVESTMENT_INTEL_APP
  Streamlit->>Warehouse: session.sql() queries
  User->>Agent: Ask NL question via Snowsight
  Agent->>Schemas: SELECT via semantic view
  Agent->>Warehouse: Execute ML stored procedure
  Schemas-->>Agent: Scoped results
  Agent-->>User: Answer with citations
```

## Component Descriptions
- **ACCOUNTADMIN Role**: Grants ability to create SFE_* schemas, warehouse, Streamlit objects, Cortex agent.
- **SFE_CAPITOLKINGS_WH**: Warehouse used for both deployment and runtime (Streamlit & agent queries).
- **SNOWFLAKE_EXAMPLE.SFE_* Schemas**: Hold all objects; RBAC enforced via the active role.
- **CAPITOLKINGS_INTELLIGENCE_AGENT**: Requires USAGE on semantic view, search service, and custom stored procedure.

## Change History
See `.cursor/DIAGRAM_CHANGELOG.md` for vhistory.
