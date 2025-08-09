# Brazilian E-Commerce Data Analysis Project

This project explores the **Brazilian E-Commerce Public Dataset by Olist** from Kaggle, utilizing **MySQL** for data structuring, cleaning, and exploratory data analysis (EDA), and **Tableau** for building interactive dashboards.

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

- There are 99441 orders and 96086 unique customer IDs.
   - There are 93099 customers who only made a single purchase (assuming the dataset is not a sample of a larger dataset, and there are not any customers with more than one unique customer ID), with 2745 customers with two orders and 203 customers with three orders.
   - The largest number of orders that a single unique customer made is 17, followed by a customer with 9 orders.
- The average total price of orders is BRL (Brazilian Real) 160.58 ranging from 9.59 to 13664.08, and a standard deviation of 220.46.
- The average review score is 4.09 out of 5.
- Out of all orders, 609 were unavailable and 314 were canceled, suggesting about 1% of orders were unable to be fulfilled.
- The first three and last two months have a very low number of instances. I removed these for the dashboard since they can result in skewed values when aggregating by month.
- The state of Sao Paulo had the highest number orders at 41746 (a bit less than half of all orders). It also had the lowest average order total of BRL 143.12, implying that there may be many more smaller valued orders compared to other states.
- Meanwhile, the state of Paraiba had the high average order total of BRL 265.01, although at a lower order count of 536 which may result in higher error.

### Correlations between delivery times with review scores and location
- Review score seems correlated with the number of days between purchase and delivery and delays in the shipping and delivery process.
   - Orders that received a scores of 5 took 10.62 days on average to deliver, and orders that received scores of 1 took twice the amount of time at 21.28 days on average.
   - Orders that received a scores of 5 arrived on average 13.38 days earlier than the estimated delivery date, while orders that received scores of 1 arrived on averaged 4.03 days earlier possibly implying more frequent and/or severe delays.
   - Similarly, orders that received higher scores tended to have the seller send the item to the carrier earlier.
   - The takeaway is that longer shipping times and delays may lead to negative review scores. While carrier delays may be unavoidable, the seller might improve customer satisfaction by taking measures to send out items to the carrier as soon as possible.
- Orders when the customer and seller are located in the same city arrive, as expected, earlier on average than when they are located in different cities. Similarly, the same could be said when they are located in the same state compared to when they are in different states.
   - Review scores are also slightly higher when deliveries are within the same city/state compared to different cities/states.
   - Surprisingly, however, there are less delays for out-of-state deliveries compared to in-state deliveries, and less delays for out-of-city deliveries compared to same-city deliveries. One possible explanation is that there may be much more leeway in estimated shipping times for further delivery destinations.
- There are a number of seller states that are incorrect for the corresponding city. For example, there are instances where the city is Rio de Janeiro and state is SP (Sao Paulo), when it should be Rio de Janeiro. However, it would require a large amount of time and effort to go through and check for hundreds of different city, state pairs. As this busywork is outside the scope of the project, I will assume that all the location information is correct (although it obviously is not) and keep in mind that normally this information should first be corrected.

### Analysis of itemized orders
- Customers purchased, on average, 1.14 items per order. The largest order had a quantity of 21.
- The single product with the largest qty sold was in the furniture_decor category at 527 units sold (within 431 distinct orders), while the product that was sold in the largest number of distinct orders was in the bed_bath_table category at 467 orders (with 488 total units sold).
- The category with the largest qty sold is bed_bath_table at 11115 units sold, followed by health_beauty at 9670 units, sports_leisure at 8641 units, and furniture_decor at 8334 units sold.
- The state of Sao Paulo (SP) had the most units of products purchased by customers and sold by sellers.
   - The second and third states with the largest total_qty_purchased are Rio de Janeiro (RJ) and Minas Gerais (MG) with 14579 and 13129 units purchased respectively.
   - The second and third states with the largest total_qty_sold are Minas Gerais and Paraiba (PR) with 8827 and 8671 units sold respectively.

### Analysis of payment types used
- Of the four payment types (credit card, debit card, boleto, and voucher), the vast majority of orders was paid (in full or partially) by credit card at 76505 orders. This is followed by 19784 orders paid with boleto, 3866 paid with a voucher, and 1528 paid with debit card.
- Credit cards involved that largest payment value of BRL 163.32 on average, with voucher involving the lowest at BRL 65.70.
- Only credit card allows for multiple installments, with an average of 3.51 and max of 24 installments.
- The average number of payment options used for a single order is 1.04, suggesting that most customers only used one payment type.
   - Different payment options of the same type are counted separately e.g. two different credit cards used in the same order has num_payment_options = 2
