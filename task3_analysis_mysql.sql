-- Task 3: SQL for Data Analysis | MySQL Workbench 8.0 CE
CREATE DATABASE IF NOT EXISTS ecommerce_analysis;
USE ecommerce_analysis;

SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS order_revenue;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE customers (
 customer_id INT PRIMARY KEY, customer_name VARCHAR(100) NOT NULL, city VARCHAR(80)
) ENGINE=InnoDB;
CREATE TABLE products (
 product_id INT PRIMARY KEY, product_name VARCHAR(100) NOT NULL,
 category VARCHAR(80), price DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE orders (
 order_id INT PRIMARY KEY, customer_id INT, order_date DATE, status VARCHAR(30),
 FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;
CREATE TABLE order_items (
 order_item_id INT PRIMARY KEY, order_id INT, product_id INT, quantity INT NOT NULL,
 FOREIGN KEY (order_id) REFERENCES orders(order_id),
 FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

INSERT INTO customers VALUES
(1,'Aarav Sharma','Mumbai'),(2,'Diya Patel','Pune'),(3,'Kabir Mehta','Delhi'),
(4,'Anaya Singh','Bengaluru'),(5,'Ishaan Gupta','Mumbai'),(6,'Mira Joshi','Chennai');
INSERT INTO products VALUES
(101,'Laptop','Electronics',55000),(102,'Headphones','Electronics',2500),
(103,'Office Chair','Furniture',8500),(104,'Notebook','Stationery',120),
(105,'Smartphone','Electronics',30000),(106,'Desk Lamp','Furniture',1800);
INSERT INTO orders VALUES
(1001,1,'2026-10-01','Completed'),(1002,2,'2026-10-03','Completed'),
(1003,1,'2026-10-05','Pending'),(1004,3,'2026-10-07','Completed'),
(1005,4,'2026-10-09','Completed'),(1006,5,'2026-10-11','Cancelled'),
(1007,2,'2026-10-13','Completed'),(1008,6,'2026-10-15','Completed');
INSERT INTO order_items VALUES
(1,1001,101,1),(2,1001,102,2),(3,1002,103,1),(4,1002,104,5),
(5,1003,105,1),(6,1004,102,1),(7,1004,104,10),(8,1005,101,1),
(9,1005,106,2),(10,1006,103,1),(11,1007,105,1),(12,1008,104,8),(13,1008,106,1);

-- 1. SELECT, WHERE, ORDER BY
SELECT * FROM orders WHERE status='Completed' ORDER BY order_date DESC;

-- 2. GROUP BY and SUM: revenue by category (completed orders)
SELECT p.category, ROUND(SUM(p.price*oi.quantity),2) AS total_revenue
FROM order_items oi JOIN products p ON p.product_id=oi.product_id
JOIN orders o ON o.order_id=oi.order_id
WHERE o.status='Completed'
GROUP BY p.category ORDER BY total_revenue DESC;

-- 3. INNER JOIN: orders with customer names
SELECT o.order_id,c.customer_name,o.order_date,o.status
FROM orders o INNER JOIN customers c ON c.customer_id=o.customer_id
ORDER BY o.order_id;

-- 4. LEFT JOIN: all customers, even without orders
SELECT c.customer_name,o.order_id
FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
ORDER BY c.customer_id;

-- 5. RIGHT JOIN: include all customers
SELECT c.customer_name,o.order_id
FROM orders o RIGHT JOIN customers c ON c.customer_id=o.customer_id
ORDER BY c.customer_id;

-- 6. Subquery: products priced above average
SELECT product_name,price FROM products
WHERE price>(SELECT AVG(price) FROM products) ORDER BY price DESC;

-- 7. COUNT, SUM and AVG for completed orders
SELECT COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(p.price*oi.quantity),2) AS total_revenue,
ROUND(AVG(p.price*oi.quantity),2) AS average_line_revenue
FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
JOIN products p ON p.product_id=oi.product_id
WHERE o.status='Completed';

-- 8. Revenue per customer
SELECT c.customer_id,c.customer_name,
ROUND(COALESCE(SUM(p.price*oi.quantity),0),2) AS customer_revenue
FROM customers c
LEFT JOIN orders o ON o.customer_id=c.customer_id AND o.status='Completed'
LEFT JOIN order_items oi ON oi.order_id=o.order_id
LEFT JOIN products p ON p.product_id=oi.product_id
GROUP BY c.customer_id,c.customer_name ORDER BY customer_revenue DESC;

-- 9. Create a VIEW
CREATE OR REPLACE VIEW order_revenue AS
SELECT o.order_id,o.order_date,o.status,c.customer_name,
ROUND(SUM(p.price*oi.quantity),2) AS order_revenue
FROM orders o JOIN customers c ON c.customer_id=o.customer_id
JOIN order_items oi ON oi.order_id=o.order_id
JOIN products p ON p.product_id=oi.product_id
GROUP BY o.order_id,o.order_date,o.status,c.customer_name;

-- 10. Query the VIEW
SELECT * FROM order_revenue WHERE status='Completed' ORDER BY order_revenue DESC;

-- 11. Indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- 12. NULL handling
SELECT customer_name,COALESCE(city,'Unknown') AS city FROM customers;
