--This is to check whether the table is loaded correctly.
SELECT *
FROM workspace.default.bright_coffee_sales_analysis
LIMIT 100;


---------------------------------------------------------------------------------------------------------------------------------------------------------------
--The query above but better
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    transaction_id,
    transaction_date,
    Monthname(transaction_date)  AS month_name,
    Dayname(transaction_date)    AS day_name,
    HOUR(transaction_time)       AS hour,
    store_location,
    product_category,
    product_type,
    product_detail,
    transaction_qty,
    unit_price,
    transaction_qty * unit_price AS revenue
FROM workspace.default.bright_coffee_sales_analysis;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking the date range(Checking seasons: Hot = Low revenue, Cold = High revenue)
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--When did data capturing start? Data capturing started on 2023-01-01
SELECT min(transaction_date) as start_date_data_capture
FROM workspace.default.bright_coffee_sales_analysis;

--When did data capture stop? Data capturing ended on 2023-06-30
SELECT max(transaction_date) as end_date_data_capture
FROM workspace.default.bright_coffee_sales_analysis;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking store location
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Store locations: Lower Manhattan, Hell's Kitchen, Astoria
SELECT DISTINCT(store_location)
FROM workspace.default.bright_coffee_sales_analysis;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking products sold across all the stores
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT(product_category)
FROM workspace.default.bright_coffee_sales_analysis;

SELECT DISTINCT(product_detail)
FROM workspace.default.bright_coffee_sales_analysis;

SELECT DISTINCT(product_category) AS category,
                product_detail AS product_name
FROM workspace.default.bright_coffee_sales_analysis;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking how many products are sold at each store
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Lower Manhattan
SELECT DISTINCT(product_category) AS category,
                product_detail AS product_name,
                COUNT(DISTINCT transaction_id) AS number_of_sales
FROM workspace.default.bright_coffee_sales_analysis
WHERE store_location = 'Lower Manhattan'
GROUP BY product_category,
         product_name;

--Hell's Kitchen
SELECT DISTINCT(product_category) AS category,
                product_detail AS product_name,
                COUNT(DISTINCT transaction_id) AS number_of_sales
FROM workspace.default.bright_coffee_sales_analysis
WHERE store_location = 'Hell''s Kitchen'
GROUP BY product_category,
         product_name;

--Astoria
SELECT DISTINCT(product_category) AS category,
                product_detail AS product_name,
                COUNT(DISTINCT transaction_id) AS number_of_sales
FROM workspace.default.bright_coffee_sales_analysis
WHERE store_location = 'Astoria'
GROUP BY product_category,
         product_name;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Best performing products 
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT(product_category) AS category,
                product_detail AS product_name,
                COUNT(DISTINCT transaction_id) AS number_of_sales
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY product_category,
         product_name
ORDER BY number_of_sales DESC
LIMIT 20;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Worst performing products
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT(product_category) AS category,
                product_detail AS product_name,
                COUNT(DISTINCT transaction_id) AS number_of_sales
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY product_category,
         product_name
ORDER BY number_of_sales ASC
LIMIT 20;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Average price of products across all stores
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT AVG(unit_price) AS avg_price
FROM workspace.default.bright_coffee_sales_analysis;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Best performing category : Coffee
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT(product_category) AS category,
            COUNT(DISTINCT transaction_id) AS number_of_sales
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY product_category
ORDER BY number_of_sales DESC
LIMIT 1;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Worst performing category : Packeged Chocolate
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT(product_category) AS category,
            COUNT(DISTINCT transaction_id) AS number_of_sales
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY product_category
ORDER BY number_of_sales ASC
LIMIT 1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking how much each store makes
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT store_location,
       SUM(unit_price * transaction_qty) AS total_revenue
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY store_location
ORDER BY total_revenue DESC;

--Hell's Kitchen: R 236 511,17
--Astoria: R 232 243,91
--Lower Manhattan: R 230 057,25

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking product prices prices and the average price
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT MIN(unit_price) AS cheapest_product
FROM workspace.default.bright_coffee_sales_analysis;

SELECT MAX(unit_price) AS expensive_product
FROM workspace.default.bright_coffee_sales_analysis;

SELECT AVG(unit_price) AS avg_price
FROM workspace.default.bright_coffee_sales_analysis;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Counting the total number of transactions across all stores
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
       COUNT(DISTINCT transaction_id) AS number_of_sales,
       store_location AS store
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY store_location
ORDER BY number_of_sales DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking the revenue per transaction
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  SELECT transaction_id,
        transaction_date,
        Dayname(transaction_date) AS Day_name,
        Monthname(transaction_date) AS Month_name,
        transaction_qty*unit_price AS revenue_per_tnx
  FROM workspace.default.bright_coffee_sales_analysis;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking the revenue per day
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
      transaction_date,
      Dayname(transaction_date) AS Day_name,
      Monthname(transaction_date) AS Month_name,
      COUNT(DISTINCT transaction_id) AS Number_of_sales,
      SUM(transaction_qty*unit_price) AS revenue_per_day
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY transaction_date,
         Day_name,
         Month_name;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking total number of products and revenue made on every day of the week  - Peak days VS Slow days
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
       Dayname(transaction_date) AS Day_name,
       COUNT(DISTINCT product_id) AS Number_of_products_sold,
       SUM(transaction_qty*unit_price) AS Amount_of_revenue
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY Day_name;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Checking number products and amount of revenue made on every day of the week for 6 months
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT transaction_date,
       Dayname(transaction_date) AS Day_name,
       SUM(transaction_qty*unit_price) AS revenue_per_day
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY transaction_date,
         Day_name
ORDER BY revenue_per_day DESC;
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Revenue per Hour
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
      HOUR(transaction_time) AS Hour,
      SUM(transaction_qty*unit_price) AS revenue_per_hour   
FROM workspace.default.bright_coffee_sales_analysis
WHERE HOUR(transaction_time) BETWEEN 7 AND 19
GROUP BY HOUR(transaction_time)
ORDER BY Hour ASC;


---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Revenue per month
----------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
      Monthname(transaction_date) AS Month_name,
      SUM(transaction_qty*unit_price) AS revenue_per_month
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY  Monthname(transaction_date);

--Warm months: January, February → Made less money compared to colder months
--Cold months: March, April, May, June → Made more money compared to warm months
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Time Buckets : Peak VS Slow hours
--------------------------------------------------------------------------------------------------------------------------------------------------------------
--Morning
SELECT
      HOUR(transaction_time) AS Hour,
      SUM(transaction_qty*unit_price) AS revenue_per_hour
FROM workspace.default.bright_coffee_sales_analysis
WHERE HOUR(transaction_time) BETWEEN 7 AND 11
GROUP BY HOUR(transaction_time)
ORDER BY Hour ASC;

--Afternoon
SELECT
      HOUR(transaction_time) AS Hour,
      SUM(transaction_qty*unit_price) AS revenue_per_hour
FROM workspace.default.bright_coffee_sales_analysis
WHERE HOUR(transaction_time) BETWEEN 12 AND 16
GROUP BY HOUR(transaction_time)
ORDER BY Hour ASC;

--Evening
SELECT
      HOUR(transaction_time) AS Hour,
      SUM(transaction_qty*unit_price) AS revenue_per_hour
FROM workspace.default.bright_coffee_sales_analysis
WHERE HOUR(transaction_time) BETWEEN 16 AND 19
GROUP BY HOUR(transaction_time)
ORDER BY Hour ASC;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT  transaction_date AS Purchase_date,
        DAYNAME(transaction_date) AS Day_name,
        MONTHNAME(transaction_date) AS Month_name,
        DATE_FORMAT(transaction_time, 'HH:mm:ss') AS Purchase_time,
        DAYOFMONTH(transaction_date) AS Day_of_Month,
        CASE 
            WHEN Day_name IN ('Sun' ,'Sat') THEN 'Weekend'
            WHEN Day_name IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri') THEN 'Weekday'

        END AS Day_Classification,

        CASE 
            WHEN DATE_FORMAT(transaction_time, 'HH:mm:ss') BETWEEN '07:00:00' AND '11:59:59' THEN 'Morning'
            WHEN DATE_FORMAT(transaction_time, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
            WHEN DATE_FORMAT(transaction_time, 'HH:mm:ss') >= '17:00:00 ' THEN 'Evening'

      END AS Time_of_day,

        COUNT(DISTINCT transaction_id) AS Number_of_sales,
        COUNT(DISTINCT product_id) AS Number_of_products,
        COUNT(DISTINCT store_id) AS Number_of_stores,

        SUM(transaction_qty*unit_price) AS Revenue,

        CASE 
            WHEN Revenue >= 50 THEN 'Low Spend'
            WHEN Revenue BETWEEN 51 AND 100 THEN 'Medium Spend'
            WHEN Revenue BETWEEN 101 AND 150 THEN 'High Spend'
            ELSE 'Very High Spend'

      END AS Spend_Classification,

        store_location,
        product_category,
        product_detail
FROM workspace.default.bright_coffee_sales_analysis
GROUP BY transaction_date,
         DAYNAME(transaction_date),
         MONTHNAME(transaction_date),
         DATE_FORMAT(transaction_time,'HH:mm:ss'),
         DAYOFMONTH(transaction_date),
         store_location,
         product_category,
         product_detail;

       
