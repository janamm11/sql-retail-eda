# 🛒 From Messy Retail Data to Real Insights: End-to-End SQL Analysis

> 643 products. 7 messy columns. No clean prices, no usable ratings, no brand names.  
> Here is how I turned that into actual business insights using only MySQL.

📝 **Full Blog Post** → [Read on Medium](https://medium.com/@janamthapa3213/from-messy-retail-data-to-real-insights-end-to-end-sql-analysis-ca726d2c1915)

---

## 📌 About the Project

A real-world messy electronics dataset scraped from a Costco-style retailer.  
The dataset had **643 products** across **7 raw columns** — all unstructured and unusable out of the box.

This project covers the full pipeline:
- 🧹 Data Cleaning
- 🔍 Exploratory Data Analysis (EDA)
- 📊 Business & Market Insights
- 📈 Power BI Dashboard *(coming soon)*

---

## 📂 Dataset Overview

| Column | Raw State | After Cleaning |
|--------|-----------|----------------|
| Price | `$1,299.99`, `$299–$449` | Clean decimal values |
| Discount | `Limited Time Offer`, `$30 After Coupon` | Yes/No flag + 4 categories |
| Rating | `Rated 4.8 out of 5 stars based on 125 reviews` | avg_rating + review_count |
| Title | Full product title | Extracted brand name |
| Sub Category | Product categories | Clean categorical column |
| Currency | $ sign in every row | Dropped (zero value) |
| Feature | Bullet points crammed in one cell | Left for future NLP |

---

## 🧹 Data Cleaning Highlights

- **Price** — Used `REPLACE()` and `SUBSTRING_INDEX()` to strip symbols and fix ranges
- **Discount** — Reduced cardinality using `LIKE` and `REGEXP` into Yes/No + discount type categories
- **Rating** — Extracted `avg_rating` and `review_count` from unstructured text using `REGEXP_SUBSTR()`
- **Brand** — Extracted first word from Title using `SUBSTRING_INDEX()`, then mapped sub-brands (MacBook, iPad, iMac → Apple) using `CASE WHEN`
- **Currency & Feature** — Dropped Currency (all same), left Feature for future NLP analysis

---

## 🔍 Key Insights

### 💰 Pricing
- 80%+ products priced below $1,500 — mid-market focused catalog, not luxury
- Distribution is right skewed — a few premium products drag the average up
- Sony has the wildest pricing ($89 to $7,999) — no typical Sony price point
- Samsung stays consistent — most products between $108 and $2,172

### 📦 Subcategory
- Laptops dominate with 134 products
- Laptops + TVs together = 37% of entire catalog
- Smart Home & Safety is most competitive — 17 brands fighting for 54 products
- Projectors are 100% discounted — most discounted subcategory

### 🏷️ Discount
- Only 31.81% of products are discounted
- Flat/fixed discount is most common (16.85%)
- Hisense discounts most aggressively — 86% of its products
- Sony (77%), Samsung (61%), LG (59%) follow

### ⭐ Ratings & Reviews
- 6.30% products have no rating or reviews — likely new listings
- Apple is the highest rated brand (4.65 avg)
- Products with 2000+ reviews average 4.51 stars vs 4.27 for low reviewed ones
- Apple AirPods 3rd Generation = most reviewed single product

### 👥 Brand Engagement
- Samsung leads total reviews (53,830) but LG wins avg reviews per product (1,162)
- LG engages customers deeper than Samsung — quality over quantity
- Samsung and Apple both sell across 8 subcategories — true all-rounders

### 📊 Statistical Findings
- Price vs Rating correlation = **-0.22** — expensive products do NOT guarantee better ratings
- Review vs Rating correlation = **0.16** — more reviews slightly linked to better ratings
- HP is the most consistent brand — lowest rating STD (0.24)
- Dell is the most unpredictable — highest rating STD

---

## 🛠️ Tools & Skills Used

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-D71F00?style=for-the-badge&logo=python&logoColor=white)

**SQL Concepts Used:**
`REGEXP` `SUBSTRING_INDEX` `REPLACE` `CASE WHEN` `LIKE` `Window Functions` `Stored Procedures` `PERCENT_RANK()` `GROUP_CONCAT` `Subqueries` `IQR Outlier Detection`

---

## 📈 Power BI Dashboard
*(Coming Soon)*

---

## 🔗 Links

- 📝 [Medium Blog](https://medium.com/@janamthapa3213/from-messy-retail-data-to-real-insights-end-to-end-sql-analysis-ca726d2c1915)

---

## 📬 Contact

Feel free to connect if you have feedback or questions!  
This is a self-learned project — always open to improving. 😊
