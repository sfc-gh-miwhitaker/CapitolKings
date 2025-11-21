import streamlit as st
from snowflake.snowpark.context import get_active_session
from datetime import datetime
import pandas as pd

st.set_page_config(page_title="Capitol Kings Credit Portfolio", layout="wide", page_icon="📊")
session = get_active_session()

# Helper functions
@st.cache_data(show_spinner=False)
def get_data_freshness():
    result = session.sql(
        """
        SELECT 
            MAX(d.calendar_date) AS latest_date,
            COUNT(DISTINCT f.deal_id) AS deal_count,
            COUNT(DISTINCT f.company_id) AS company_count
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
        """
    ).collect()
    return result[0] if result else None

@st.cache_data(show_spinner=False)
def get_portfolio_summary():
    df = session.sql(
        """
        SELECT
            SUM(f.exposure) AS total_exposure,
            SUM(f.commitment) AS total_commitment,
            SUM(f.fair_value) AS total_fair_value,
            AVG(f.mark) AS average_mark,
            COUNT(DISTINCT f.deal_id) AS deal_count,
            COUNT(DISTINCT f.company_id) AS company_count
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
        WHERE d.calendar_date = CURRENT_DATE()
        """
    ).to_pandas()
    return df.iloc[0] if not df.empty else None

@st.cache_data(show_spinner=False)
def get_top_deals_by_exposure(limit=10):
    return session.sql(
        f"""
        SELECT
            deals.deal_name,
            companies.company_name,
            deals.watchlist,
            deals.rating,
            SUM(f.exposure) AS total_exposure,
            SUM(f.commitment) AS total_commitment,
            AVG(f.mark) AS average_mark
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL deals ON f.deal_id = deals.deal_id
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY companies ON f.company_id = companies.company_id
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
        WHERE d.calendar_date = CURRENT_DATE()
        GROUP BY deals.deal_name, companies.company_name, deals.watchlist, deals.rating
        ORDER BY total_exposure DESC
        LIMIT {limit}
        """
    ).to_pandas()

@st.cache_data(show_spinner=False)
def get_exposure_by_industry():
    return session.sql(
        """
        SELECT
            companies.industry,
            SUM(f.exposure) AS total_exposure,
            COUNT(DISTINCT f.deal_id) AS deal_count
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY companies ON f.company_id = companies.company_id
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
        WHERE d.calendar_date = CURRENT_DATE()
        GROUP BY companies.industry
        ORDER BY total_exposure DESC
        """
    ).to_pandas()

@st.cache_data(show_spinner=False)
def get_monthly_exposure_trend():
    return session.sql(
        """
        SELECT
            d.month_end_date,
            SUM(f.exposure) AS total_exposure,
            SUM(f.commitment) AS total_commitment,
            SUM(f.fair_value) AS total_fair_value
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
        WHERE d.is_month_end = TRUE
          AND d.year = YEAR(CURRENT_DATE())
        GROUP BY d.month_end_date
        ORDER BY d.month_end_date
        """
    ).to_pandas()

@st.cache_data(show_spinner=False)
def get_all_deals(watchlist_filter=None, originator_filter=None):
    base_query = """
        SELECT
            deals.deal_name,
            companies.company_name,
            deals.watchlist,
            deals.rating,
            deals.originator1,
            deals.deal_date,
            SUM(f.exposure) AS total_exposure,
            SUM(f.fair_value) AS total_fair_value
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.FACT_POSITION_SNAPSHOT f
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL deals ON f.deal_id = deals.deal_id
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_COMPANY companies ON f.company_id = companies.company_id
        JOIN SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DATE d ON f.date_id = d.date_key
        WHERE d.calendar_date = CURRENT_DATE()
    """
    
    if watchlist_filter and watchlist_filter != "All":
        base_query += f" AND deals.watchlist = '{watchlist_filter}'"
    
    if originator_filter and originator_filter != "All":
        base_query += f" AND deals.originator1 = '{originator_filter}'"
    
    base_query += """
        GROUP BY deals.deal_name, companies.company_name, deals.watchlist, deals.rating, deals.originator1, deals.deal_date
        ORDER BY total_exposure DESC
    """
    
    return session.sql(base_query).to_pandas()

@st.cache_data(show_spinner=False)
def get_unique_originators():
    result = session.sql(
        """
        SELECT DISTINCT originator1
        FROM SNOWFLAKE_EXAMPLE.SFE_ANALYTICS_CREDIT.DIM_DEAL
        WHERE originator1 IS NOT NULL
        ORDER BY originator1
        """
    ).collect()
    return ["All"] + [row[0] for row in result]

# Header
st.title("📊 Capitol Kings Credit Portfolio Dashboard")
st.caption("🔒 Credit portfolio analytics powered by Snowflake Intelligence")

# Data freshness banner
freshness = get_data_freshness()
if freshness:
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("📅 Latest Data", str(freshness['LATEST_DATE']))
    with col2:
        st.metric("📈 Total Deals", f"{freshness['DEAL_COUNT']}")
    with col3:
        st.metric("🏢 Companies", f"{freshness['COMPANY_COUNT']}")

st.divider()

# Tabs for different views
tab1, tab2, tab3, tab4 = st.tabs(["📊 Portfolio Summary", "💼 Deal Analysis", "📈 Time Series", "💬 Cortex Chat"])

# TAB 1: Portfolio Summary
with tab1:
    st.header("Portfolio Overview")
    
    summary = get_portfolio_summary()
    if summary is not None:
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("Total Exposure", f"${summary['TOTAL_EXPOSURE']:,.0f}")
        with col2:
            st.metric("Total Commitment", f"${summary['TOTAL_COMMITMENT']:,.0f}")
        with col3:
            st.metric("Total Fair Value", f"${summary['TOTAL_FAIR_VALUE']:,.0f}")
        with col4:
            st.metric("Average Mark", f"{summary['AVERAGE_MARK']:.4f}")
        
        st.divider()
        
        # Top 10 deals by exposure
        st.subheader("Top 10 Deals by Exposure")
        top_deals = get_top_deals_by_exposure(10)
        
        if not top_deals.empty:
            # Add color coding for watchlist status
            def highlight_watchlist(row):
                if row['WATCHLIST'] == 'Intensive Care':
                    return ['background-color: #ffebee'] * len(row)
                elif row['WATCHLIST'] == 'Watchlist':
                    return ['background-color: #fff9c4'] * len(row)
                else:
                    return [''] * len(row)
            
            styled_df = top_deals.style.apply(highlight_watchlist, axis=1)
            st.dataframe(styled_df, use_container_width=True, height=400)
            
            # Bar chart
            st.bar_chart(top_deals.set_index('DEAL_NAME')['TOTAL_EXPOSURE'], height=300)
        else:
            st.info("No deal data available")
        
        st.divider()
        
        # Exposure by industry (pie chart)
        st.subheader("Exposure by Industry")
        industry_data = get_exposure_by_industry()
        
        if not industry_data.empty:
            col1, col2 = st.columns([2, 1])
            
            with col1:
                # Create pie chart data
                fig_data = industry_data.set_index('INDUSTRY')['TOTAL_EXPOSURE']
                st.bar_chart(fig_data, height=300)
            
            with col2:
                st.dataframe(
                    industry_data[['INDUSTRY', 'TOTAL_EXPOSURE', 'DEAL_COUNT']],
                    use_container_width=True,
                    height=300
                )

# TAB 2: Deal Analysis
with tab2:
    st.header("Deal Analysis & Filters")
    
    # Filters
    col1, col2 = st.columns(2)
    with col1:
        watchlist_filter = st.selectbox(
            "Filter by Watchlist Status",
            options=["All", "None", "Watchlist", "Intensive Care"]
        )
    with col2:
        originators = get_unique_originators()
        originator_filter = st.selectbox(
            "Filter by Originator",
            options=originators
        )
    
    # Get filtered deals
    deals_df = get_all_deals(watchlist_filter, originator_filter)
    
    if not deals_df.empty:
        st.subheader(f"Found {len(deals_df)} deals")
        
        # Color code by watchlist status
        def color_watchlist(val):
            if val == 'Intensive Care':
                return 'background-color: #ff5252; color: white'
            elif val == 'Watchlist':
                return 'background-color: #ffd740'
            return ''
        
        styled_df = deals_df.style.applymap(color_watchlist, subset=['WATCHLIST'])
        st.dataframe(styled_df, use_container_width=True, height=500)
        
        # Summary statistics
        st.divider()
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Total Deals", len(deals_df))
        with col2:
            st.metric("Avg Exposure", f"${deals_df['TOTAL_EXPOSURE'].mean():,.0f}")
        with col3:
            watchlist_count = len(deals_df[deals_df['WATCHLIST'].isin(['Watchlist', 'Intensive Care'])])
            st.metric("Watchlist Deals", watchlist_count)
    else:
        st.info("No deals match the selected filters")

# TAB 3: Time Series
with tab3:
    st.header("Monthly Exposure Trends")
    
    trend_data = get_monthly_exposure_trend()
    
    if not trend_data.empty:
        # Line chart for exposure trend
        st.subheader("Total Exposure by Month-End")
        st.line_chart(
            trend_data.set_index('MONTH_END_DATE')['TOTAL_EXPOSURE'],
            height=300
        )
        
        st.divider()
        
        # Multi-metric view
        st.subheader("All Metrics Trend")
        st.line_chart(
            trend_data.set_index('MONTH_END_DATE')[['TOTAL_EXPOSURE', 'TOTAL_COMMITMENT', 'TOTAL_FAIR_VALUE']],
            height=300
        )
        
        st.divider()
        
        # Data table
        st.subheader("Monthly Summary Table")
        st.dataframe(
            trend_data.style.format({
                'TOTAL_EXPOSURE': '${:,.0f}',
                'TOTAL_COMMITMENT': '${:,.0f}',
                'TOTAL_FAIR_VALUE': '${:,.0f}'
            }),
            use_container_width=True
        )
        
        # Month-over-month change
        if len(trend_data) >= 2:
            latest_exposure = trend_data.iloc[-1]['TOTAL_EXPOSURE']
            previous_exposure = trend_data.iloc[-2]['TOTAL_EXPOSURE']
            change = ((latest_exposure - previous_exposure) / previous_exposure) * 100
            
            st.metric(
                "Month-over-Month Change",
                f"{change:+.2f}%",
                delta=f"${latest_exposure - previous_exposure:,.0f}"
            )
    else:
        st.info("No time series data available")

# TAB 4: Cortex Chat (Interactive)
with tab4:
    st.header("💬 Ask the Credit Portfolio Analyst")
    st.caption("Natural language queries powered by Cortex Agent")
    
    # Initialize chat history in session state
    if "chat_messages" not in st.session_state:
        st.session_state.chat_messages = []
    
    # Sample questions sidebar
    with st.expander("💡 Sample Questions (Click to Use)", expanded=False):
        sample_questions = [
            "Create a table of financial metrics for HealthTech Solutions",
            "Show me all of John Williams's deals in the watchlist",
            "List deals where commitment changed more than 2% between now and March 31st",
            "For each month-end starting from the beginning of the current year, what is the total exposure?",
            "Total count of deals for ACME",
            "What is the total fair value for top 10 deals"
        ]
        
        for i, question in enumerate(sample_questions, 1):
            if st.button(f"{i}. {question}", key=f"sample_{i}", use_container_width=True):
                # Add to chat input by triggering a rerun with this question
                st.session_state.pending_question = question
                st.rerun()
    
    st.divider()
    
    # Display chat history
    for message in st.session_state.chat_messages:
        with st.chat_message(message["role"]):
            st.markdown(message["content"])
    
    # Handle pending question from sample button click
    prompt = None
    if "pending_question" in st.session_state:
        prompt = st.session_state.pending_question
        del st.session_state.pending_question
    
    # Chat input (if no pending question, get from input box)
    if prompt is None:
        prompt = st.chat_input("Ask a question about the credit portfolio...")
    
    # Process user input
    if prompt:
        # Display user message
        with st.chat_message("user"):
            st.markdown(prompt)
        
        # Add user message to history
        st.session_state.chat_messages.append({"role": "user", "content": prompt})
        
        # Call Cortex Agent
        with st.chat_message("assistant"):
            with st.spinner("🤔 Analyzing your question..."):
                try:
                    # Call the Cortex Agent using Snowflake SQL
                    agent_response = session.sql(f"""
                        SELECT SNOWFLAKE_INTELLIGENCE.AGENTS.CREDIT_PORTFOLIO_ANALYST!CHAT(
                            [
                                {{'role': 'user', 'content': '{prompt.replace("'", "''")}'}}
                            ]
                        ) AS response
                    """).collect()
                    
                    if agent_response and len(agent_response) > 0:
                        # Extract response text from agent
                        response_data = agent_response[0]['RESPONSE']
                        
                        # Handle different response formats
                        if isinstance(response_data, str):
                            response_text = response_data
                        elif isinstance(response_data, dict):
                            # Extract message content from structured response
                            if 'message' in response_data:
                                response_text = response_data['message']
                            elif 'content' in response_data:
                                response_text = response_data['content']
                            else:
                                response_text = str(response_data)
                        else:
                            response_text = str(response_data)
                        
                        st.markdown(response_text)
                        
                        # Add assistant response to history
                        st.session_state.chat_messages.append({
                            "role": "assistant",
                            "content": response_text
                        })
                    else:
                        error_msg = "⚠️ No response received from the agent. Please try again."
                        st.warning(error_msg)
                        st.session_state.chat_messages.append({
                            "role": "assistant",
                            "content": error_msg
                        })
                        
                except Exception as e:
                    error_msg = f"❌ Error calling agent: {str(e)}\n\n**Troubleshooting:**\n- Verify agent exists: `SHOW AGENTS IN SCHEMA snowflake_intelligence.agents;`\n- Check agent name: `CREDIT_PORTFOLIO_ANALYST`\n- Ensure you have USAGE privilege on the agent"
                    st.error(error_msg)
                    st.session_state.chat_messages.append({
                        "role": "assistant",
                        "content": error_msg
                    })
    
    # Clear chat button
    if st.session_state.chat_messages:
        if st.button("🗑️ Clear Chat History", type="secondary"):
            st.session_state.chat_messages = []
            st.rerun()

# Footer
st.divider()
col1, col2, col3 = st.columns([2, 1, 1])
with col1:
    st.caption("💼 **Data Sources:** Credit portfolio star schema (deals, companies, funds, sponsors)")
with col2:
    st.caption("🏗️ **Tech Stack:** Snowflake Cortex AI, Streamlit in Snowflake")
with col3:
    st.caption(f"⏰ **Last Updated:** {datetime.now().strftime('%Y-%m-%d %H:%M')}")
