#!/usr/bin/env bash
set -euo pipefail
mkdir -p .pids
cat <<'MSG'
Snowflake-native demo – nothing to start locally.
Use Snowsight → Apps → Streamlit to open `SFE_INVESTMENT_INTEL_APP`.
This helper just tracks that you acknowledged the checklist.
MSG
printf 'snowflake_streamlit
' > .pids/streamlit.pid
