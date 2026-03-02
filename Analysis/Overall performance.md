# Analysis Questions
1. What was the total revenue?
2. What was the revenue for each day and each month?
3. Find the list of top 10 best - selling day? 
4. How many customers who made transactions?

---

# Solutions
Let's collaborate on running the queries using Oracle 19c

## 1. What was the total revenue?
```sql
Select sum(total_amount)
from orders
```
## Result set
| SUM(TOTAL_AMOUNT) |
|-------------------|
| 14670045960000    |
---
## 2. What was the revenue for each day and each month?
```sql
--Revenue for each day
select
  order_date,
  sum (total_amount)
from orders
group by order_date
```
## Result set (Preview)
| ORDER_DATE | SUM(TOTAL_AMOUNT) |
|------------|-------------------|
| 14-JAN-26  | 509833222392      |
| 19-JAN-26  | 246658381383      |
| 20-JAN-26  | 481101559188      |
| 21-JAN-26  | 762652582485      |
| 26-JAN-26  | 497479132404      |
| 28-JAN-26  | 243191341632      |
| 13-JAN-26  | 245192535279      |
| 15-JAN-26  | 741416426301      |
| 23-JAN-26  | 486764527902      |
| 07-JAN-26  | 249708089559      |

```sql
--Revenue for each month
select
  extract (month from (order_date))month,
  sum(total_amount)
from orders
group by extract (month from (order_date))
```
## Result set
| MONTH | SUM(TOTAL_AMOUNT) |
|-------|-------------------|
| 1     | 14670045960000    |
---
## 3. Find the list of top 10 best - selling day?
```sql
select 
    order_date,
    ttl_amt
from (
    select 
        order_date,
        sum(total_amount)ttl_amt,
        rank () over (order by sum(total_amount)desc) rnk
    from orders
    group by order_date
    )
where rnk <=10;
```
## Result set
| ORDER_DATE | TTL_AMT      |
|------------|--------------|
| 06-JAN-26  | 763364089233 |
| 21-JAN-26  | 762652582485 |
| 30-JAN-26  | 741552591342 |
| 15-JAN-26  | 741416426301 |
| 03-JAN-26  | 722506721514 |
| 18-JAN-26  | 721481900523 |
| 27-JAN-26  | 719212137288 |
| 12-JAN-26  | 716230702113 |
| 09-JAN-26  | 713791830096 |
| 24-JAN-26  | 711115618965 |
---
## 4. How many customers who made transactions?
```sql
select count (distinct(customer_id)) As transaction_cus
from orders;
```
## Result set
| TRANSACTION_CUS |
|-----------------|
| 1000000         |
---
