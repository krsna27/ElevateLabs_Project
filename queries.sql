q1 = """
SELECT 
    category,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit)*100.0 / SUM(revenue), 2) AS profit_margin_pct
FROM retail_data
GROUP BY category
ORDER BY total_profit DESC;
"""
pd.read_sql_query(q1, conn)


q3 = """
SELECT 
    product_id, product_name, category,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit)*100.0/SUM(revenue),2) AS profit_margin_pct
FROM retail_data
GROUP BY product_id, product_name, category
ORDER BY total_profit DESC
LIMIT 10;
"""
pd.read_sql_query(q3, conn)

-- queries.sql
-- Adapted for table name: retail_data (SQLite table created from retail_clean.csv)
-- Column names used: order_id, order_date, product_id, product_name, category, country (region), quantity, unit_price, unit_cost, revenue, cost, profit, profit_margin_pct

----------------------------------------------------------------
-- 0. Quick: show table schema (SQLite)
----------------------------------------------------------------
PRAGMA table_info('retail_data');

----------------------------------------------------------------
-- 1. Profitability by Category (category-level)
----------------------------------------------------------------
SELECT
  category,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(SUM(cost), 2) AS total_cost,
  ROUND(SUM(profit), 2) AS total_profit,
  CASE WHEN SUM(revenue)=0 THEN 0
       ELSE ROUND(SUM(profit)*100.0 / SUM(revenue), 2)
  END AS profit_margin_pct,
  SUM(quantity) AS total_units_sold
FROM retail_data
GROUP BY category
ORDER BY total_profit DESC;

----------------------------------------------------------------
-- 2. Top N products by Profit (product-level)
----------------------------------------------------------------
SELECT
  product_id,
  product_name,
  category,
  SUM(quantity) AS units_sold,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(SUM(cost), 2) AS total_cost,
  ROUND(SUM(profit), 2) AS total_profit,
  CASE WHEN SUM(revenue)=0 THEN 0
       ELSE ROUND(SUM(profit)*100.0 / SUM(revenue), 2)
  END AS profit_margin_pct
FROM retail_data
GROUP BY product_id, product_name, category
ORDER BY total_profit DESC
LIMIT 50;

----------------------------------------------------------------
-- 3. Bottom (loss-making) products
----------------------------------------------------------------
SELECT
  product_id,
  product_name,
  category,
  SUM(quantity) AS units_sold,
  ROUND(SUM(revenue), 2) AS total_revenue,
  ROUND(SUM(profit), 2) AS total_profit,
  CASE WHEN SUM(revenue)=0 THEN 0
       ELSE ROUND(SUM(profit)*100.0 / SUM(revenue), 2)
  END AS profit_margin_pct
FROM retail_data
GROUP BY product_id, product_name, category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 50;

----------------------------------------------------------------
-- 4. Monthly revenue & profit per category (seasonality)
----------------------------------------------------------------
SELECT
  STRFTIME('%Y-%m', order_date) AS month,
  category,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SUM(profit), 2) AS profit
FROM retail_data
GROUP BY month, category
ORDER BY month ASC, revenue DESC;

----------------------------------------------------------------
-- 5. Revenue & Profit by Region (country)
----------------------------------------------------------------
SELECT
  country AS region,
  ROUND(SUM(revenue),2) AS total_revenue,
  ROUND(SUM(profit),2) AS total_profit,
  CASE WHEN SUM(revenue)=0 THEN 0
       ELSE ROUND(SUM(profit)*100.0 / SUM(revenue), 2)
  END AS profit_margin_pct
FROM retail_data
GROUP BY region
ORDER BY total_revenue DESC;

----------------------------------------------------------------
-- 6. Slow movers / low-margin candidates (heuristic)
-- Criteria: products with low margin (margin < 5%) OR low sales volume
----------------------------------------------------------------
SELECT
  product_id,
  product_name,
  category,
  SUM(quantity) AS units_sold_last_period,
  ROUND(SUM(revenue),2) AS revenue,
  ROUND(SUM(profit),2) AS profit,
  CASE WHEN SUM(revenue)=0 THEN 0
       ELSE ROUND(SUM(profit)*100.0 / SUM(revenue), 2)
  END AS profit_margin_pct
FROM retail_data
GROUP BY product_id, product_name, category
HAVING profit_margin_pct < 5 OR SUM(quantity) < 10
ORDER BY profit_margin_pct ASC, units_sold_last_period ASC
LIMIT 200;


