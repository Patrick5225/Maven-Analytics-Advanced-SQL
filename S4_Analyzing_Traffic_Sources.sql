USE mavenfuzzyfactory;

SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM order_items;
SELECT * FROM order_item_refunds;
SELECT * FROM website_sessions;
SELECT * FROM website_pageviews;

-- LECTURE: Analyzing Top Traffic Sources
USE mavenfuzzyfactory;

SELECT 
    *
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000; # arbitrary
    
SELECT 
    utm_content, COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000
GROUP BY 1 # group by column 1
ORDER BY 2 DESC; # order by column 2
    
SELECT 
    utm_content, COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000
GROUP BY 1 # group by column 1
ORDER BY 2 DESC;

-- ASSIGNMENT: Finding Top Traffic Sources
SELECT * FROM website_sessions;

SELECT 
    utm_source, utm_campaign, http_referer, COUNT(DISTINCT website_session_id) as sessions
FROM
    website_sessions
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;

-- ASSIGNMENT: Traffic Source Conversion Rates
SELECT * FROM website_sessions;
SELECT * FROM orders;

SELECT 
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS session_to_order_conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.created_at < '2012-04-14'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND http_referer = 'https://www.gsearch.com';

-- LECTURE: Bid Optimization & Trend Analysis
/*
Bid optimization: Understanding the value of various segments of paid traffic so that
you can optimize your marketing budget
*/

/*
DATE FUNCTIONS

- MONTH()
- QUARTER()
- YEAR()
- WEEK()
- DATE()
- NOW()
*/

SELECT 
    YEAR(created_at),
    WEEK(created_at),
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
GROUP BY 1,2;

/*
CASE "PIVOTS"
*/

SELECT 
	primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS count_single_item_orders,
    COUNT(CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS count_two_item_orders
FROM orders
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

-- ASSIGNMENT: Traffic Source Trending
SELECT * FROM website_sessions;

SELECT 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND created_at < '2012-05-10'
GROUP BY YEAR(created_at), WEEK(created_at)
ORDER BY week_start_date;

-- ASSIGNMENT: Bid Optimization for Paid Traffic
SELECT * FROM orders;

SELECT
	ws.device_type,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS session_to_order_conv_rate
FROM website_sessions ws
LEFT JOIN orders o
ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-05-11' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY ws.device_type;

-- ASSIGNMENT: Trending w/ Granular Segments
SELECT * FROM website_sessions;

SELECT 
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
FROM website_sessions
WHERE created_at > '2012-04-15' AND created_at < '2012-06-09'
AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at);