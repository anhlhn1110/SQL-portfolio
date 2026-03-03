# List of stored procedure
1. Write a stored procedure to list the transaction dates of a given customer
2. Create and update table to calculate the KPI of a given customer at a range of specified time (from date to date): Total orders, total revenue, last order date, revenue rank
3. Write a store procedure to list the top N customer that had the highest revenue on a given date (N is flexible number)
---
# List of function
4. Write a function to calculate the total revenue for a given date/month
5. Write a function to calculate the Cumulative revenue to a given date
6. Write a function to update the point of each customer (100,000 revenue ~ 1 point)
---
# Solutions
# 1. Write a stored procedure to list the transaction dates of a given customer.
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
# 2. Create and update table to calculate the KPI of a given customer at a range of specified time (from date to date): Total orders, total revenue, last order date, revenue rank
### Purpose: This procedure builds and maintains a KPI table for a specified customer over a defined date range. This procedure can be run at any specified set-up time in a day in order to keep track of the KPI of customers quickly 
```sql
--Create the table KPI_table to save and update the KPI information
create table KPI_table
(report_date DATE,
customer_id NUMBER,
total_orders NUMBER,
total_revenue NUMBER,
last_order_date DATE,
rank_revenue NUMBER);

--Create stored procedure
create or replace procedure update_KPI_table
(
    p_start_date IN DATE,
    p_end_date IN DATE
)
As
Begin
    --Delete the previous report
    delete from KPI_table
    where report_date = p_end_date;
    
    --Update the report with the latest data
    insert into KPI_table (
    report_date,
    customer_id,
    total_orders,
    total_revenue,
    last_order_date,
    rank_revenue)
    
    select 
        p_end_date as report_date,
        customer_id,
        count(distinct (order_id)) as total_orders,
        sum(total_amount) as total_revenue,
        max(order_date) as last_order_date,
        rank() over(order by sum(total_amount)) as rank_revenue
    from orders
    where order_date between p_start_date and p_end_date
    group by customer_id;

    commit;
END;
/
--Call the procedure (Exp: for period from 01-Jan-26 to 10-jan-26)
BEGIN
    update_KPI_table(to_date(20260101,'YYYYMMDD'), to_date(20260110,'YYYYMMDD'));
END;
/
--Select to see the data
select * from KPI_table;
```
#Result set (preview)
| REPORT_DATE | CUSTOMER_ID | TOTAL_ORDERS | TOTAL_REVENUE | LAST_ORDER_DATE | RANK_REVENUE |
|-------------|-------------|--------------|---------------|-----------------|--------------|
| 10-JAN-26   | 200793      | 3            | 423045        | 04-JAN-26       | 10783        |
| 10-JAN-26   | 200943      | 3            | 423045        | 04-JAN-26       | 10783        |
| 10-JAN-26   | 205713      | 3            | 423045        | 04-JAN-26       | 10783        |
| 10-JAN-26   | 213006      | 3            | 423045        | 07-JAN-26       | 10783        |
| 10-JAN-26   | 222603      | 3            | 423045        | 04-JAN-26       | 10783        |
| 10-JAN-26   | 196986      | 3            | 423045        | 07-JAN-26       | 10783        |
| 10-JAN-26   | 252360      | 3            | 423045        | 01-JAN-26       | 10783        |
| 10-JAN-26   | 214809      | 3            | 423045        | 10-JAN-26       | 10783        |
| 10-JAN-26   | 228009      | 3            | 423045        | 10-JAN-26       | 10783        |
| 10-JAN-26   | 221100      | 3            | 423045        | 01-JAN-26       | 10783        |
---
# 3. Write a store procedure to list the top N customer that had the highest revenue on a given date (N is flexible number)
#####(Get all the customer with the same revenue with the same rank)
### Purpose: This procedure calculate to show the list of top N customer that genarated the highest revenue on a specified date. It helps business find out the top customer quickly for further promotion program to push the sale result.

```sql
create or replace procedure get_top_customer
(
    p_top IN NUMBER,
    p_order_date IN VARCHAR2
)
As
    v_checking NUMBER;
Begin
    --check if the table already exists, drop table
    select count(*) 
    into v_checking
    from all_tables
    where table_name = UPPER ('Top_cus');
    
    if v_checking = 1 then
        execute immediate 'Drop table top_cus';
    end if;
    --Create the table to get the top customer
    execute immediate 'Create table top_cus as(
        select 
            c.*,
            top_rnk.ttl_amt
        from(
            Select
                order_date,
                customer_id,
                sum(total_amount) ttl_amt,
                rank() over(partition by order_date order by sum(total_amount)) rnk
            from orders
            group by order_date, customer_id
            ) top_rnk
        join customers c
            on c.customer_id = top_rnk.customer_id
        where top_rnk.rnk <= ' || p_top || 
            ' and top_rnk.order_date = to_date(' || p_order_date || ',''YYYYMMDD'')
            )'; 
END;
/
--Call the procedure (exp: top 5 in 23-jan-26)
Begin
    top_customer(5, '20260123');
End;
/
--Select to see the list
Select *
from top_cus;
```
# Result set (Preview)
| CUSTOMER_ID | FULL_NAME       | EMAIL                      | PHONE      | ADDRESS                      | TTL_AMT |
|-------------|-----------------|----------------------------|------------|------------------------------|---------|
| 108472      | Customer 108472 | customer108472@example.com | 0900108472 | Address No. 108472, Viet Nam | 371616  |
| 108622      | Customer 108622 | customer108622@example.com | 0900108622 | Address No. 108622, Viet Nam | 371616  |
| 108772      | Customer 108772 | customer108772@example.com | 0900108772 | Address No. 108772, Viet Nam | 371616  |
| 175522      | Customer 175522 | customer175522@example.com | 0900175522 | Address No. 175522, Viet Nam | 371616  |
| 175672      | Customer 175672 | customer175672@example.com | 0900175672 | Address No. 175672, Viet Nam | 371616  |
| 175822      | Customer 175822 | customer175822@example.com | 0900175822 | Address No. 175822, Viet Nam | 371616  |
| 175972      | Customer 175972 | customer175972@example.com | 0900175972 | Address No. 175972, Viet Nam | 371616  |
| 242722      | Customer 242722 | customer242722@example.com | 0900242722 | Address No. 242722, Viet Nam | 371616  |
| 242872      | Customer 242872 | customer242872@example.com | 0900242872 | Address No. 242872, Viet Nam | 371616  |
| 243022      | Customer 243022 | customer243022@example.com | 0900243022 | Address No. 243022, Viet Nam | 371616  |
---
# 4. Write a function to calculate the total revenue for a given date/month
### Purpose: This function calculates total revenue for a specified day or month, enabling flexible sales reporting and analysis.
```sql
--Create the function
create or replace function get_rev_fn
(
    p_order_date IN DATE,
    p_key IN VARCHAR2 --'n' for revenue on a date, 't' for revenue in a month
)
Return NUMBER
is
    v_rev NUMBER;
begin
    if p_key = 'n' then
        select sum(total_amount)
        into v_rev
        from orders
        where order_date = p_order_date;
    elsif p_key = 't' then
        select sum(total_amount)
        into v_rev
        from orders
        where extract (month from order_date) = extract(month from p_order_date);
    end if;
    
    return NVL(v_rev,0);
end;
/
--Call the function (exp: calculate the revenue for the month on 30-jan-26) 
select get_rev_fn(to_date(20260130,'YYYYMMDD'),'t') as Rev
from dual;
```
# Result set
| REV            |
|----------------|
| 14670045960000 |
---
# 5. Write a function to calculate the Cumulative revenue to a given date
### Purpose: This function calculates the cumulative revenue up to a specified date. It helps track revenue growth over time and supports financial analysis and reporting.
```sql
--Create funtion
create or replace function get_cum_rev_fn
(
    p_date IN DATE
)
return NUMBER
is
    rev NUMBER := 0;
Begin
    For r in(
        select sum(total_amount) ttl_rev
        from orders
        where order_date <= p_date
        group by order_date
        )
    Loop
        rev := rev + r.ttl_rev;
    End loop;
    
    return rev;
end;
/
--Select to see the result (exp: cumulative revenue until 23-jan-26)
select get_cum_rev_fn(to_date(20260123,'YYYYMMDD')) cum_rev
from dual;
```
# Result set
| CUM_REV        |
|----------------|
| 11009206342248 |
---
# 6. Write a function to update the point of each customer (revenue = 100,000 ~ 1 point)
### Purpose: This function updates each customer’s reward points based on their total revenue, enabling quick review to implement promotion program for high_point customers
```sql
--Create the function
create or replace function get_customer_point_fn
(
    p_customer_id IN NUMBER
)
Return NUMBER
is 
    v_point NUMBER;
begin
    Select sum(total_amount)/100000
    into v_point
    from orders
    where customer_id = p_customer_id;
    
    return v_point;
end;
/
--Call the function for every customer 
select 
    orders.customer_id,
    sum(orders.total_amount) ttl_rev,
    trunc(get_customer_point_fn(customer_id)) customer_point
from orders
group by customer_id;
```
# Result set (Preview)
| CUSTOMER_ID | TTL_REV  | CUSTOMER_POINT |
|-------------|----------|----------------|
| 589         | 18902511 | 189            |
| 594         | 3783192  | 37             |
| 605         | 12795780 | 127            |
| 612         | 17173980 | 171            |
| 627         | 21739005 | 217            |
---
