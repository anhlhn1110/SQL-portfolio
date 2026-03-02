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
### (Get all customers that had the same total revenue)
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
    o1.customer_id,
    o1.order_date AS order_date_1,
    o2.order_date AS order_date_2
FROM orders o1
JOIN orders o2
  ON o1.customer_id = o2.customer_id
 AND o1.order_date <  o2.order_date
ORDER BY o1.customer_id, o1.order_date;
```
## Result set (preview)
