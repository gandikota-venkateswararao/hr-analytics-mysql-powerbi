# HR Analytics Dashboard | MySQL + Power BI

A real-world HR Analytics project built with MySQL and Power BI
tracking employee lifecycle, attrition, salary and performance.

## Tech Stack
- MySQL 8.0 - Database design and SQL views
- Power BI Desktop - Interactive dashboard
- Python 3 - Data generation

## Database
- 7 Tables
- 500 Employee records
- 1800+ Performance reviews
- 3000+ Attendance records
- 7 SQL Views

## Dashboard Pages
- Page 1: Overview - Headcount, Attrition, Department analysis
- Page 2: Salary analysis, Experience band, Work mode

## Key Insights Found
- Sales department has highest attrition 28%
- Employees with 0-1 year experience leave most
- Remote employees have lower attrition than on-site

## How to Run
1. Run 01_schema.sql in MySQL Workbench
2. Run 02_data.sql to load 500 employees
3. Run 03_views_and_kpis.sql to create views
4. Connect Power BI to MySQL localhost
5. Import all 7 views and build dashboard

## Author
Gandikota Venkateswara Rao
