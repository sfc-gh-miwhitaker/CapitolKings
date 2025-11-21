#!/usr/bin/env bash
set -euo pipefail
show_help() {
  cat <<'MSG'
Capitol Kings Master Orchestrator
Usage: ./tools/00_master.sh [command]

Commands:
  run         Print the end-to-end workflow (default)
  refresh     Re-run the manual refresh checklist
  cleanup     Remind you how to run teardown_all.sql
MSG
}
command="${1:-run}"
case "$command" in
  -h|--help|help)
    show_help
    ;;
  run)
    cat <<'STEPS'
1. Read docs/01-SETUP.md
2. Open Snowsight, paste sql/00_deploy_all.sql, click Run All
3. Follow docs/02-DEPLOYMENT.md to refresh data + test the agent
4. When finished, run sql/99_cleanup/teardown_all.sql (or ./tools/00_master.sh cleanup)
STEPS
    ;;
  refresh)
    cat <<'REFRESH'
Manual Refresh Checklist:
- Execute sql/02_data/02_load_sample_data.sql
- CALL SNOWFLAKE_EXAMPLE.SFE_ORCHESTRATION_FINANCIAL.SP_REFRESH_ANALYTICS();
- ALTER DYNAMIC TABLE ... RESUME/REFRESH/SUSPEND
- ALTER CORTEX SEARCH SERVICE ... REFRESH
REFRESH
    ;;
  cleanup)
    cat <<'CLEAN'
Cleanup:
- Open docs/03-CLEANUP.md
- Run sql/99_cleanup/teardown_all.sql from Snowsight
- Verify SHOW WAREHOUSES LIKE 'SFE_CAPITOLKINGS_WH' returns no rows
CLEAN
    ;;
  *)
    echo "Unknown command: $command" >&2
    show_help
    exit 1
    ;;
esac
