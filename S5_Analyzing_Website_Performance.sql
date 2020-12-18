-- LECTURE: Analyzing Top Website Pages & Entry Pages
/*
Website content analysis: Understanding which pages are seen the most by your users,
to identify where to focus on improving your business
*/

# CREATING TEMPORARY TABLES
/*
Allows you to create a dataset stored as a table which you can query
*/

USE mavenfuzzyfactory;

SELECT *
FROM website_pageviews
WHERE website_pageview_id < 1000;

# Total amount of times each page is visited
SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY pvs DESC;

# first page visited for each session
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id,
    pageview_url
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;

CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;

# runs same query from the temp table
SELECT * FROM first_pageview;

# name of landing page and amount of sessions that land on this page
SELECT
    website_pageviews.pageview_url AS landing_page, -- "entry page"
    COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pv_id = website_pageviews.website_pageview_id;
        
-- ASSIGNMENT: Finding Top Website Pages
SELECT * FROM website_pageviews;

SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) as sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;

-- ASSIGNMENT: Finding Top Entry Pages
SELECT * FROM website_pageviews;

# Find first pageview for each session
SELECT 
	MIN(website_pageview_id),
    website_session_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

DROP TABLE IF EXISTS first_pageview_per_session;

# Put above query into a temporary table
CREATE TEMPORARY TABLE first_pageview_per_session
SELECT 
	MIN(website_pageview_id) AS first_pageview,
    website_session_id
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT
	pageview_url AS landing_page, 
    COUNT(DISTINCT first_pageview_per_session.website_session_id) AS sessions_hitting_this_landing_page
FROM first_pageview_per_session
	LEFT JOIN website_pageviews
	ON first_pageview_per_session.first_pageview = website_pageviews.website_pageview_id
GROUP BY pageview_url;

SELECT 
    *
FROM
    orders;
    
-- LECTURE: Analyzing Bounce Rates & Landing Page Tests

/*
Landing page analysis and testing: Understanding performance of your key landing pages
and then testing to improve your results
*/

USE mavenfuzzyfactory;

# BUSINESS CONTEXT: Find landing page performance for a certain time period

# Step 1: Find first website_pageview_id for relevant sessions
# Step 2: Identify landing page for each session
# Step 3: Count pageviews for each session (bounce session: no pageviews after that the first pageview)
# Step 4: Summarize total sessions abd bounced sessions by landing page

# find minimum website pageview id associated with each relevant session
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
	website_pageviews.website_session_id;
    
# temporary table of the query above
CREATE TEMPORARY TABLE first_pageviews_demo
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
	website_pageviews.website_session_id;
    
SELECT * FROM first_pageviews_demo;

# landing page for each session
CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT
	first_pageviews_demo.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews_demo.min_pageview_id;
        
SELECT * FROM sessions_w_landing_page_demo;

# Next, make a table for count of pageviews per session, but only for those with 1 count of pageview (bounced session)

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page_demo
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_w_landing_page_demo.website_session_id
GROUP BY
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1; -- count_of_pages_viewed = 1

SELECT * FROM bounced_sessions_only;

# combine bounced and non-bounced sessions
SELECT
	sessions_w_landing_page_demo.landing_page,
    sessions_w_landing_page_demo.website_session_id,
    bounced_sessions_only.website_session_id AS bounced_website_session_id
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
ORDER BY
	sessions_w_landing_page_demo.website_session_id;

# Run a count of records for our final output
SELECT
	sessions_w_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) / COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS bounce_rate
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only
		ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
GROUP BY sessions_w_landing_page_demo.landing_page;