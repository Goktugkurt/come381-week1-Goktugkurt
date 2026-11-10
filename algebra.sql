-- COME 381 / Ödev 2 D: D1-D6 SQL karşılıkları. seed.sql'den sonra çalışır.

-- D1: seçim + izdüşüm: stoğu asgari seviyeye eşit veya altında olan aktif ürünler.
SELECT product_id, product_name, stock_qty, min_stock_qty
FROM product WHERE status = 'active' AND stock_qty <= min_stock_qty ORDER BY product_id;

-- D2: join: her sipariş kaleminin tedarikçisi, ürünü ve miktarları.
SELECT po.order_id, s.supplier_name, p.product_name, poi.ordered_qty, poi.delivered_qty
FROM purchase_order po
JOIN supplier s ON s.supplier_id = po.supplier_id
JOIN purchase_order_item poi ON poi.order_id = po.order_id
JOIN product p ON p.product_id = poi.product_id
ORDER BY po.order_id, p.product_id;

-- D3: birleşim: satılmış veya sipariş edilmiş ürünler.
SELECT product_id FROM sale_item
UNION
SELECT product_id FROM purchase_order_item
ORDER BY product_id;

-- D4-A: fark (EXCEPT): hiç satılmamış ürünler.
SELECT product_id, product_name FROM product
EXCEPT
SELECT p.product_id, p.product_name FROM product p JOIN sale_item si ON si.product_id = p.product_id
ORDER BY product_id;

-- D4-B: aynı fark (NOT EXISTS).
SELECT p.product_id, p.product_name FROM product p
WHERE NOT EXISTS (SELECT 1 FROM sale_item si WHERE si.product_id = p.product_id)
ORDER BY p.product_id;

-- D5: rename + self-join: aynı türde çalışan farklı tedarikçi çiftleri.
SELECT s1.supplier_name AS supplier_1, s1.supplier_type, s2.supplier_name AS supplier_2
FROM supplier s1 JOIN supplier s2 ON s1.supplier_type = s2.supplier_type AND s1.supplier_id < s2.supplier_id
ORDER BY s1.supplier_id, s2.supplier_id;

-- D6: division (çift NOT EXISTS): tüm aktif Bira ürünlerini içeren satış fişleri.
SELECT s.sale_id, s.sold_at FROM sale s
WHERE NOT EXISTS (
  SELECT 1 FROM product p JOIN category c ON c.category_id = p.category_id
  WHERE c.category_name = 'Bira' AND p.status = 'active'
    AND NOT EXISTS (SELECT 1 FROM sale_item si WHERE si.sale_id = s.sale_id AND si.product_id = p.product_id))
ORDER BY s.sale_id;
