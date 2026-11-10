-- COME 381 / Ödev 2 D: örnek veri. schema.sql + constraints.sql sonrasında çalışır; eski verileri siler.
TRUNCATE category, supplier, customer, product, purchase_order, purchase_order_item,
         credit_risk_assessment, sale, sale_item, shelf_sensor RESTART IDENTITY CASCADE;

INSERT INTO category (category_name, is_age_restricted) VALUES
('Bira', true), ('Sarap', true), ('Mesrubat', false), ('Atistirmalik', false), ('Tup ve Yakit', false);

INSERT INTO supplier (supplier_name, supplier_type, phone, status, lead_time_days) VALUES
('Tuborg Dagitim', 'beverage', '02120000001', 'active', 2),
('Ege Icecek', 'beverage', '02120000002', 'active', 1),
('Ege Can Yakit', 'fuel', '02120000003', 'active', 1),
('Metro Atistirmalik', 'snack', '02120000004', 'active', 3),
('Yerel Gida', 'snack', '02120000005', 'active', 2),
('Marmara Icecek', 'beverage', '02120000006', 'active', 2);

INSERT INTO customer (customer_name, phone, credit_limit, credit_used, status) VALUES
('Musteri A', '05550000001', 300, 118.75, 'active'),
('Musteri B', '05550000002', 100, 97.50, 'active'),
('Musteri C', '05550000003', 200, 0, 'active'),
('Musteri D', '05550000004', 100, 0, 'active'),
('Musteri E', '05550000005', 200, 0, 'active'),
('Musteri F', '05550000006', 150, 0, 'blocked');

-- Ürün 9 pasiftir (discontinued): D6'daki "aktiflik" tuzağı.
INSERT INTO product (barcode, product_name, category_id, preferred_supplier_id, cost_price, sale_price, stock_qty, min_stock_qty, max_stock_qty, status) VALUES
('8690000000001', 'Tuborg Gold 50 cl', 1, 1, 24, 32.50, 39, 10, 80, 'active'),
('8690000000002', 'Carlsberg 50 cl', 1, 2, 25, 34, 22, 8, 60, 'active'),
('8690000000003', 'Efes Malt 50 cl', 1, 1, 23, 31, 24, 8, 50, 'active'),
('8690000000004', 'Kavaklidere Kirmizi Sarap', 2, 2, 150, 195, 14, 5, 40, 'active'),
('8690000000005', 'Kola 1 L', 3, 6, 20, 29, 43, 12, 60, 'active'),
('8690000000006', 'Patates Cipsi 120 g', 4, 4, 18, 27.50, 3, 10, 45, 'active'),
('8690000000007', 'LPG Tupu', 5, 3, 550, 650, 4, 5, 15, 'active'),
('8690000000008', 'Enerji Icecegi 250 ml', 3, 6, 22, 32, 0, 3, 20, 'active'),
('8690000000009', 'Bomonti Filtresiz 50 cl', 1, 2, 22, 30, 4, 5, 40, 'discontinued');

INSERT INTO purchase_order (supplier_id, order_date, expected_date, status) VALUES
(1, '2026-10-01', '2026-10-03', 'delivered'),
(2, '2026-10-02', '2026-10-04', 'delivered'),
(3, '2026-10-03', '2026-10-05', 'sent'),
(4, '2026-10-04', '2026-10-07', 'delivered'),
(6, '2026-10-05', '2026-10-07', 'delivered'),
(1, '2026-10-08', '2026-10-10', 'sent');

INSERT INTO purchase_order_item (order_id, product_id, ordered_qty, delivered_qty, unit_cost) VALUES
(1, 1, 24, 24, 24), (1, 3, 20, 20, 23), (2, 2, 18, 18, 25), (2, 4, 6, 6, 150),
(3, 7, 4, 2, 550), (4, 6, 30, 0, 18), (5, 5, 24, 24, 20), (6, 1, 12, NULL, 24.50);

INSERT INTO credit_risk_assessment (customer_id, risk_score, decision, assessed_at, expires_at, notes) VALUES
(1, 20, 'approved', '2026-10-06 09:00', '2027-10-06', 'Onayli'),
(2, 40, 'approved', '2026-10-06 09:00', '2027-10-06', 'Onayli'),
(3, 88, 'rejected', '2026-10-06 09:00', '2027-10-06', 'Yuksek risk'),
(4, 30, 'approved', '2026-09-01 09:00', '2026-10-01', 'Suresi dolmus'),
(5, 75, 'approved', '2026-10-06 09:00', '2027-10-06', 'Puan esigi ustu'),
(6, 30, 'approved', '2026-10-06 09:00', '2027-10-06', 'Hesap bloke');

INSERT INTO sale (customer_id, sold_at, payment_type) VALUES
(NULL, '2026-10-07 10:00', 'cash'),
(1, '2026-10-08 11:00', 'credit'),
(2, '2026-10-08 15:00', 'card'),
(2, '2026-10-09 09:00', 'credit'),
(NULL, '2026-10-09 10:00', 'cash');

-- D6 verisi: aktif Bira ürünleri 1, 2, 3. Hepsini içeren fişler: 1 ve 4.
-- Fiş 2 üç farklı ürün içerir ama biri Bira değil; fiş 5'teki ürün 9 pasiftir (eksik olan aktif Bira: 3).
INSERT INTO sale_item (sale_id, product_id, quantity, unit_price, unit_cost, discount_rate) VALUES
(1, 1, 2, 32.50, 24, 0), (1, 2, 1, 34, 25, NULL), (1, 3, 1, 31, 23, 0),
(2, 1, 1, 32.50, 24, 0), (2, 2, 1, 34, 25, 0), (2, 6, 2, 27.50, 18, 5),
(3, 2, 2, 34, 25, 0), (3, 5, 1, 29, 20, NULL),
(4, 1, 1, 32.50, 24, 0), (4, 2, 1, 34, 25, 0), (4, 3, 1, 31, 23, 0),
(5, 1, 1, 32.50, 24, 0), (5, 2, 1, 34, 25, 0), (5, 9, 1, 30, 22, 0);

INSERT INTO shelf_sensor (sensor_code, product_id, shelf_location, status, last_reading_qty, last_seen_at) VALUES
('SNS-001', 1, 'Raf A1', 'online', 39, '2026-10-09 12:00'),
('SNS-002', 2, 'Raf A2', 'online', 22, '2026-10-09 12:00'),
('SNS-003', 3, 'Raf A3', 'offline', 24, '2026-10-08 12:00'),
('SNS-004', 6, 'Raf B1', 'online', 3, '2026-10-09 12:00'),
('SNS-005', NULL, 'Raf C1', 'maintenance', NULL, '2026-10-07 12:00');
