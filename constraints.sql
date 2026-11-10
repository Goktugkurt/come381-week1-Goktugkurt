-- COME 381 / Ödev 2 A: iş kuralları. schema.sql'den sonra, veri yüklenmeden önce çalışır.

-- NOT NULL: boş kalmaması gereken sütunlar.
-- Her kategorinin adı olmalı.
ALTER TABLE category ALTER COLUMN category_name SET NOT NULL;
-- Tedarikçinin adı ve durumu olmalı.
ALTER TABLE supplier ALTER COLUMN supplier_name SET NOT NULL, ALTER COLUMN status SET NOT NULL;
-- Müşterinin adı ve kredi bilgisi olmalı (limit kontrolü NULL ile atlatılamasın).
ALTER TABLE customer ALTER COLUMN customer_name SET NOT NULL, ALTER COLUMN credit_limit SET NOT NULL,
                     ALTER COLUMN credit_used SET NOT NULL;
-- Ürünün barkodu, adı, kategorisi, satış fiyatı ve stoğu olmalı.
ALTER TABLE product ALTER COLUMN barcode SET NOT NULL, ALTER COLUMN product_name SET NOT NULL,
                    ALTER COLUMN category_id SET NOT NULL, ALTER COLUMN sale_price SET NOT NULL,
                    ALTER COLUMN stock_qty SET NOT NULL;
-- Her siparişin bir tedarikçisi olmalı.
ALTER TABLE purchase_order ALTER COLUMN supplier_id SET NOT NULL;
-- Sipariş kalemi bir siparişe, bir ürüne ve bir miktara bağlı olmalı (M:N ara tablo).
ALTER TABLE purchase_order_item ALTER COLUMN order_id SET NOT NULL, ALTER COLUMN product_id SET NOT NULL,
                                ALTER COLUMN ordered_qty SET NOT NULL;
-- Risk değerlendirmesinin müşterisi, puanı ve kararı olmalı.
ALTER TABLE credit_risk_assessment ALTER COLUMN customer_id SET NOT NULL, ALTER COLUMN risk_score SET NOT NULL,
                                   ALTER COLUMN decision SET NOT NULL;
-- Satışın ödeme tipi olmalı.
ALTER TABLE sale ALTER COLUMN payment_type SET NOT NULL;
-- Satış satırı bir fişe, bir ürüne ve bir miktara bağlı olmalı (M:N ara tablo).
ALTER TABLE sale_item ALTER COLUMN sale_id SET NOT NULL, ALTER COLUMN product_id SET NOT NULL,
                      ALTER COLUMN quantity SET NOT NULL;
-- Sensörün kodu olmalı.
ALTER TABLE shelf_sensor ALTER COLUMN sensor_code SET NOT NULL;

-- UNIQUE
-- Kategori adları tekrar edemez.
ALTER TABLE category ADD CONSTRAINT uq_category_name UNIQUE (category_name);
-- Tedarikçi adları tekrar edemez.
ALTER TABLE supplier ADD CONSTRAINT uq_supplier_name UNIQUE (supplier_name);
-- Aynı telefon iki müşteride bulunamaz (NULL telefon serbest).
ALTER TABLE customer ADD CONSTRAINT uq_customer_phone UNIQUE (phone);
-- Her barkod tek ürüne aittir.
ALTER TABLE product ADD CONSTRAINT uq_product_barcode UNIQUE (barcode);
-- Aynı ürün aynı siparişe iki kez kalem olarak eklenemez (çok sütunlu).
ALTER TABLE purchase_order_item ADD CONSTRAINT uq_poi_order_product UNIQUE (order_id, product_id);
-- Aynı ürün aynı satış fişinde iki ayrı satır olamaz (çok sütunlu).
ALTER TABLE sale_item ADD CONSTRAINT uq_sale_item_sale_product UNIQUE (sale_id, product_id);
-- Sensör kodları tekrar edemez.
ALTER TABLE shelf_sensor ADD CONSTRAINT uq_sensor_code UNIQUE (sensor_code);

-- CHECK
-- Tedarikçi durumu yalnızca active, suspended veya closed olabilir.
ALTER TABLE supplier ADD CONSTRAINT chk_supplier_status CHECK (status IN ('active','suspended','closed'));
-- Tedarik süresi 0 ile 365 gün arasındadır.
ALTER TABLE supplier ADD CONSTRAINT chk_supplier_lead_time CHECK (lead_time_days BETWEEN 0 AND 365);
-- Müşteri durumu yalnızca active, blocked veya closed olabilir.
ALTER TABLE customer ADD CONSTRAINT chk_customer_status CHECK (status IN ('active','blocked','closed'));
-- Kullanılan kredi negatif olamaz ve müşterinin limitini aşamaz (iki sütun karşılaştırması).
ALTER TABLE customer ADD CONSTRAINT chk_customer_credit_bounds CHECK (credit_used >= 0 AND credit_used <= credit_limit);
-- Alış ve satış fiyatı negatif olamaz.
ALTER TABLE product ADD CONSTRAINT chk_product_price CHECK (cost_price >= 0 AND sale_price >= 0);
-- Stok ve minimum stok negatif olamaz.
ALTER TABLE product ADD CONSTRAINT chk_product_stock CHECK (stock_qty >= 0 AND min_stock_qty >= 0);
-- Maksimum stok tanımlıysa minimum stoktan küçük olamaz (iki sütun karşılaştırması).
ALTER TABLE product ADD CONSTRAINT chk_product_stock_range CHECK (max_stock_qty IS NULL OR max_stock_qty >= min_stock_qty);
-- Ürün durumu yalnızca active, inactive veya discontinued olabilir.
ALTER TABLE product ADD CONSTRAINT chk_product_status CHECK (status IN ('active','inactive','discontinued'));
-- Beklenen teslim tarihi sipariş tarihinden önce olamaz (iki sütun karşılaştırması).
ALTER TABLE purchase_order ADD CONSTRAINT chk_order_dates CHECK (expected_date IS NULL OR expected_date >= order_date);
-- Sipariş durumu yalnızca draft, sent, delivered veya cancelled olabilir.
ALTER TABLE purchase_order ADD CONSTRAINT chk_order_status CHECK (status IN ('draft','sent','delivered','cancelled'));
-- Sipariş miktarı sıfırdan büyük olmalıdır.
ALTER TABLE purchase_order_item ADD CONSTRAINT chk_poi_ordered_qty CHECK (ordered_qty > 0);
-- Teslim edilen adet 0 ile sipariş adedi arasındadır; teslim yoksa NULL olabilir (iki sütun karşılaştırması).
ALTER TABLE purchase_order_item ADD CONSTRAINT chk_poi_delivered_qty CHECK (delivered_qty IS NULL OR (delivered_qty >= 0 AND delivered_qty <= ordered_qty));
-- Risk puanı 0 ile 100 arasındadır.
ALTER TABLE credit_risk_assessment ADD CONSTRAINT chk_risk_score CHECK (risk_score BETWEEN 0 AND 100);
-- Risk kararı yalnızca approved veya rejected olabilir.
ALTER TABLE credit_risk_assessment ADD CONSTRAINT chk_risk_decision CHECK (decision IN ('approved','rejected'));
-- Ödeme tipi cash, card, credit veya other olmalıdır.
ALTER TABLE sale ADD CONSTRAINT chk_sale_payment CHECK (payment_type IN ('cash','card','credit','other'));
-- Kredi satışında müşteri zorunludur; nakit/kart satışta NULL olabilir.
ALTER TABLE sale ADD CONSTRAINT chk_sale_credit_customer CHECK (payment_type <> 'credit' OR customer_id IS NOT NULL);
-- Satılan miktar sıfırdan büyük olmalıdır.
ALTER TABLE sale_item ADD CONSTRAINT chk_sale_item_quantity CHECK (quantity > 0);
-- İndirim oranı 0 ile 100 arasındadır. Sütun NOT NULL değil: NULL için CHECK "bilinmiyor" döner ve kabul edilir.
ALTER TABLE sale_item ADD CONSTRAINT chk_sale_item_discount CHECK (discount_rate BETWEEN 0 AND 100);
-- Sensör durumu online, offline veya maintenance olabilir.
ALTER TABLE shelf_sensor ADD CONSTRAINT chk_sensor_status CHECK (status IN ('online','offline','maintenance'));
