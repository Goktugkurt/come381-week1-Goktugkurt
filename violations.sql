-- COME 381 / Ödev 2 B: ihlal testleri. schema.sql ve constraints.sql'den sonra çalışır.
-- Her test tek bir deyimdir; hata veren deyim kaydı değiştirmez, psql sonrakiyle devam eder.
\set VERBOSITY verbose

TRUNCATE category, supplier, customer, product, purchase_order, purchase_order_item,
         credit_risk_assessment, sale, sale_item, shelf_sensor RESTART IDENTITY CASCADE;

INSERT INTO category (category_name) VALUES ('Bira'), ('Atistirmalik');
INSERT INTO supplier (supplier_name, phone) VALUES ('Supplier One', '1'), ('Supplier Two', '2');
INSERT INTO customer (customer_name, phone, credit_limit) VALUES ('Customer One', '1', 300), ('Customer Two', '2', 100);
INSERT INTO product (barcode, product_name, category_id, preferred_supplier_id, cost_price, sale_price, stock_qty, min_stock_qty, max_stock_qty)
VALUES ('8690000000001', 'Product One', 1, 1, 24, 32.50, 20, 10, 80), ('8690000000002', 'Product Two', 2, 2, 18, 27.50, 5, 10, 45);
INSERT INTO purchase_order (supplier_id, order_date, expected_date, status) VALUES (1, '2026-10-01', '2026-10-03', 'sent');
INSERT INTO purchase_order_item (order_id, product_id, ordered_qty, unit_cost) VALUES (1, 1, 24, 24);
INSERT INTO credit_risk_assessment (customer_id, risk_score, decision, expires_at) VALUES (2, 20, 'approved', '2026-12-31');
INSERT INTO sale (customer_id, sold_at, payment_type) VALUES (NULL, '2026-10-05 12:00', 'cash'), (1, '2026-10-05 13:00', 'credit');
INSERT INTO sale_item (sale_id, product_id, quantity, unit_price, unit_cost, discount_rate) VALUES (1, 1, 2, 32.50, 24, 0);
INSERT INTO shelf_sensor (sensor_code, product_id, shelf_location) VALUES ('SNS-1', 1, 'Raf A1');

-- ===== NOT NULL (Beklenen: 23502) =====
-- T01 | category.category_name NOT NULL | Beklenen: 23502
UPDATE category SET category_name = NULL WHERE category_id = 1;
-- T02 | supplier.supplier_name NOT NULL | Beklenen: 23502
UPDATE supplier SET supplier_name = NULL WHERE supplier_id = 1;
-- T03 | supplier.status NOT NULL | Beklenen: 23502
UPDATE supplier SET status = NULL WHERE supplier_id = 1;
-- T04 | customer.customer_name NOT NULL | Beklenen: 23502
UPDATE customer SET customer_name = NULL WHERE customer_id = 1;
-- T05 | customer.credit_limit NOT NULL | Beklenen: 23502
UPDATE customer SET credit_limit = NULL WHERE customer_id = 1;
-- T06 | customer.credit_used NOT NULL | Beklenen: 23502
UPDATE customer SET credit_used = NULL WHERE customer_id = 1;
-- T07 | product.barcode NOT NULL | Beklenen: 23502
UPDATE product SET barcode = NULL WHERE product_id = 1;
-- T08 | product.product_name NOT NULL | Beklenen: 23502
UPDATE product SET product_name = NULL WHERE product_id = 1;
-- T09 | product.category_id NOT NULL | Beklenen: 23502
UPDATE product SET category_id = NULL WHERE product_id = 1;
-- T10 | product.sale_price NOT NULL | Beklenen: 23502
UPDATE product SET sale_price = NULL WHERE product_id = 1;
-- T11 | product.stock_qty NOT NULL | Beklenen: 23502
UPDATE product SET stock_qty = NULL WHERE product_id = 1;
-- T12 | purchase_order.supplier_id NOT NULL | Beklenen: 23502
UPDATE purchase_order SET supplier_id = NULL WHERE order_id = 1;
-- T13 | purchase_order_item.order_id NOT NULL | Beklenen: 23502
UPDATE purchase_order_item SET order_id = NULL WHERE order_item_id = 1;
-- T14 | purchase_order_item.product_id NOT NULL | Beklenen: 23502
UPDATE purchase_order_item SET product_id = NULL WHERE order_item_id = 1;
-- T15 | purchase_order_item.ordered_qty NOT NULL | Beklenen: 23502
UPDATE purchase_order_item SET ordered_qty = NULL WHERE order_item_id = 1;
-- T16 | credit_risk_assessment.customer_id NOT NULL | Beklenen: 23502
UPDATE credit_risk_assessment SET customer_id = NULL WHERE assessment_id = 1;
-- T17 | credit_risk_assessment.risk_score NOT NULL | Beklenen: 23502
UPDATE credit_risk_assessment SET risk_score = NULL WHERE assessment_id = 1;
-- T18 | credit_risk_assessment.decision NOT NULL | Beklenen: 23502
UPDATE credit_risk_assessment SET decision = NULL WHERE assessment_id = 1;
-- T19 | sale.payment_type NOT NULL | Beklenen: 23502
UPDATE sale SET payment_type = NULL WHERE sale_id = 1;
-- T20 | sale_item.sale_id NOT NULL | Beklenen: 23502
UPDATE sale_item SET sale_id = NULL WHERE sale_item_id = 1;
-- T21 | sale_item.product_id NOT NULL | Beklenen: 23502
UPDATE sale_item SET product_id = NULL WHERE sale_item_id = 1;
-- T22 | sale_item.quantity NOT NULL | Beklenen: 23502
UPDATE sale_item SET quantity = NULL WHERE sale_item_id = 1;
-- T23 | shelf_sensor.sensor_code NOT NULL | Beklenen: 23502
UPDATE shelf_sensor SET sensor_code = NULL WHERE sensor_id = 1;

-- ===== UNIQUE (Beklenen: 23505) =====
-- T24 | uq_category_name | Beklenen: 23505
UPDATE category SET category_name = 'Bira' WHERE category_id = 2;
-- T25 | uq_supplier_name | Beklenen: 23505
UPDATE supplier SET supplier_name = 'Supplier One' WHERE supplier_id = 2;
-- T26 | uq_customer_phone | Beklenen: 23505
UPDATE customer SET phone = '1' WHERE customer_id = 2;
-- T27 | uq_product_barcode | Beklenen: 23505
UPDATE product SET barcode = '8690000000001' WHERE product_id = 2;
-- T28 | uq_poi_order_product (çok sütunlu) | Beklenen: 23505
INSERT INTO purchase_order_item (order_id, product_id, ordered_qty, unit_cost) VALUES (1, 1, 5, 24);
-- T29 | uq_sale_item_sale_product (çok sütunlu) | Beklenen: 23505
INSERT INTO sale_item (sale_id, product_id, quantity, unit_price, unit_cost) VALUES (1, 1, 1, 32.50, 24);
-- T30 | uq_sensor_code | Beklenen: 23505
INSERT INTO shelf_sensor (sensor_code, shelf_location) VALUES ('SNS-1', 'Raf Z');

-- ===== CHECK (Beklenen: 23514) =====
-- T31 | chk_supplier_status | Beklenen: 23514
UPDATE supplier SET status = 'unknown' WHERE supplier_id = 1;
-- T32 | chk_supplier_lead_time | Beklenen: 23514
UPDATE supplier SET lead_time_days = 366 WHERE supplier_id = 1;
-- T33 | chk_customer_status | Beklenen: 23514
UPDATE customer SET status = 'unknown' WHERE customer_id = 1;
-- T34 | chk_customer_credit_bounds (iki sütun: credit_used > credit_limit) | Beklenen: 23514
UPDATE customer SET credit_used = 301 WHERE customer_id = 1;
-- T35 | chk_product_price | Beklenen: 23514
UPDATE product SET sale_price = -1 WHERE product_id = 1;
-- T36 | chk_product_stock | Beklenen: 23514
UPDATE product SET stock_qty = -1 WHERE product_id = 1;
-- T37 | chk_product_stock_range (iki sütun: max < min) | Beklenen: 23514
UPDATE product SET max_stock_qty = 5 WHERE product_id = 1;
-- T38 | chk_product_status | Beklenen: 23514
UPDATE product SET status = 'unknown' WHERE product_id = 1;
-- T39 | chk_order_dates (iki sütun: teslim < sipariş tarihi) | Beklenen: 23514
UPDATE purchase_order SET expected_date = '2026-09-30' WHERE order_id = 1;
-- T40 | chk_order_status | Beklenen: 23514
UPDATE purchase_order SET status = 'unknown' WHERE order_id = 1;
-- T41 | chk_poi_ordered_qty | Beklenen: 23514
UPDATE purchase_order_item SET ordered_qty = 0 WHERE order_item_id = 1;
-- T42 | chk_poi_delivered_qty (iki sütun: teslim > sipariş) | Beklenen: 23514
UPDATE purchase_order_item SET delivered_qty = 25 WHERE order_item_id = 1;
-- T43 | chk_risk_score | Beklenen: 23514
UPDATE credit_risk_assessment SET risk_score = 101 WHERE assessment_id = 1;
-- T44 | chk_risk_decision | Beklenen: 23514
UPDATE credit_risk_assessment SET decision = 'maybe' WHERE assessment_id = 1;
-- T45 | chk_sale_payment | Beklenen: 23514
UPDATE sale SET payment_type = 'barter' WHERE sale_id = 1;
-- T46 | chk_sale_credit_customer (kredi satışı, müşteri NULL) | Beklenen: 23514
UPDATE sale SET payment_type = 'credit' WHERE sale_id = 1;
-- T47 | chk_sale_item_quantity | Beklenen: 23514
UPDATE sale_item SET quantity = 0 WHERE sale_item_id = 1;
-- T48 | chk_sale_item_discount | Beklenen: 23514
UPDATE sale_item SET discount_rate = 101 WHERE sale_item_id = 1;
-- T49 | chk_sensor_status | Beklenen: 23514
UPDATE shelf_sensor SET status = 'unknown' WHERE sensor_id = 1;

-- ===== FOREIGN KEY: olmayan ebeveyne kayıt eklemek (Beklenen: 23503) =====
-- T50 | fk_product_category | Beklenen: 23503
INSERT INTO product (barcode, product_name, category_id, cost_price, sale_price) VALUES ('8699999999991', 'X', 999, 1, 2);
-- T51 | fk_product_preferred_supplier | Beklenen: 23503
INSERT INTO product (barcode, product_name, category_id, preferred_supplier_id, cost_price, sale_price) VALUES ('8699999999992', 'X', 1, 999, 1, 2);
-- T52 | fk_purchase_order_supplier | Beklenen: 23503
INSERT INTO purchase_order (supplier_id) VALUES (999);
-- T53 | fk_poi_order | Beklenen: 23503
INSERT INTO purchase_order_item (order_id, product_id, ordered_qty, unit_cost) VALUES (999, 2, 1, 1);
-- T54 | fk_poi_product | Beklenen: 23503
INSERT INTO purchase_order_item (order_id, product_id, ordered_qty, unit_cost) VALUES (1, 999, 1, 1);
-- T55 | fk_risk_customer | Beklenen: 23503
INSERT INTO credit_risk_assessment (customer_id, risk_score, decision, expires_at) VALUES (999, 10, 'approved', '2026-12-31');
-- T56 | fk_sale_customer | Beklenen: 23503
INSERT INTO sale (customer_id, payment_type) VALUES (999, 'card');
-- T57 | fk_sale_item_sale | Beklenen: 23503
INSERT INTO sale_item (sale_id, product_id, quantity, unit_price, unit_cost) VALUES (999, 2, 1, 1, 1);
-- T58 | fk_sale_item_product | Beklenen: 23503
INSERT INTO sale_item (sale_id, product_id, quantity, unit_price, unit_cost) VALUES (2, 999, 1, 1, 1);
-- T59 | fk_sensor_product | Beklenen: 23503
INSERT INTO shelf_sensor (sensor_code, product_id, shelf_location) VALUES ('SNS-9', 999, 'Raf X');

-- ===== FOREIGN KEY: kaydı olan ebeveyni silmek / anahtarını değiştirmek =====
-- RESTRICT ihlali 23001 (restrict_violation), NO ACTION ihlali 23503 (foreign_key_violation) döndürür.
-- T60 | fk_product_category (RESTRICT) | Beklenen: 23001
DELETE FROM category WHERE category_id = 1;
-- T61 | fk_purchase_order_supplier (RESTRICT) | Beklenen: 23001
DELETE FROM supplier WHERE supplier_id = 1;
-- T62 | fk_sale_customer (RESTRICT) | Beklenen: 23001
DELETE FROM customer WHERE customer_id = 1;
-- T63 | fk_sale_item_sale (RESTRICT) | Beklenen: 23001
DELETE FROM sale WHERE sale_id = 1;
-- T64 | fk_risk_customer (ebeveyn anahtarını UPDATE) | Beklenen: 23503
UPDATE customer SET customer_id = 99 WHERE customer_id = 2;

-- ===== SINIR TESTLERİ (Beklenen: OK) =====
-- T65 | chk_poi_ordered_qty | Beklenen: OK (sınır: ordered_qty = 1)
UPDATE purchase_order_item SET ordered_qty = 1 WHERE order_item_id = 1;
-- T66 | chk_order_dates | Beklenen: OK (sınır: teslim tarihi = sipariş tarihi)
UPDATE purchase_order SET expected_date = order_date WHERE order_id = 1;
-- T67 | chk_sale_item_discount | Beklenen: OK (sınır: discount_rate = 100)
UPDATE sale_item SET discount_rate = 100 WHERE sale_item_id = 1;
-- T68 | chk_supplier_lead_time | Beklenen: OK (sınır: lead_time_days = 365)
UPDATE supplier SET lead_time_days = 365 WHERE supplier_id = 1;

-- ===== NULL TESTİ (Beklenen: OK) =====
-- T69 | chk_sale_item_discount (sütun NOT NULL değil) | Beklenen: OK (NULL için CHECK "bilinmiyor" döner, reddetmez)
UPDATE sale_item SET discount_rate = NULL WHERE sale_item_id = 1;

-- ===== SET NULL (Beklenen: OK) =====
-- T70 | fk_product_preferred_supplier (SET NULL) | Beklenen: OK (ürün 2'nin tercihli tedarikçisi NULL olur)
DELETE FROM supplier WHERE supplier_id = 2;
SELECT product_id, preferred_supplier_id FROM product WHERE product_id = 2;
