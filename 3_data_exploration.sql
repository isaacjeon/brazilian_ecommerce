USE brazilian_ecommerce;

-- Create temporary tables from views for EDA

DROP TEMPORARY TABLE IF EXISTS orders_temp;
CREATE TEMPORARY TABLE orders_temp AS
SELECT * FROM orders_staging;

DROP TEMPORARY TABLE IF EXISTS items_temp;
CREATE TEMPORARY TABLE items_temp AS
SELECT * FROM itemized_staging;

DROP TEMPORARY TABLE IF EXISTS payments_temp;
CREATE TEMPORARY TABLE payments_temp AS
SELECT * FROM payments_staging;


-- EDA

-- Distribution summaries for order_staging
SELECT
	COUNT(order_id) AS order_count,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_count,
	ROUND(AVG(order_total), 2) AS average_total,
    MIN(order_total) AS min_total,
    MAX(order_total) AS max_total,
    ROUND(STDDEV(order_total), 2) AS std_dev,
    ROUND(AVG(review_score), 2) as avg_review_score
FROM orders_temp;

-- Get the number of unique customers that made a specific amount of orders
WITH customer_order_counts AS (
SELECT COUNT(*) AS order_count
FROM orders_temp
GROUP BY customer_unique_id
)
SELECT order_count, COUNT(*) AS num_customers
FROM customer_order_counts
GROUP BY order_count
ORDER BY order_count;

-- Monthly distribution summaries for order_total
SELECT
	DATE_FORMAT(purchased_on, '%Y-%m') AS month,
	COUNT(*) AS order_count,
    SUM(order_total) AS total,
	ROUND(AVG(order_total), 2) AS average_total,
    MIN(order_total) AS min_total,
    MAX(order_total) AS max_total,
    ROUND(STDDEV(order_total), 2) AS std_dev,
    ROUND(AVG(review_score), 2) as avg_review_score
FROM orders_temp
GROUP BY month
ORDER BY month;

-- Total count of orders grouped by order status
SELECT order_status, COUNT(*) as count
FROM orders_temp
GROUP BY order_status;

-- Get rows with null order_total values
SELECT *
FROM orders_temp
WHERE order_total IS NULL;

-- Average review score by month
SELECT
	DATE_FORMAT(purchased_on, '%Y-%m') AS month,
    COUNT(*) AS count,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM orders_temp
GROUP BY month
ORDER BY month;

-- Average order_total and review score by state
SELECT
    customer_state,
    COUNT(*) AS count,
	ROUND(AVG(order_total), 2) AS avg_order_total,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM orders_temp
GROUP BY customer_state
ORDER BY avg_order_total DESC;

/*
For each order, get:
- the order ID, order status, and review score
- the number of days between purchased and delivered dates
- the difference in days between shipping_limit_date and delivered_carrier_date (negative means early)
- the difference in days between actual and estimated delivery dates (negative means early)
- if the customer and seller are located in the same city/state (multiple items were purchased from
	a different seller, 'no' if at least one seller is located in a different city/state)
*/
WITH same_loc_shipping AS
(
SELECT
	order_id,
	IF(MIN(customer_city = seller_city) = 1, 'yes', 'no') AS same_city_shipping,
    IF(MIN(customer_state = seller_state) = 1, 'yes', 'no') AS same_state_shipping
FROM items_temp
GROUP BY order_id
)
SELECT
	o.order_id, order_status, review_score,
	DATEDIFF(DATE(delivered_carrier_date), DATE(purchased_on)) AS days_to_ship,
    DATEDIFF(DATE(delivered_customer_date), DATE(purchased_on)) AS days_to_deliver,
	DATEDIFF(DATE(delivered_carrier_date), DATE(shipping_limit_date)) AS carrier_delivery_delay_days,
	DATEDIFF(DATE(delivered_customer_date), DATE(estimated_delivery_date)) AS customer_delivery_delay_days,
    same_city_shipping, same_state_shipping
FROM orders_temp o
LEFT JOIN same_loc_shipping s
ON o.order_id = s.order_id;

-- Get averages for days_to_deliver and delivery delays grouped by review_score (1 through 5)
SELECT
	review_score,
	ROUND(AVG(DATEDIFF(DATE(delivered_carrier_date), DATE(purchased_on))), 2) AS avg_days_to_ship,
    ROUND(AVG(DATEDIFF(DATE(delivered_customer_date), DATE(purchased_on))), 2) AS avg_days_to_deliver,
	ROUND(AVG(DATEDIFF(DATE(delivered_carrier_date), DATE(shipping_limit_date))), 2) AS avg_carrier_delivery_delay_days,
	ROUND(AVG(DATEDIFF(DATE(delivered_customer_date), DATE(estimated_delivery_date))), 2) AS avg_customer_delivery_delay_days
FROM orders_temp
GROUP BY review_score
ORDER BY review_score;

-- Get averages for days_to_deliver, delivery delays, and review_score grouped by same city and same state shipping
WITH same_loc_shipping AS
(
SELECT
	order_id,
	IF(MIN(customer_city = seller_city) = 1, 'yes', 'no') AS same_city_shipping,
    IF(MIN(customer_state = seller_state) = 1, 'yes', 'no') AS same_state_shipping
FROM items_temp
GROUP BY order_id
)
SELECT
    same_city_shipping, same_state_shipping,
	ROUND(AVG(review_score), 2) AS avg_review_score,
	ROUND(AVG(DATEDIFF(DATE(delivered_carrier_date), DATE(purchased_on))), 2) AS avg_days_to_ship,
    ROUND(AVG(DATEDIFF(DATE(delivered_customer_date), DATE(purchased_on))), 2) AS avg_days_to_deliver,
	ROUND(AVG(DATEDIFF(DATE(delivered_carrier_date), DATE(shipping_limit_date))), 2) AS avg_carrier_delivery_delay_days,
	ROUND(AVG(DATEDIFF(DATE(delivered_customer_date), DATE(estimated_delivery_date))), 2) AS avg_customer_delivery_delay_days
FROM orders_temp o
LEFT JOIN same_loc_shipping s
ON o.order_id = s.order_id
GROUP BY same_city_shipping, same_state_shipping;

-- Get rows where customer and seller cities are the same but states are different
SELECT * FROM items_temp
WHERE customer_city = seller_city
AND customer_state != seller_state;

-- Get list of all city, state pairs for customers and sellers, and
-- find all cities where the customer and seller states don't match
WITH customer_locs AS (
SELECT DISTINCT customer_city, customer_state
FROM orders_temp
),
seller_locs AS (
SELECT DISTINCT seller_city, seller_state
FROM items_temp
)
SELECT *
FROM customer_locs
JOIN seller_locs
ON customer_city = seller_city
AND customer_state != seller_state
ORDER BY seller_state, seller_city;

-- Total, average, and max number of items purchased per order
SELECT
    SUM(qty_purchased) as total_qty_purchased,
    ROUND(AVG(qty_purchased), 2) as avg_qty_purchased,
	MAX(qty_purchased) as max_qty_purchased
FROM (
	-- Get total number of items purchased for each order
	SELECT SUM(qty) as qty_purchased
	FROM items_temp
    GROUP BY order_id
    ) i;
    
-- Monthly total, average, and max number of items purchased per order
SELECT
	month,
    SUM(qty_purchased) as total_qty_purchased,
    ROUND(AVG(qty_purchased), 2) as avg_qty_purchased,
	MAX(qty_purchased) as max_qty_purchased
FROM (
	-- Get month and total number of items purchased for each order
	SELECT order_id,
	DATE_FORMAT(MIN(purchased_on), '%Y-%m') AS month,
    SUM(qty) as qty_purchased
	FROM items_temp
    GROUP BY order_id
    ) i
GROUP BY month
ORDER BY month;

-- Aggregate values for each unique product
SELECT
	product_id,
    MIN(product_category) AS category,
	COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(qty) AS total_qty,
    SUM(total_price) AS total_value,
	MAX(price_per_unit) AS price_per_unit
FROM items_temp
GROUP BY product_id
ORDER BY total_qty DESC;

-- Total qty purchased and avg, min, and max price_per_unit by product_category
SELECT
	product_category,
	SUM(qty) AS total_qty,
	ROUND(AVG(price_per_unit), 2) AS avg_ppu,
    MIN(price_per_unit) AS min_ppu,
    MAX(price_per_unit) AS max_ppu
FROM items_temp
GROUP BY product_category
ORDER BY total_qty DESC;

-- Total quantity of items purchased by customers and sold by sellers in each state
WITH total_purchased AS (
SELECT
	customer_state AS state,
	SUM(qty) as total_qty_purchased
FROM items_temp
GROUP BY customer_state
),
total_sold AS (
SELECT
	seller_state AS state,
	SUM(qty) as total_qty_sold
-- Use view instead of temp table, since opening temp table more than once causes an error
FROM itemized_staging
GROUP BY seller_state
)
SELECT p.state, p.total_qty_purchased, s.total_qty_sold
FROM total_purchased p
JOIN total_sold s
ON p.state = s.state
ORDER BY total_qty_purchased DESC, total_qty_sold DESC;

-- Top 3 (or more in case of ties) purchased product_category by customer_state
WITH ranked_categories AS (
SELECT
	customer_state,
	RANK() OVER (PARTITION BY customer_state ORDER BY SUM(qty) DESC) AS category_rank,
	product_category,
    SUM(qty) AS total_qty_purchased
FROM items_temp
GROUP BY customer_state, product_category
)
SELECT customer_state, product_category, total_qty_purchased
FROM ranked_categories
WHERE category_rank <= 3
ORDER BY customer_state, category_rank;

-- Top 3 (or more in case of ties) sold product_category by seller_state
WITH ranked_categories AS (
SELECT
	seller_state,
	RANK() OVER (PARTITION BY seller_state ORDER BY SUM(qty) DESC) AS category_rank,
	product_category,
    SUM(qty) AS total_qty_sold
FROM items_temp
GROUP BY seller_state, product_category
)
SELECT seller_state, product_category, total_qty_sold
FROM ranked_categories
WHERE category_rank <= 3
ORDER BY seller_state, category_rank;

-- Distribution values for each payment_type
SELECT
	payment_type,
    COUNT(DISTINCT order_id) as order_count,
	ROUND(AVG(payment_value), 2) AS avg_pay_val,
    MIN(payment_value) AS min_pay_val,
    MAX(payment_value) AS max_pay_val,
	ROUND(AVG(num_installments), 2) AS avg_num_installments,
    MIN(num_installments) AS min_num_installments,
    MAX(num_installments) AS max_num_installments
FROM payments_temp
GROUP BY payment_type
ORDER BY order_count DESC;

-- Average number of payment options used in each order (different payment options of the same type are counted separately
-- e.g. two different credit cards used in the same order has num_payment_options = 2)
SELECT ROUND(AVG(num_payment_options), 2) AS avg_num_payment_options
FROM (
	SELECT order_id, COUNT(*) AS num_payment_options
    FROM payments_temp
    GROUP BY order_id
) t;

-- Get rows where payment_type is not_defined or payment_value is 0
SELECT *
FROM payments_temp
WHERE payment_type = 'not_defined'
OR payment_value = 0;

-- Average payment_value for each payment_type by customer_state
SELECT
	customer_state,
    COUNT(DISTINCT order_id) AS order_count,
	ROUND(AVG(CASE WHEN payment_type = 'credit_card' THEN payment_value END), 2) AS credit_avg,
	ROUND(AVG(CASE WHEN payment_type = 'debit_card' THEN payment_value END), 2) AS debit_avg,
	ROUND(AVG(CASE WHEN payment_type = 'boleto' THEN payment_value END), 2) AS boleto,
	ROUND(AVG(CASE WHEN payment_type = 'voucher' THEN payment_value END), 2) AS voucher_avg
FROM payments_temp
GROUP BY customer_state;

-- Ratio of orders that used each payment type by state (may add up to over 1)
SELECT
	customer_state,
	COUNT(DISTINCT order_id) AS order_count,
	ROUND(
		COUNT(DISTINCT CASE WHEN payment_type = 'credit_card' THEN order_id END) /
        COUNT(DISTINCT order_id),
        2) AS credit_ratio,
	ROUND(
		COUNT(DISTINCT CASE WHEN payment_type = 'debit_card' THEN order_id END) /
        COUNT(DISTINCT order_id),
        2) AS debit_ratio,
	ROUND(
		COUNT(DISTINCT CASE WHEN payment_type = 'boleto' THEN order_id END) /
        COUNT(DISTINCT order_id),
        2) AS boleto_ratio,
	ROUND(
		COUNT(DISTINCT CASE WHEN payment_type = 'voucher' THEN order_id END) /
        COUNT(DISTINCT order_id),
        2) AS voucher_ratio
FROM payments_temp
GROUP BY customer_state;

-- Average num_installments and avg_installment_value for credit card purchases grouped by state
SELECT
	customer_state,
	COUNT(DISTINCT order_id) AS order_count,
    ROUND(AVG(num_installments), 2) AS avg_num_installments,
    ROUND(AVG(avg_installment_value), 2) AS avg_installment_val
FROM payments_temp
WHERE payment_type = 'credit_card'
GROUP BY customer_state;


-- Final Data Cleaning and Feature Engineering

-- Add columns for days_to_deliver, carrier_delivery_delay_days, and customer_delivery_delay_days to orders_staging
CREATE VIEW orders_final AS
SELECT *,
    DATEDIFF(DATE(delivered_carrier_date), DATE(purchased_on)) AS days_to_ship,
    DATEDIFF(DATE(delivered_customer_date), DATE(purchased_on)) AS days_to_deliver,
	DATEDIFF(DATE(delivered_carrier_date), DATE(shipping_limit_date)) AS carrier_delivery_delay_days,
	DATEDIFF(DATE(delivered_customer_date), DATE(estimated_delivery_date)) AS customer_delivery_delay_days
FROM orders_staging
WHERE DATE(purchased_on) >= '2017-01-01' AND DATE(purchased_on) <= '2018-08-31'
ORDER BY purchased_on;

/*
No change to orders_staging
Note: There seem to be some mistakes with seller_city having the wrong associated seller_state.
	This is require manual review of potentially hundreds of cities which is outside the scope of this informal project.
*/
CREATE VIEW itemized_final AS
SELECT *
FROM itemized_staging
WHERE DATE(purchased_on) >= '2017-01-01' AND DATE(purchased_on) <= '2018-08-31'
ORDER BY purchased_on;

-- Include rows from payments_staging where payment_value > 0
CREATE VIEW payments_final AS
SELECT *
FROM payments_staging
WHERE payment_value > 0
-- Only include orders between specified dates
AND order_id IN (SELECT order_id FROM orders_final);

-- Query each view
SELECT * FROM orders_final;

SELECT * FROM itemized_final;

SELECT * FROM payments_final;