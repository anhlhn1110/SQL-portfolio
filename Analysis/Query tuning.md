# Problem statement:
The original query on orders dataset was slow when calculating customers that return to buy again
# Original Query:
```sql
SELECT
    distinct (o1.customer_id),
    o1.order_date AS order_date_1,
    o2.order_date AS order_date_2
FROM orders o1
JOIN orders o2
  ON o1.customer_id = o2.customer_id
 AND o1.order_date <  o2.order_date
ORDER BY o1.customer_id, o1.order_date
```
# Explain plan:
It takes the query 15.3s to fetch all rows

**Before Optimization**
![Before](images/before_index.png)
# Index Creation:
```sql
--Note that the query includes an ORDER BY clause for customer_id and order_date, so try adding an index on customer_id and order_date
create index idx_orders2 on orders(customer_id, order_date)
```
# Performance Comparison:
It takes the query 2.1s to fetch all rows

**After Optimization**
![After](images/after_index.png) 
