CREATE DATABASE brazilian_ecommerce;

USE brazilian_ecommerce;

-- Create Tables

CREATE TABLE customers (
	customer_id VARCHAR(50) PRIMARY KEY,
	customer_unique_id VARCHAR(50),
	customer_zip_code_prefix INT,
	customer_city VARCHAR(100),
	customer_state VARCHAR(2)
);

CREATE TABLE order_items (
	order_id VARCHAR(50),
	order_item_id INT,
	product_id VARCHAR(50),
	seller_id VARCHAR(50),
	shipping_limit_date DATETIME,
	price DECIMAL(10,2),
	freight_value DECIMAL(10,2),
	PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
	order_id VARCHAR(50),
	payment_sequential INT,
	payment_type VARCHAR(20),
	payment_installments INT,
	payment_value DECIMAL(10,2),
	PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
	review_id VARCHAR(50),
	order_id VARCHAR(50),
	review_score INT,
	review_comment_title TEXT,
	review_comment_message TEXT,
	review_creation_date VARCHAR(50),
	review_answer_timestamp VARCHAR(50),
	PRIMARY KEY (review_id, order_id)
);

CREATE TABLE orders (
	order_id VARCHAR(50) PRIMARY KEY,
	customer_id VARCHAR(50),
	order_status VARCHAR(20),
	order_purchase_timestamp DATETIME,
	order_approved_at DATETIME,
	order_delivered_carrier_date DATETIME,
	order_delivered_customer_date DATETIME,
	order_estimated_delivery_date DATETIME
);

CREATE TABLE products (
	product_id VARCHAR(50) PRIMARY KEY,
	product_category_name VARCHAR(100),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

CREATE TABLE sellers (
	seller_id VARCHAR(50) PRIMARY KEY,
	seller_zip_code_prefix INT,
	seller_city VARCHAR(100),
	seller_state VARCHAR(2)
);

CREATE TABLE product_category_name_translation (
	product_category_name VARCHAR(100),
	product_category_name_english VARCHAR(100)
);

-- Load CSV files

LOAD DATA LOCAL INFILE 'olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
-- Do not escape with backslash to avoid incorrectly escaping
-- double quotes that enclose text ending with '\'
ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, customer_id, order_status, order_purchase_timestamp,
	@approved_at, @carrier_date, @customer_date,
    order_estimated_delivery_date)
-- Convert empty strings to NULL for datetime fields
SET
	order_approved_at = NULLIF(@approved_at, ''),
	order_delivered_carrier_date = NULLIF(@carrier_date, ''),
	order_delivered_customer_date = NULLIF(@customer_date, '');

LOAD DATA LOCAL INFILE 'olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_category_name,
	@name_len, @desc_len, @photos_qty,
	@weight, @length, @height, @width)
-- Convert empty strings to NULL for numeric fields
SET
	product_name_length = NULLIF(@name_len, ''),
	product_description_length = NULLIF(@desc_len, ''),
	product_photos_qty = NULLIF(@photos_qty, ''),
	product_weight_g = NULLIF(@weight, ''),
	product_length_cm = NULLIF(@length, ''),
	product_height_cm = NULLIF(@height, ''),
	product_width_cm = NULLIF(@width, '');

LOAD DATA LOCAL INFILE 'olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;