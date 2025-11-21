#!/usr/bin/env bash
set -euo pipefail
if [[ -f .pids/streamlit.pid ]]; then
  echo "Streamlit in Snowflake: ✅ Running (Snowsight managed)"
else
  echo "Streamlit in Snowflake: ⚪ Not started (run tools/02_start.sh)"
fi
echo "Reminder: All compute happens inside Snowflake. Use Snowsight Monitoring to check warehouses/tasks."
