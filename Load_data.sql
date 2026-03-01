--Insert data for 'customers' table
INSERT  INTO customers (
    customer_id,
    full_name,
    email,
    phone,
    address
)
WITH r (id) AS (
    -- Anchor member
    SELECT 1 FROM dual
    UNION ALL
    -- Recursive member
    SELECT id + 1
    FROM r
    WHERE id < 1000000
)
SELECT
    id                                                   AS customer_id,
    'Customer ' || id                                   AS full_name,
    'customer' || id || '@example.com'                  AS email,
    '0' || TO_CHAR(900000000 + MOD(id, 100000000))      AS phone,
    'Address No. ' || id || ', Viet Nam'                 AS address
FROM r;

--Insert data for 'Products' table
INSERT INTO products (
    product_id,
    product_code,
    product_name,
    unit_price,
    stock_quantity
)
WITH r (id) AS (
    SELECT 1 FROM dual
    UNION ALL
    SELECT id + 1 FROM r WHERE id < 50
)
SELECT
    id product_id,
    id product_code,
    'Product ' || id product_name,
    ROUND(DBMS_RANDOM.VALUE(10000, 500000)) unit_price, 
    ROUND(DBMS_RANDOM.VALUE(100, 10000)) stock_quantity
FROM r;

--Insert data for 'Orders' table
INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    total_amount
)
WITH r (lvl) AS (
    SELECT 1 FROM dual
    UNION ALL
    SELECT lvl + 1 FROM r WHERE lvl <= 3
)
SELECT
    order_seq.NEXTVAL order_id, 
    c.customer_id,
    DATE '2026-01-01' + MOD(c.customer_id, 30) order_date,
    0 total_amount 
FROM customers c
JOIN r
  ON r.lvl <= MOD(c.customer_id, 3) + 1; 

--Insert data for 'Order_items' table
INSERT INTO order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    line_price
)
WITH r (lvl) AS (
    SELECT 1 FROM dual
    UNION ALL
    SELECT lvl + 1 FROM r WHERE lvl <= 5
)
SELECT
    order_items_seq.NEXTVAL order_item_id,
    o.order_id,
    MOD(o.order_id, 50) + 1 product_id,
    MOD(o.order_id + r.lvl, 5) + 1 quantity,
    (MOD(o.order_id + r.lvl, 5) + 1) * ROUND(DBMS_RANDOM.VALUE(10000, 500000)) line_price
FROM orders o
JOIN r
  ON r.lvl <= MOD(o.order_id, 5) + 1;


MERGE INTO order_items oi 
USING (    
SELECT oi.order_item_id,         
    oi.quantity * p.unit_price AS calc_line_price     
FROM order_items oi     
JOIN products p       
ON p.product_id = oi.product_id
) src 
ON (oi.order_item_id = src .order_item_id) 
WHEN MATCHED THEN   
UPDATE SET oi.line_price = src.calc_line_price;  

MERGE INTO orders o
USING (
    SELECT order_id,
           SUM(line_price) AS total_amt
    FROM order_items
    GROUP BY order_id
) sum_items
ON (o.order_id = sum_items.order_id)
WHEN MATCHED THEN
  UPDATE SET o.total_amount = sum_items.total_amt;