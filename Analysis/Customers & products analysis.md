# Analysis Questions
1. List the top 10 customers that had the highest revenue?
2. Customers segmentation based on revenue:
   If revenue > 50 mil then 'VIP',
   If 10 mil < revenue <50 mil then 'NORMAL',
   If revenue < 10 mil then 'LOW'
3. List of returning customers who purchased again.
4. List the top 10 best-selling products.
5. List the top 10 products that had the highest revenue.
   
---

# Solutions
Let's collaborate on running the queries using Oracle 19c

## 1. List the top 10 customers that had the highest revenue?
#### (Get all customers that had the same total revenue)
```sql
With amt_per_cusid as (
    Select 
        customer_id,
        total_amt
    from(
        select 
            customer_id,
            sum(total_amount) total_amt,
            rank () over (order by sum(total_amount) desc)rnk
        from orders 
        group by customer_id
    )
    where rnk <=10
)
select 
    cus.*, 
    cusid.total_amt
from amt_per_cusid cusid
join customers cus 
    on cus.customer_id = cusid.customer_id
```
## Result set (preview)
| CUSTOMER_ID | FULL_NAME     | EMAIL                    | PHONE      | ADDRESS                    | TOTAL_AMT |
|-------------|---------------|--------------------------|------------|----------------------------|-----------|
| 1802        | Customer 1802 | customer1802@example.com | 0900001802 | Address No. 1802, Viet Nam | 61010010  |
| 1952        | Customer 1952 | customer1952@example.com | 0900001952 | Address No. 1952, Viet Nam | 61010010  |
| 2102        | Customer 2102 | customer2102@example.com | 0900002102 | Address No. 2102, Viet Nam | 61010010  |
| 2252        | Customer 2252 | customer2252@example.com | 0900002252 | Address No. 2252, Viet Nam | 61010010  |
| 2402        | Customer 2402 | customer2402@example.com | 0900002402 | Address No. 2402, Viet Nam | 61010010  |
| 2552        | Customer 2552 | customer2552@example.com | 0900002552 | Address No. 2552, Viet Nam | 61010010  |
| 2702        | Customer 2702 | customer2702@example.com | 0900002702 | Address No. 2702, Viet Nam | 61010010  |
| 2852        | Customer 2852 | customer2852@example.com | 0900002852 | Address No. 2852, Viet Nam | 61010010  |
| 3002        | Customer 3002 | customer3002@example.com | 0900003002 | Address No. 3002, Viet Nam | 61010010  |
| 3152        | Customer 3152 | customer3152@example.com | 0900003152 | Address No. 3152, Viet Nam | 61010010  |
---
## 2. Customers segmentation based on revenue
   If revenue > 50 mil then 'VIP',
   If 10 mil < revenue < 50 mil then 'NORMAL',
   If revenue < 10 mil then 'LOW'
```sql
Select
    cus.customer_id, 
    cus.full_name, 
    cus.email, 
    cus.phone, 
    cus.address,
    sum(ord.total_amount) total_amt,
    case
        when sum(ord.total_amount) >= 50000000 
        then 'VIP' 
        when sum(ord.total_amount) > 10000000
        then 'NORMAL' 
        else 'LOW'
        end cus_seg
from customers cus
join orders ord 
    on cus.customer_id = ord.customer_id
group by
    cus.customer_id, 
    cus.full_name, 
    cus.email, 
    cus.phone, 
    cus.address
```
## Result set (preview)
| CUSTOMER_ID | FULL_NAME       | EMAIL                      | PHONE      | ADDRESS                      | TOTAL_AMT | CUS_SEG |
|-------------|-----------------|----------------------------|------------|------------------------------|-----------|---------|
| 697985      | Customer 697985 | customer697985@example.com | 0900697985 | Address No. 697985, Viet Nam | 21132837  | NORMAL  |
| 393239      | Customer 393239 | customer393239@example.com | 0900393239 | Address No. 393239, Viet Nam | 27609204  | NORMAL  |
| 200863      | Customer 200863 | customer200863@example.com | 0900200863 | Address No. 200863, Viet Nam | 25637397  | NORMAL  |
| 210316      | Customer 210316 | customer210316@example.com | 0900210316 | Address No. 210316, Viet Nam | 7989393   | LOW     |
| 206159      | Customer 206159 | customer206159@example.com | 0900206159 | Address No. 206159, Viet Nam | 18293838  | NORMAL  |
| 196338      | Customer 196338 | customer196338@example.com | 0900196338 | Address No. 196338, Viet Nam | 21739005  | NORMAL  |
| 480850      | Customer 480850 | customer480850@example.com | 0900480850 | Address No. 480850, Viet Nam | 7989393   | LOW     |
| 949677      | Customer 949677 | customer949677@example.com | 0900949677 | Address No. 949677, Viet Nam | 350691    | LOW     |
| 1255        | Customer 1255   | customer1255@example.com   | 0900001255 | Address No. 1255, Viet Nam   | 7419138   | LOW     |
| 55649       | Customer 55649  | customer55649@example.com  | 0900055649 | Address No. 55649, Viet Nam  | 13151853  | NORMAL  |
---
## 3. List of returning customers who purchased again.
```sql
SELECT
    distinct (o1.customer_id),
    o1.order_date AS order_date_1,
    o2.order_date AS order_date_2
FROM orders o1
JOIN orders o2
  ON o1.customer_id = o2.customer_id
 AND o1.order_date <  o2.order_date
ORDER BY o1.customer_id, o1.order_date;
```
## Result set
### There is no returning customer


```sql
-- Update the order_date of 1 order_id to check the code:
Update orders
set order_date = '11-JAN-26'
where order_id = 4000001
-- Rewrite code:
SELECT
    distinct(o1.customer_id),
    o1.order_date AS order_date_1,
    o2.order_date AS order_date_2
FROM orders o1
JOIN orders o2
  ON o1.customer_id = o2.customer_id
 AND o1.order_date <  o2.order_date
ORDER BY o1.customer_id, o1.order_date;
```
## Result set
| CUSTOMER_ID | ORDER_DATE_1 | ORDER_DATE_2 |
|-------------|--------------|--------------|
| 579         | 10-JAN-26    | 11-JAN-26    |

##### After update the dataset, the code is running correctly and find out that there is 1 customer (customer_id = 579) buy products in 10-Jan-26 and return to buy again in 11-jan-16
---
## 4. List the top 10 best-selling products.
#### (Get all products that had the same total quantity)
```sql
select 
    pro.product_id,
    pro.product_code,
    pro.product_name,
    ID_qtt.total_quantity
from( 
    select 
        product_id, 
        sum(quantity) total_quantity,
        rank () over(order by sum(quantity) desc) rnk
    from order_items
    group by product_id 
    ) ID_qtt
join products pro
    on ID_qtt.product_id = pro.product_id
where ID_qtt.rnk <= 10
```
## Result set
| PRODUCT_ID | PRODUCT_CODE | PRODUCT_NAME | TOTAL_QUANTITY |
|------------|--------------|--------------|----------------|
| 5          | 5            | Product 5    | 1800000        |
| 10         | 10           | Product 10   | 1800000        |
| 15         | 15           | Product 15   | 1800000        |
| 20         | 20           | Product 20   | 1800000        |
| 25         | 25           | Product 25   | 1800000        |
| 30         | 30           | Product 30   | 1800000        |
| 35         | 35           | Product 35   | 1800000        |
| 40         | 40           | Product 40   | 1800000        |
| 45         | 45           | Product 45   | 1800000        |
| 50         | 50           | Product 50   | 1800000        |
---
## 5. List the top 10 products that had the highest revenue.
```sql
select 
    pro.product_id,
    pro.product_code,
    pro.product_name,
    pro_rev.rev, 
    pro_rev.rnk
from(
    select 
        product_id, 
        sum(line_price) rev,
        rank ()over (order by sum(line_price) desc) rnk
    from order_items
    group by product_id
    ) pro_rev   
join products pro
    on pro.product_id = pro_rev.product_id
where pro_rev.rnk <=10
```
## Result set
| PRODUCT_ID | PRODUCT_CODE | PRODUCT_NAME | REV          | RNK |
|------------|--------------|--------------|--------------|-----|
| 45         | 45           | Product 45   | 874168200000 | 1   |
| 50         | 50           | Product 50   | 869560200000 | 2   |
| 40         | 40           | Product 40   | 856148400000 | 3   |
| 5          | 5            | Product 5    | 745043400000 | 4   |
| 15         | 15           | Product 15   | 696672000000 | 5   |
| 35         | 35           | Product 35   | 686959200000 | 6   |
| 49         | 49           | Product 49   | 625747320000 | 7   |
| 39         | 39           | Product 39   | 623920440000 | 8   |
| 25         | 25           | Product 25   | 586987200000 | 9   |
| 23         | 23           | Product 23   | 505285200000 | 10  |
---
