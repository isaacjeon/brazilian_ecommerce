# Brazilian E-Commerce Data Analysis Project

This project explores the **Brazilian E-Commerce Public Dataset by Olist** from Kaggle, utilizing **MySQL** for data structuring, cleaning, and exploratory data analysis (EDA), and **Tableau** for building interactive dashboards.

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

## How to Use

1. Download the CSV files from the Kaggle source (`olist_geolocation_dataset.csv` is not used for this project).
2. Clone the repository
3. Import data into MySQL and run the sql scripts in the following order:
   - `1_load_data.sql`
   - `2_create_views.sql`
   - `3_data_exploration`
4. 

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
- Created interactive dashboards including:
  ...
  ...

## Key Insights

- 
