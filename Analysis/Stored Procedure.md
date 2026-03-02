# List of procedure
1. Write a stored procedure to calculate revenue for any given day or month.
2. Write a stored procedure to list the transaction dates of a given customer
3. Write a store procedure to calculate the Cumulative Revenue as of a given date
4. Write a store procedure to calculate the KPI of a given customer in a range of specified time (from date to date): Total orders, total revenue, last order date, revenue rank
5. Write a store procedure to list the top N customer that had the highest revenue in a given date (N is flexible number)
---
# Solutions
# 1. Write a stored procedure to calculate revenue for any given day or month.
### Purpose:  This procedure calculates total revenue for a specified day or month, enabling flexible sales reporting and analysis.
```sql
--Write the procedure
CREATE OR REPLACE PROCEDURE Get_revenue 
(
    p_order_date IN  DATE,
    p_key IN VARCHAR2
)
AS
    p_revenue NUMBER;
BEGIN 
    If p_key = 'n' then
        select 
            sum (total_amount)
        into p_revenue
        from orders
        where order_date = p_order_date;
        
        DBMS_OUTPUT.PUT_LINE('Revenue in' || p_order_date || ' = ' || p_revenue);
    
    ELSIF p_key = 't' then
        select 
            sum (total_amount)
        into p_revenue
        from orders
        where extract (month from order_date) = extract (month from p_order_date);
        
        DBMS_OUTPUT.PUT_LINE('Revenue in ' || extract (month from p_order_date)|| ' = ' || p_revenue);
    
    END IF;
END;
/
-- Call the procedure for month January
BEGIN
    Get_revenue (to_date(20260123,'YYYYMMDD'),'t');
END;
/
```
# Result set
Revenue in Jan = 14670045960000

```sql
-- Call the procedure for date 30-Jan-26
BEGIN
    Get_revenue (to_date(20260130,'YYYYMMDD'),'n');
END;
/
```
# Result set
Revenue in 30-JAN-26 = 741552591342
---
# 2. Write a stored procedure to list the transaction dates of a given customer.
### Purpose:  This procedure retrieves all transaction dates for a specified customer, enabling quick review of the customer's purchase activity.
```sql
--Write the procedure
Create or replace procedure get_transaction_date
(
    p_customer_id IN NUMBER
)
As 
    checking NUMBER;
BEGIN
    select 1
    into checking  
    from all_tables
    where table_name = UPPER('order_date_per_customer');
    
    if checking = 1 then
        execute immediate 'Drop table order_date_per_customer';
    END IF;
    
    execute immediate 'Create table order_date_per_customer as( 
        Select distinct(order_date)
        from orders
        where customer_id = ' || p_customer_id || '
        )'; 
END;
/
-- Call the procedure for customer_id = 579
execute get_transaction_date(579);
-- Get result set
select *
from order_date_per_customer;
```
# Result set
| ORDER_DATE |
|------------|
| 10-JAN-26  |
| 11-JAN-26  |
---
# 3. Write a stored procedure to calculate the Cumulative Revenue as of a given date.
### Purpose:  This procedure calculate the YTD revenue, enabling revenue monitoring and business analysis.
```sql
create or replace procedure accum_rev
(
    p_order_date IN DATE
)
is
    rev NUMBER :=0;
BEGIN
    FOR R IN(
        select 
            sum(total_amount) ttl_amt
        from orders
        where order_date <= p_order_date
        group by order_date)
    LOOP 
        rev := rev + R.ttl_amt; --gán biến là phải := chứ không được mỗi =
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Cumulative revenue to date '|| p_order_date ||' = '|| rev);
END;
/
-- Call the procedure for order date = 05-Jan-26
Exec accum_rev(to_date(20260105,'YYYYMMDD'));
```
# Result set
Cumulative revenue to date 05-JAN-26 = 2176393094814
