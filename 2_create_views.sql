USE brazilian_ecommerce;

-- For order_items, add respective product, customer, and seller info for each row
CREATE VIEW itemized_staging AS
WITH order_items_grouped AS (
-- Aggregate same products purchased in the same order
SELECT order_id, product_id, seller_id,
	MIN(shipping_limit_date) as shipping_limit_date,
	COUNT(*) AS qty, -- Quantity of the product that was ordered
    MAX(price) AS price_per_unit,
    MAX(freight_value) AS freight_value_per_unit,
    SUM(price + freight_value) AS total_price
FROM order_items
GROUP BY order_id, product_id, seller_id
),
product_categories AS (
-- Get English-translated product category names for each product_id
SELECT
	p.product_id,
	COALESCE(
		TRIM('\r' FROM t.product_category_name_english),
		NULLIF(p.product_category_name, ''), -- handle empty strings as NULL
		'not_defined' -- if product_category_name is blank
	) AS product_category
FROM products p
LEFT JOIN product_category_name_translation t
ON p.product_category_name = t.product_category_name
)
SELECT
	i.order_id, i.product_id, p.product_category,
	o.order_purchase_timestamp AS purchased_on, i.shipping_limit_date,
    i.qty, i.price_per_unit, i.freight_value_per_unit, i.total_price,
	c.customer_zip_code_prefix, c.customer_city, c.customer_state,
    s.seller_zip_code_prefix, s.seller_city, s.seller_state
FROM order_items_grouped i
LEFT JOIN product_categories p
ON i.product_id = p.product_id
LEFT JOIN orders o
ON i.order_id = o.order_id
LEFT JOIN customers c
ON o.customer_id = c.customer_id
LEFT JOIN sellers s
ON i.seller_id = s.seller_id
ORDER BY purchased_on;

-- Join orders table with aggregated order_items, customers, and reviews data
CREATE VIEW orders_staging AS
WITH order_items_agg AS (
SELECT
order_id,
SUM(total_price) AS order_total,
MIN(shipping_limit_date) AS shipping_limit_date
FROM itemized_staging
GROUP BY order_id
),
reviews AS (
-- Get the average review score of each order (there may be different scores for each item in the same order)
SELECT 
	order_id,
	ROUND(AVG(review_score)) AS review_score
FROM order_reviews
GROUP BY order_id
)
SELECT o.order_id, o.order_status, i.order_total,
    o.order_purchase_timestamp AS purchased_on,
    o.order_approved_at AS approved_at,
	i.shipping_limit_date,
    o.order_delivered_carrier_date AS delivered_carrier_date,
    o.order_delivered_customer_date AS delivered_customer_date,
    o.order_estimated_delivery_date AS estimated_delivery_date,
	c.customer_unique_id, c.customer_zip_code_prefix, c.customer_city, c.customer_state,
	r.review_score
FROM orders o
LEFT JOIN order_items_agg i
ON o.order_id = i.order_id
LEFT JOIN customers c
ON o.customer_id = c.customer_id
LEFT JOIN reviews r
ON o.order_id = r.order_id
ORDER BY purchased_on;

-- 
CREATE VIEW payments_staging AS
SELECT
	p.order_id, p.payment_type,
	p.payment_value,
    -- If payment_installments is 0, assign number of installment as 1
    CASE
        WHEN p.payment_installments = 0 THEN 1 
        ELSE p.payment_installments 
    END AS num_installments,
    ROUND(
		p.payment_value /
        CASE
			WHEN p.payment_installments = 0 THEN 1 
			ELSE p.payment_installments 
		END, 2
    ) as avg_installment_value, -- average installment value
    c.customer_zip_code_prefix, c.customer_city, c.customer_state
FROM order_payments p
LEFT JOIN orders o
ON p.order_id = o.order_id
LEFT JOIN customers c
ON o.customer_id = c.customer_id;