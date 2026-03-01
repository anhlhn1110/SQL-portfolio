CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY, 
    full_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE, 
    phone VARCHAR2(20),
    address VARCHAR2(200)
);
CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    product_code VARCHAR2(10),
    product_name VARCHAR2(100) NOT NULL,
    unit_price NUMBER(10,2) NOT NULL,
    stock_quantity NUMBER
);
CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    order_date DATE DEFAULT SYSDATE, 
    total_amount NUMBER(12,2), 
    CONSTRAINT fk_order_customer FOREIGN KEY(customer_id)  
        REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id NUMBER PRIMARY KEY,
    order_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    line_price NUMBER(10,2),
    CONSTRAINT fk_item_order FOREIGN KEY(order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_item_product FOREIGN KEY(product_id)
        REFERENCES products(product_id)
);
CREATE SEQUENCE customer_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE product_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE order_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE order_items_seq START WITH 1 INCREMENT BY 1;