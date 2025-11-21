#!/usr/bin/env bash
set -euo pipefail
if [[ -f .pids/streamlit.pid ]]; then
  rm .pids/streamlit.pid
  echo "Cleared local tracking for Streamlit session. Nothing to stop on your laptop."
else
  echo "No local tracking file found; nothing to do."
fi
