@echo off
IF "%1"=="" GOTO run
IF "%1"=="help" GOTO help
IF "%1"=="--help" GOTO help
IF "%1"=="-h" GOTO help
IF "%1"=="refresh" GOTO refresh
IF "%1"=="cleanup" GOTO cleanup
:help
ECHO Capitol Kings Master Orchestrator
ECHO Usage: tools\00_master.bat [run^|refresh^|cleanup]
GOTO end
:run
ECHO 1. Read docs/01-SETUP.md
ECHO 2. Open Snowsight, paste sql/00_deploy_all.sql, click Run All
ECHO 3. Follow docs/02-DEPLOYMENT.md to refresh data + test the agent
ECHO 4. Finished? Run sql/99_cleanup/teardown_all.sql (or tools\00_master.bat cleanup)
GOTO end
:refresh
ECHO Manual Refresh Checklist:
ECHO   - Execute sql/02_data/02_load_sample_data.sql
ECHO   - CALL SNOWFLAKE_EXAMPLE.SFE_ORCHESTRATION_FINANCIAL.SP_REFRESH_ANALYTICS();
ECHO   - ALTER DYNAMIC TABLE ... RESUME/REFRESH/SUSPEND
ECHO   - ALTER CORTEX SEARCH SERVICE ... REFRESH
GOTO end
:cleanup
ECHO Cleanup:
ECHO   - Open docs/03-CLEANUP.md
ECHO   - Run sql/99_cleanup/teardown_all.sql from Snowsight
ECHO   - SHOW WAREHOUSES LIKE ^'SFE_CAPITOLKINGS_WH^' should return no rows
GOTO end
:end
