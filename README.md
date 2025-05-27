# 📦 EcommerceDB – E-commerce Data Analysis with SQL

## 🧾 Overview
This project focuses on building a structured database from raw e-commerce transactional data stored in a CSV file, followed by performing advanced SQL-based analytics to derive valuable business insights related to sales, customers, and products.

## 📁 Project Components
- **Database and table creation**: `RawData`, `Customers`, `Products`, `Orders`, `OrderItems`
- **Raw data import** from CSV into the `RawData` table
- **Data transformation and normalization** into relational tables
- **Analytical SQL queries** for business intelligence reporting

## 🧱 Database Schema
- **Customers**: Contains customer IDs and countries
- **Products**: Stores product codes, descriptions, and unit prices
- **Orders**: Includes invoices with dates and customer references
- **OrderItems**: Holds product details per invoice
- **RawData**: Temporary table used for data staging and cleaning (dropped afterward)

## 📊 Key Insights and Queries
- 🏆 Top 10 customers by total spending
- 📦 Top 10 products by quantity sold
- 💰 Top 10 products by revenue generated
- 📅 Monthly revenue trends
- 🔁 Average number of orders per customer
- ⏰ Peak ordering hours
- 🏅 Best-selling product each month
- 🐢 Slow-moving products not sold in the last 6 months

## 🛠️ Tools & Technologies
- Microsoft SQL Server
- SQL (DDL, DML, Aggregations, CTEs, Ranking functions)
- `BULK INSERT` for CSV import

## 🚀 How to Use
1. Create the database using SQL Server.
2. Adjust the CSV file path in the `BULK INSERT` statement to match your system location.
3. Run the SQL script from top to bottom.
4. Review the output using the analytical queries at the end of the script.

## 📌 Notes
- Ensure SQL Server has permission to access the file system for importing the CSV.
- Dataset used in this project can be downloaded from:  
  [📥 Kaggle – Ecommerce Data](https://www.kaggle.com/datasets/carrie1/ecommerce-data)

## 👨‍💻 Developer
- **Name:** Hesham Saad  
- **Role:** Data Analyst  
- **LinkedIn:** [hesham-saad-haiba](https://www.linkedin.com/in/hesham-saad-haiba)  
- **📧 Email:** hesham.s.haiba@gmail.com