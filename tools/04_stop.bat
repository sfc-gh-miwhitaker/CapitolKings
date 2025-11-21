@echo off
IF EXIST .pids\streamlit.pid (
  DEL /Q .pids\streamlit.pid >NUL 2>&1
  ECHO Cleared local tracking. Stop the Streamlit app from Snowsight if needed.
) ELSE (
  ECHO Nothing to stop.
)
