# SQL Data Warehouse Project

Welcome to my **Data Warehouse and Analytics Project** repository! 🚀
This project demonstrates a complete data warehousing and analytics solution, built using **MySQL**, from raw data ingestion to business-ready reporting. It follows the Medallion Architecture and was built as a hands-on portfolio project to practice real-world data engineering and analytics skills.

---

## 🏗️ Data Architecture

The data architecture for this project follows the Medallion Architecture with **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV files into a MySQL database (`bronze_db`).
2. **Silver Layer**: Includes data cleansing, standardization, and normalization to prepare the data for analysis (`silver_db`).
3. **Gold Layer**: Houses business-ready data modeled into a star schema for reporting and analytics (`gold_db`).

---

## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a modern data warehouse using the Medallion Architecture (Bronze, Silver, Gold layers).
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and queries for actionable business insights.

🎯 This repository showcases practical skills in:
- SQL Development
- Data Modeling
- ETL Pipeline Development
- Data Engineering Fundamentals
- Data Analytics

---

## 🛠️ Tools Used

Everything used in this project is free:
- **[Datasets](datasets/):** Source CSV files (ERP and CRM data).
- **[MySQL Community Server](https://dev.mysql.com/downloads/mysql/):** Free, open-source database server used to host the data warehouse.
- **[MySQL Workbench](https://dev.mysql.com/downloads/workbench/):** GUI tool used for writing queries, managing databases, and designing schemas.
- **[Git & GitHub](https://github.com/):** Used to version and manage the project code.

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

**Objective:**
Develop a modern data warehouse using MySQL to consolidate sales data, enabling analytical reporting and informed decision-making.

**Specifications:**
- **Data Sources**: Import data from two source systems (ERP and CRM), provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historical tracking is not included.
- **Documentation**: Provide clear documentation of the data model for both business stakeholders and analytics teams.

### BI: Analytics & Reporting (Data Analysis)

**Objective:**
Develop SQL-based analytics to deliver insights into:
- Customer Behavior
- Product Performance
- Sales Trends

These insights help stakeholders understand key business metrics and support data-driven decision-making.

---

## 📂 Repository Structure

```
SQL-Data-Warehouse-Project/
│
├── datasets/                     # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                         # Project documentation and architecture details
│   ├── data_architecture.png     # Image showing the project's architecture
│   ├── data_catalog.md           # Catalog of datasets, including field descriptions and metadata
│   ├── naming_conventions.md     # Naming guidelines for tables, columns, and files
│
├── scripts/                      # SQL scripts for ETL and transformations
│   ├── bronze/                   # Scripts for creating tables and loading raw data
│   ├── silver/                   # Scripts for cleaning and transforming data
│   ├── gold/                     # Scripts for creating analytical views (star schema)
│
├── tests/                        # Data quality checks and validation scripts
│
├── README.md                     # Project overview and instructions
├── LICENSE                       # License information for the repository
└── .gitignore                    # Files and directories ignored by Git
```

---

## 🔑 Key Insights

- *Which product categories/subcategories generate the highest sales revenue?*
- *Who are the top customers by total sales, and which country/region do most customers come from?*
- *How do sales trend over time (monthly/yearly) — any seasonal patterns?*
- *What's the average order value, and how does it vary by product category?*
- *Which products have the highest sales quantity vs. highest revenue (are they the same products)?*

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and share this project with proper attribution.

---

## 🌟 About Me

Hi, I'm **Surya Teja Narina** — currently building my data analytics portfolio, with a focus on SQL, data warehousing, and BI tools.

🔗 [LinkedIn](https://www.linkedin.com/in/surya-teja-narina-b4aa5a317/)

---

## 🙏 Acknowledgment

This project was built by following and adapting a guided data warehousing tutorial by **Data With Baraa** (originally designed for SQL Server), rewritten and implemented here using **MySQL** as a practical exercise in translating concepts across database platforms.
