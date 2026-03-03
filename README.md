# 📊 SQL_portfolio

# 📌 Overview

Welcome to my SQL Portfolio repository!! 🚀

This repository is a comprehensive collection of SQL case studies, solutions to problems from various platforms. All are designed to demonstrate my proficiency in SQL.

# 🗂️ Dataset

The datasets used in this project are synthetically generated for practice purposes and do not represent real-world data.

The data model consists of four key tables:

1️⃣ Customers

Contains customer master information.

Columns:

`customer_id` — Unique customer identifier

`full_name` — Customer full name

`email` — Customer email address

`phone` — Customer phone number

`address` — Customer address

2️⃣ Products

Stores product master data.

Columns:

`product_id` — Unique product identifier

`product_code` — Product code

`product_name` — Product name

`unit_price` — Unit price

`stock_qty` — Available stock quantity

3️⃣ Orders

Represents sales orders placed by customers.

Columns:

`order_id` — Unique order identifier

`customer_id` — Reference to customer

`order_date` — Order date

`total_amount` — Total order value

4️⃣ Order_Items

Contains line-item details for each order.

Columns:

`order_item_id` — Unique line item identifier

`order_id` — Reference to order

`product_id` — Reference to product

`quantity` — Quantity of product

`line_price` — Line item amount

🔗 Data Relationships

The tables are relationally linked with the following constraints:

`orders.customer_id` → must exist in `customers.customer_id`

`order_items.order_id` → must exist in `orders.order_id`

`order_items.product_id` → must exist in `products.product_id`

These relationships ensure referential integrity across the dataset.

# 🛠️ Tools & Technologies
- SQL (Oracle 19c):

  Use techniques: CTE, Window function, join, selfjoin, aggregation, procedure, function, index tunning,...
  
- Github
- Markdown

# 🧠 Key Analysis

1️⃣ Overall Performance

[#1 - Overall Performance](Overall%20performance.md)

2️⃣ Customer & Product Analysis

[#2 - Customer & Product Analysis](Customers%20%26%20products%20analysis.md)

⚙️ Advanced SQL Techniques
🔹 Stored Procedures
🔹 Functions

[#3 - Stored Procedure & function](Stored%20Procedure%20%26%20function.md)

🔹 Performance Tuning

[#4 - Query tuning](Query%20tuning.md)

# 👤 Author
I hope you find these resources informative and useful for your SQL learning and application. Should you have any questions or feedback, feel free to reach out to me on LinkedIn. 🙌
