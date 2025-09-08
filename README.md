# Brazilian E-Commerce Data Analysis Project

This project explores the **Brazilian E-Commerce Public Dataset by Olist** from Kaggle, involving order data across several dimensions including customer and seller demographics, product categories, payment types, delivery logistics, and review scores. It utilizes **MySQL** for data structuring, cleaning, and exploratory data analysis (EDA), and **Tableau** for building interactive dashboards for visualizing monthly sales performance, regional trends, delivery times, and customer purchasing behavior and satisfaction to uncover operational and marketing insights.

## How to Use

The Tableau dashboard may be viewed on [Tableau Public](https://public.tableau.com/views/BrazilianE-Commerce_17547219521680/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link). The following steps may also be taken to use the files in this repository:

1. Download the CSV files from the Kaggle source linked below (`olist_geolocation_dataset.csv` is not used for this project).
2. Clone the repository
3. Import data into MySQL and run the sql scripts in the following order:
   - `1_load_data.sql`
   - `2_create_views.sql`
   - `3_data_exploration`
4. Tableau Public cannot connect directly to MySQL, so the three views orders_final, itemized_final, and payments_final should be exported as csv files `orders.csv`, `items.csv`, and `payments.csv` respectively.
   - If using MySQL Workbench, the Table Data Export Wizard should not be used. It automatically assigns default values for NULL values, which is undesirable in the case of numeric values as NULL values will become 0. Instead, the views should be queried without limiting the number of rows and then exported. This isn't the most efficient solution, but it's a fairly simple workaround and the dataset isn't too large so it shouldn't be an issue here.
5. Load the `Brazilian E-Commerce.twb` Tableau file (it was created using Tableau Public), and connect to the three CSV files created in the previous step.

## Dataset

**Source**: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

**Description**:  
The dataset contains information from 2016 to 2018 about orders made at Olist — a Brazilian online marketplace.

It includes multiple CSV files representing different entities in the e-commerce process such as:
- Customers
- Sellers
- Products
- Orders
- Order Items
- Order Payments
- Order Reviews

## Project Workflow

### Data Preparation and EDA with MySQL

`1_load_data.sql`
- Importing CSVs into MySQL by creating tables and loading csv files.
- Setting primary and foreign keys.
- Handling empty values as nulls and setting appropriate data types.

`2_create_views.sql`
- Joining tables and aggregating values to create three SQL Views:
   - a view for each individual order
   - a view for orders at an itemized level (one row per unique product per order)
   - a view for payment types used for each order
- Initial data transformations (e.g. computing order totals) and handling of null values

`3_data_exploration`
- Create temporary tables of views for faster queries.
- Identified key business metrics such average delivery time, order frequency, most popular categories, etc.
- Aggregated data by key dimensions such as order month, state, and product category to analyze sales trends and delivery performance.
- Perform final data cleaning and addition of calculated fields

### Data Visualization with Tableau

- Connected Tableau to SQL views.
- Created interactive dashboards for analysis of order counts, sales totals, review scores, shipping and delivery times, and payment options.

## Key Insights

### Customer Behavior

- 93099 out of 96086 customers (96.9%) only made a single purchase. 2745 customers made two orders while 242 customers made three or more orders.
   - Assuming the dataset is not a sample of a larger dataset and there are no customers with more than one unique customer ID, this indicates low customer retention.
- The average total price of orders is BRL (Brazilian Real) 160.58 ranging from 9.59 to 13664.08, and a standard deviation of 220.46.
   - Customers purchased, on average, 1.14 items per order.
   - Most customers seem to be placing small-to-mid-sized orders, but there are a few very large orders that could point to bulk buyers or high-value items being sold occasionally.

- There is a growth in sales over time, with sales significantly increasing from Fall 2017.
   - Monthly average order value stayed stable over time.
   - This suggests that the amount that customers were spending on each order didn't change much over time, and the increase in sales can be attributed to more orders being placed.
- The state of Sao Paulo had the highest number orders at 41746, or 42.0% of all orders. It also had the lowest average order total of BRL 143.12. suggesting a pattern of frequent but smaller purchases compared to other states.

![](https://github.com/isaacjeon/brazilian_ecommerce/blob/main/image/orders_kpi.png)
![](https://github.com/isaacjeon/brazilian_ecommerce/blob/main/image/number_of_orders.png)

### Product Categories

- The single product with the largest qty sold was in the furniture_decor category at 527 units sold (within 431 distinct orders), while the product that was sold in the largest number of distinct orders was in the bed_bath_table category at 467 orders (with 488 total units sold).
- The category with the largest qty sold is bed_bath_table at 11115 units sold, followed by health_beauty at 9670 units, sports_leisure at 8641 units, and furniture_decor at 8334 units sold.
   - The top product categories suggest customers primarily purchase home, personal care, and lifestyle products.
   - While bed_bath_table leads in number of sales, there is not a huge difference compared to other top categories, indicating a diversity in product demand.

![](https://github.com/isaacjeon/brazilian_ecommerce/blob/main/image/product_categories.png)
 
### Analysis of payment types used
- Of the four payment types (credit card, debit card, boleto, and voucher), credit card usage dominates at 76505 (76.9%) of orders.
   - 27594 (27.7%) of orders paid in more than one installments and the average number of credit card installments was 3.51, highlighting the importance of installment support.
- The second most used payment type is "boleto" (a Brazilian payment method) at 19784 (19.9%) orders, which also highlights the importance of supporting this payment option.

![](https://github.com/isaacjeon/brazilian_ecommerce/blob/main/image/payment_types.png)

### Review Scores
- The average review score is 4.09 out of 5, indicating decent levels of customer satisfaction but also room for improvement.
- 97.09% of orders were delivered. While 58.84% of delivered orders received a review score of 5, 9.64% of delivered orders received a score of 1.
   - While the fulfillment rate is high, nearly 1 in 10 delivered orders still receive the lowest rating, indicating potential issues with delivery speed, product condition, or service quality.

![](https://github.com/isaacjeon/brazilian_ecommerce/blob/main/image/review_scores.png)
 
- The number of positive views significantly increased over time, while negative/neutral reviews remained relatively low.
   - This trend suggests a steady improvement in customer satisfaction.
   - Negative reviews somewhat spiked around November 2017 and March 2018, which could be potentially be due to the increase in delivery times observed in the data for those periods.

![](https://github.com/isaacjeon/brazilian_ecommerce/blob/main/image/review_scores_monthly.png)

### Delivery Times
- 90.49% of orders arrived by the estimated delivery date, meaning that about 1 out of 10 orders experienced a delay.
- Review score is strongly correlated with delivery delays.
   - Orders that received a score of 5 took 10.6 days on average to deliver, and orders that received scores of 1 took twice the amount of time at 21.3 days on average.
   - Orders that received a score of 5 arrived on average 13.4 days earlier than the estimated delivery date, while orders that received scores of 1 arrived on averaged 4.0 days early.
- The seller may improve customer satisfaction by taking measures to send out items to the carrier as soon as possible.

![](https://github.com/isaacjeon/brazilian_ecommerce/blob/main/image/delivery_times.png)

- There are many cases where, despite the seller sending the item one or two weeks early, the carrier still delivers the item late. Sometimes the item takes months to deliver.
   - This highlights a key logistics bottleneck in which delays result from carrier inefficiencies rather than seller performance. These delays result in lower review scores even though the seller may not be at fault.
   - This suggests a need to reevaluate carrier partnerships or improve the accuracy of estimated delivery dates.
 
![](https://github.com/isaacjeon/brazilian_ecommerce/blob/main/image/delivery_delays.png)
