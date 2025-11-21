@echo off
IF EXIST .pids\streamlit.pid (
  ECHO Streamlit in Snowflake: OK (Snowsight manages runtime)
) ELSE (
  ECHO Streamlit in Snowflake: NOT STARTED (run tools\02_start.bat)
)
ECHO Use Snowsight Monitoring -> Warehouses to verify SFE_CAPITOLKINGS_WH status.
