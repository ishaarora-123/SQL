# IPL Players SQL Analysis

## 📌 Overview

This project uses **MySQL** to analyze IPL player data, focusing on team spending, player salaries, roles, and player categories.

The analysis covers practical SQL problems using **CTEs, Window Functions, Aggregations, CASE statements, and String Functions**.

---

## 📂 Dataset  
IPL 2025 squads: 228 players across 10 teams (player, price in ₹ crore, Indian/Overseas, capped/uncapped, retained/auction/RTM, role, team).  
Run `Insert.sql` to create and load the table, then `question.sql`.


## 📊 Analysis Questions, Concepts & Insights

| #  | Question                                                                | SQL Concepts Used                                    | Key Insight                                                                      |
| -- | ----------------------------------------------------------------------- | ---------------------------------------------------- | -------------------------------------------------------------------------------- |
| 1  | What is the total spending on players for each team?                    | `SUM()`, `GROUP BY`, `ORDER BY`                      | Compare overall player spending across teams.                                    |
| 2  | Who are the top 3 highest-paid all-rounders?                            | `WHERE`, `ORDER BY`, `LIMIT`                         | Identify the most expensive all-rounders across all teams.                       |
| 3  | Who is the highest-paid player in each team?                            | CTE, `ROW_NUMBER()`, `PARTITION BY`                  | Find the top-paid player within every team.                                      |
| 4  | Who are the top 2 highest-paid players in each team?                    | CTE, `ROW_NUMBER()`, Window Functions                | Solve a Top-N-per-team ranking problem.                                          |
| 5  | Can the top 2 players of each team be displayed as separate columns?    | CTE, `ROW_NUMBER()`, `CASE`, Conditional Aggregation | Transform ranked rows into columns for easier comparison.                        |
| 6  | What percentage of a team's total spending does each player contribute? | `SUM() OVER()`, `PARTITION BY`, Calculations         | Understand each player's contribution to their team's total spending.            |
| 7  | How many players fall into High, Medium, and Low price brackets?        | `CASE WHEN`, `COUNT()`, `GROUP BY`                   | Categorize players based on price and compare salary distributions across teams. |
| 8  | What is the average price of Indian vs Overseas players?                | `AVG()`, `WHERE`, `UNION ALL`                        | Compare the average player price between Indian and Overseas players.            |
| 9  | Which players have a price greater than their team's average?           | `AVG() OVER()`, `PARTITION BY`, CTE                  | Identify players whose price is above their team's average.                      |
| 10 | Who is the most expensive player in each role?                          | `MAX() OVER()`, `PARTITION BY`, CTE                  | Identify the highest-priced player within each playing role.                     |

---

## 🧹 Data Cleaning

Before analysis, the dataset was cleaned using SQL to standardize and extract relevant information.

### Cleaning performed:

* Standardized inconsistent values in the `Type` column.
* Removed additional information from player names stored inside parentheses.
* Used `REPLACE()`, `TRIM()`, and `SUBSTRING_INDEX()` for text cleaning.
* Used a temporary column to safely transform player names before updating the original data.

---

## 🧠 SQL Concepts Practiced

### Aggregation

* `SUM()`
* `AVG()`
* `MAX()`
* `COUNT()`

### Window Functions

* `ROW_NUMBER()`
* `SUM() OVER()`
* `AVG() OVER()`
* `MAX() OVER()`
* `PARTITION BY`

### Query Structuring

* CTEs using `WITH`
* Subqueries
* `UNION ALL`

### Conditional Logic

* `CASE WHEN`
* Conditional Aggregation

### Data Cleaning

* `REPLACE()`
* `TRIM()`
* `SUBSTRING_INDEX()`

### Filtering & Sorting

* `WHERE`
* `LIKE`
* `GROUP BY`
* `ORDER BY`
* `LIMIT`

---
  
  
## 💡 Key Insights  
- **Spending is nearly level:** 9 of 10 teams spent between ₹116.55 cr and ₹119.90 cr. KKR is the outlier at ₹107.95 cr.  
- **Most expensive players:** Rishabh Pant (LSG, ₹27 cr), Shreyas Iyer (PBKS, ₹26.75 cr), Venkatesh Iyer (KKR, ₹23.75 cr). Each takes up about 22% of his team's total spend.  
- **Star concentration varies:** LSG's top two players take 40% of its spend, while Delhi Capitals' top two take only 26%. Delhi has the most evenly spread squad.  
- **Most players are cheap:** 151 of 228 players (66%) cost under ₹5 cr; only 21 cost more than ₹15 cr.  
- **Overseas players cost more on average:** average ₹5.64 cr vs ₹4.97 cr for Indian players, and the median gap is wider (₹2.7 cr vs ₹1.8 cr) because many uncapped Indian players are bought cheaply.  
- **Top all-rounders:** Ravindra Jadeja (₹18 cr), Hardik Pandya (₹16.35 cr), Abhishek Sharma (₹14 cr).  
- **Bowlers tie at the top:** five bowlers (Bumrah, Rashid Khan, Arshdeep Singh, Chahal, Cummins) share the highest bowler price of ₹18 cr.  


---

## 🎯 Key Learning

This project focuses on applying SQL to **real-world analytical questions**, with particular emphasis on **Window Functions, CTEs, ranking, aggregation, conditional logic, and data cleaning**.
