# List of stored procedure
1. Write a stored procedure to list the transaction dates of a given customer
2. Create and update table to calculate the KPI of a given customer in a range of specified time (from date to date): Total orders, total revenue, last order date, revenue rank
3. Write a store procedure to list the top N customer that had the highest revenue in a given date (N is flexible number)
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
# 2. Create and update table to calculate the KPI of a given customer in a range of specified time (from date to date): Total orders, total revenue, last order date, revenue rank
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
# 3. Write a store procedure to list the top N customer that had the highest revenue in a given date (N is flexible number)
### Purpose: This procedure 
