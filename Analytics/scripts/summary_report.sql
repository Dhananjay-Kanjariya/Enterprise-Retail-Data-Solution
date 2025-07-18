/*
===============================================================================
Enterprise Retail Analytics Summary Report
===============================================================================
Project: Enterprise-Retail-Data-Warehouse-and-Analytics
Author: Dhananjay Kanjariya
Purpose:
    This SQL script contains a comprehensive suite of analytics and reporting queries 
    performed on the Gold Layer of the Enterprise Retail Data Warehouse project. 
    It includes ranking, trend, segmentation, performance, and customer/product analysis.

    The objective is to uncover business insights across product performance, 
    customer behavior, and sales trends for data-driven decision-making.

Data Source:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_products

Target Users:
    - Business Analysts
    - Data Scientists
    - Decision Makers
===============================================================================
*/

-- =============================================================================
-- 1. RANKING ANALYSIS
-- =============================================================================

-- Top 5 Products by Total Revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Bottom 5 Products by Total Revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Top 10 Customers by Total Spending
SELECT TOP 10
    c.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- Bottom 3 Customers by Order Count
SELECT TOP 3
    c.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders;

-- =============================================================================
-- 2. CHANGE OVER TIME ANALYSIS
-- =============================================================================

-- Monthly Sales Trend
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- Monthly Aggregation Using FORMAT
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY order_month;

-- =============================================================================
-- 3. CUMULATIVE ANALYSIS
-- =============================================================================

-- Running Total and Moving Average (Yearly)
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t;

-- =============================================================================
-- 4. PERFORMANCE ANALYSIS (YoY, MoM)
-- =============================================================================

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above Avg'
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
        WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

-- =============================================================================
-- 5. DATA SEGMENTATION ANALYSIS
-- =============================================================================

-- Segment Products by Cost
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- Segment Customers by Spending and Lifespan
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- =============================================================================
-- 6. PART-TO-WHOLE ANALYSIS
-- =============================================================================

-- Category Contribution to Total Sales
WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- =============================================================================
-- 7. CUSTOMER & PRODUCT REPORT VIEWS (PRE-CREATED)
-- =============================================================================

-- gold.report_customers
-- gold.report_products

-- These views contain pre-aggregated customer/product metrics for dashboards:
-- - Segmentations, KPIs (recency, AOV, monthly revenue)
-- - Age groups, lifespan, spending profiles, product tiers, etc.

SELECT * FROM gold.report_customers;
SELECT * FROM gold.report_products;