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