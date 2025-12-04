--  таблица товаров
CREATE table products1 (
  id serial primary key,
  name text not null,
  category text not null,
  price numeric(10,2) check (price >= 0)
);

--  таблица клиентов
CREATE table customers1 (
  id serial primary key,
  name text not null,
  email text unique,
  city text 
);

--  таблица заказов
CREATE table orders1 (
  id serial primary key,
  customer_id integer references customers1(id) on delete cascade,
  order_date date not null default current_date
);

--  таблица позиций в заказах
CREATE table order_items1 (
  order_id integer
  references orders1(id) on delete cascade,
  product_id integer
  references products1(id) on delete cascade,
  quantity integer check (quantity > 0),
  primary key (order_id, product_id)
);

--  добавляем товары
INSERT INTO products1 (name, category, price) VALUES
('Notebook', 'Electronics', 1200.00),
('Mouse', 'Electronics', 25.00),
('T-shirt', 'Clothing', 10.00),
('Chair', 'Furniture', 15.25),
('Water', 'Food', 2.00);

--  добавляем клиентов
insert into customers1 (name, email, city) values
('Svitlana', 'svitlana@example.com', 'Kyiv'),
('Taras', 'taras@example.com', 'Lviv'),
('Iryna', 'iryna@example.com', 'Kharkiv');

-- создаем заказ
insert into orders1 (customer_id) values (1);  --Svitlana (1) номер заказа 1
insert into orders1 (customer_id) values (3); -- Iryna (2) номер заказа 2
insert into orders1 (customer_id) values (3); -- Iryna (3) номер заказа 3

-- добовляем товар в заказ
insert into order_items1 (order_id, product_id, quantity)
values
(1, 1, 1), -- Svitlana, Notebook, 1
(1, 2, 1), -- Svitlana, Mouse, 1
(2, 3, 1), -- Iryna, shirt, 1
(3, 5, 2); -- Iryna, Water, 2

-- CRUD операции для таблиц products
-- CREATE: добавляем новый товар
INSERT INTO products (name, category, price) VALUES ('USB-C Cable', 'Electronics', 12.99);
-- READ: выбрать все товары
SELECT * FROM products;
-- UPDATE: изменить цену товара
UPDATE products SET price = 11.99 WHERE name = 'USB-C Cable';
-- DELETE: удалить товар
DELETE FROM products WHERE name = 'USB-C Cable';

-- количество заказов по клиентам
SELECT c.name, COUNT(o.id) AS orders_count
FROM customers1 c
LEFT JOIN orders1 o ON o.customer_id = c.id
GROUP BY c.id, c.name
ORDER BY orders_count DESC;

-- суммарная стоитомости каждого заказа
SELECT 
  o.id AS order_id, 
  SUM(oi.quantity * p.price) AS order_total
FROM orders1 o
JOIN order_items1 oi ON oi.order_id = o.id
JOIN products1 p ON p.id = oi.product_id
GROUP BY o.id
ORDER BY order_total DESC;

-- Топ‑3 дорогих товаров
SELECT name, price
FROM products1
ORDER BY price DESC
LIMIT 3;

SELECT category, name, price
FROM (
  SELECT category, name, price,
    ROW_NUMBER() OVER 
    (PARTITION BY category ORDER BY price DESC) 
    AS rank_in_category
  FROM products1
) ranked
WHERE rank_in_category <= 3
ORDER BY category, price DESC;