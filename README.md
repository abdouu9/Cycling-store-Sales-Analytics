# End-to-End SQL Server Data Warehouse & Sales Analytics

## Project Overview

This project demonstrates an end-to-end data engineering and business intelligence solution built using **Microsoft SQL Server, T-SQL, and Power BI**.

The objective is to transform raw CRM and ERP data into structured, reliable, and business-ready datasets through automated ETL pipelines, perform business-oriented analysis using SQL, and deliver actionable insights through interactive Power BI dashboards.

The project covers three main areas:

## 1. Data Engineering – SQL Server Data Warehouse

Designed and implemented a data warehouse following a Medallion-inspired architecture (Bronze, Silver, and Gold).

- Automated data ingestion and transformation using stored procedures.
- Integrated and cleansed CRM and ERP source datasets.
- Implemented data quality checks, error handling, and transaction management.
- Designed a Star Schema consisting of customer and product dimensions and a sales fact view.

*Detailed implementation and SQL scripts are documented in the corresponding project files.*

## 2. SQL-Based Data Analysis

Performed business-oriented analysis on the Gold layer to investigate:

- Overall sales performance and revenue trends.
- Product and category performance.
- Customer purchasing behavior and segmentation.
- Geographic sales distribution.
- Customer spending, frequency, and recency.

The analysis uses advanced SQL techniques, including CTEs, joins, aggregations, subqueries, and window functions.

*Detailed queries and analytical findings are available in the corresponding SQL files.*

## 3. Business Intelligence – Power BI

Developed an interactive Power BI report consisting of three analytical dashboards:

- **Executive Overview:** Overall business performance, sales trends, revenue growth, and geographic distribution.
- **Product Analysis:** Product performance, revenue contribution, sales volume, and profitability.
- **Customer Analysis:** Customer segmentation, purchasing behavior, recency, and revenue contribution.

The dashboards include interactive slicers, KPI cards, comparative metrics, and dynamic visualizations to support business performance monitoring and exploration.

**[View Interactive Power BI Report](https://app.powerbi.com/groups/me/reports/7a57a03b-c98f-4b90-a64d-a15cfb2d27fe?ctid=f93d5f40-88c0-4650-b8f2-cc4ec3ef6a10&pbi_source=linkShare)**

## 4. Key Business Findings & Recommendations

The analysis highlighted several important business patterns:

- Bikes represent the dominant revenue-generating product category, contributing approximately 96% of total sales.
- 2013 recorded strong business growth, with approximately 180% revenue growth compared with 2012.
- The United States and Australia are the leading revenue-generating markets.
- Approximately 62.88% of customers made only one purchase.
- The top 10% of customers contribute approximately 40.30% of total revenue.
- Customer purchasing frequency and spending patterns reveal opportunities for more targeted marketing and retention strategies.

Based on these findings, the project proposes business recommendations focused on:

- Improving customer retention and repeat purchases.
- Strengthening relationships with high-value customers.
- Increasing accessory sales through cross-selling and product bundling.
- Optimizing product profitability.
- Improving inventory planning around seasonal demand.
- Developing market-specific customer strategies.

## Technologies & Tools

- **Database:** Microsoft SQL Server
- **Language:** T-SQL
- **Development Environment:** SQL Server Management Studio (SSMS)
- **Data Engineering:** ETL Pipelines, Data Ingestion, Data Cleansing, Stored Procedures
- **Data Architecture:** Medallion Architecture, Star Schema
- **Data Analysis:** CTEs, Joins, Aggregations, Window Functions
- **Business Intelligence:** Microsoft Power BI, DAX, Interactive Dashboards
- **Version Control:** Git & GitHub

## Project Objective

To demonstrate practical skills across the data lifecycle, combining data engineering, SQL analytics, and business intelligence to transform raw business data into reliable datasets, meaningful insights, and actionable recommendations.
