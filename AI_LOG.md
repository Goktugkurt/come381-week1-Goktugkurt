# Yapay Zekâ Kullanım Kaydı

**Proje:** Otonom Stok Takibi ve Kredi Risk Kontrollü Perakende Veritabanı Mimarisi  
**Ders:** COME 381  
**Öğrenci:** Göktuğ Kurt — Yönetim Bilişim Sistemleri — 202502009061

Bu projede **ChatGPT (OpenAI)** ve **Claude (Anthropic)** yapay zekâ araçlarından yararlanılmıştır. Araçlar; taslak oluşturma, SQL ve ER diyagramı sözdizimini gözden geçirme, test senaryoları geliştirme ve açıklamaları iyileştirme amacıyla kullanılmıştır. Proje senaryosu, veri modeli için verilen iş kararları ve nihai dosyaların sorumluluğu öğrenciye aittir. Yapay zekâ önerileri proje tabloları, örnek veriler ve ders yönergesiyle karşılaştırılmıştır.

## Ödev 1 — ER diyagramı ve veritabanı şeması

ChatGPT ve Claude; varlıkların ve alanların gözden geçirilmesi, tablolar arasındaki ilişkilerin kontrol edilmesi, çoktan-çoğa (M:N) ilişkilerin ara tablolarla modellenmesi ve Mermaid ER diyagramının düzenlenmesi aşamalarında yardımcı olarak kullanılmıştır.

Nihai modelde `purchase_order_item`, sipariş–ürün M:N ilişkisini; `sale_item` ise satış–ürün M:N ilişkisini çözer. Satış anındaki `unit_price` ve `unit_cost` değerlerinin `sale_item` tablosunda saklanması, ürün fiyatı sonradan değiştiğinde geçmiş satış kârının değişmemesi amacıyla tercih edilmiştir. Kredi satışında müşteri bulunması gerekliliği `chk_sale_credit_customer` kuralıyla ifade edilmiştir.

## Ödev 2 — Constraint'ler, ihlal testleri ve ilişkisel cebir

ChatGPT ve Claude; `constraints.sql` dosyasındaki iş kurallarının ve Türkçe açıklama yorumlarının gözden geçirilmesi, `violations.sql` testlerinin tasarlanması, `seed.sql` örnek verilerinin hazırlanması ve `algebra.md` / `algebra.sql` dosyalarının kontrol edilmesi aşamalarında kullanılmıştır.

Birden fazla tabloyu ilgilendiren otomasyon kuralları (örneğin satış sırasında stok güncelleme veya kredi satışında geçerli risk değerlendirmesini kontrol etme) satır seviyesindeki `CHECK` kısıtlarıyla doğrudan doğrulanamaz. Bu kurallar mevcut projede tamamlanmış bir özellik gibi gösterilmemiş, ileride trigger gibi veritabanı mekanizmalarıyla ele alınabilecek geliştirmeler olarak ayrılmıştır.

## D6 — İlişkisel bölme (division) deneyi

### 1. ChatGPT'ye verilen istem

> COME 381 projemde `product`, `category`, `sale` ve `sale_item` tabloları bulunuyor. `product` tablosunda `product_id`, `category_id` ve `status`; `category` tablosunda `category_id` ve `category_name`; `sale` tablosunda `sale_id` ve `sold_at`; `sale_item` tablosunda `sale_id` ve `product_id` alanları var. İlişkisel bölme (division) mantığıyla, Bira kategorisindeki bütün aktif ürünleri içeren satış fişlerini bulan PostgreSQL sorgusunu yaz. Sorguyu iç içe iki `NOT EXISTS` kullanarak kur. Başka kategorideki ürünlerin veya `discontinued` durumundaki bira ürünlerinin sonucu yanlışlıkla sağlamasını önle. Sorgunun neden division işlemini karşıladığını ve nasıl çalıştığını açıkla.

### 2. ChatGPT'nin ürettiği SQL yanıtı

```sql
SELECT s.sale_id, s.sold_at
FROM sale AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM product AS p
    JOIN category AS c
      ON c.category_id = p.category_id
    WHERE c.category_name = 'Bira'
      AND p.status = 'active'
      AND NOT EXISTS (
          SELECT 1
          FROM sale_item AS si
          WHERE si.sale_id = s.sale_id
            AND si.product_id = p.product_id
      )
)
ORDER BY s.sale_id;
```

### 3. Sorgunun açıklaması ve proje seed verisinden beklenen sonuç

Sorgu, her satış fişi için Bira kategorisindeki aktif ürünleri hedef küme olarak belirler. İçteki `NOT EXISTS`, hedef kümedeki bir ürünün ilgili satış fişinde bulunmadığını kontrol eder. Dıştaki `NOT EXISTS` ise böyle eksik bir ürün kalmadığını doğrular. Başka bir ifadeyle, satış fişinde hedef kümedeki **bütün** aktif Bira ürünleri bulunmalıdır. Bu, ilişkisel bölme (division) işleminin mantığıdır.

Projenin `week-05/seed.sql` dosyasındaki aktif Bira ürünlerinin `product_id` değerleri 1, 2 ve 3'tür. Bu üç ürünü birlikte içeren satışlar 1 ve 4 numaralı fişlerdir. Proje seed verisine göre beklenen sonuç:

| sale_id | sold_at | Açıklama |
|---:|---|---|
| 1 | 2026-10-07 10:00 | Aktif Bira ürünleri 1, 2 ve 3'ün tamamı bulunur. |
| 4 | 2026-10-09 09:00 | Aktif Bira ürünleri 1, 2 ve 3'ün tamamı bulunur. |

### 4. OneCompiler üzerinde yapılan D6 testi ve gerçek çıktı

D6 sorgusu, **OneCompiler PostgreSQL** çevrimiçi editöründe ayrı ve küçük bir test ortamı kurularak çalıştırılmıştır. Testte sorgunun kullandığı dört tablo (`category`, `product`, `sale`, `sale_item`) oluşturulmuş ve örnek kayıtlar eklenmiştir. Aşağıdaki kod, OneCompiler'da çalıştırılan test kodudur:

```sql
-- COME 381 - D6 DIVISION TESTI
-- OneCompiler PostgreSQL

DROP TABLE IF EXISTS sale_item, sale, product, category CASCADE;

CREATE TABLE category (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE product (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT,
    category_id INTEGER REFERENCES category(category_id),
    status TEXT
);

CREATE TABLE sale (
    sale_id INTEGER PRIMARY KEY,
    sold_at TIMESTAMP
);

CREATE TABLE sale_item (
    sale_item_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id INTEGER REFERENCES sale(sale_id),
    product_id INTEGER REFERENCES product(product_id)
);

INSERT INTO category VALUES
(1, 'Bira'),
(2, 'Atistirmalik');

INSERT INTO product VALUES
(1, 'Tuborg Gold', 1, 'active'),
(2, 'Carlsberg', 1, 'active'),
(3, 'Efes Malt', 1, 'active'),
(6, 'Patates Cipsi', 2, 'active'),
(9, 'Bomonti', 1, 'discontinued');

INSERT INTO sale VALUES
(1, '2026-10-07 10:00'),
(2, '2026-10-08 11:00'),
(3, '2026-10-08 15:00'),
(4, '2026-10-09 09:00'),
(5, '2026-10-09 10:00');

INSERT INTO sale_item (sale_id, product_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2), (2, 6),
(3, 2), (3, 6),
(4, 1), (4, 2), (4, 3),
(5, 1), (5, 2), (5, 9);

-- Tablo kontrolu
SELECT
    to_regclass('public.sale') AS sale,
    to_regclass('public.sale_item') AS sale_item,
    to_regclass('public.product') AS product,
    to_regclass('public.category') AS category;

-- D6: Iliskisel bolme (division)
SELECT s.sale_id, s.sold_at
FROM sale AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM product AS p
    JOIN category AS c
      ON c.category_id = p.category_id
    WHERE c.category_name = 'Bira'
      AND p.status = 'active'
      AND NOT EXISTS (
          SELECT 1
          FROM sale_item AS si
          WHERE si.sale_id = s.sale_id
            AND si.product_id = p.product_id
      )
)
ORDER BY s.sale_id;
```

**OneCompiler'da alınan gerçek sonuç:** Çalıştırma çıktısında dört `CREATE TABLE` işlemi, kategori için `INSERT 0 2`, ürünler için `INSERT 0 5`, satışlar için `INSERT 0 5` ve satış kalemleri için `INSERT 0 14` mesajları görülmüştür. Tablo kontrolü dört tablonun da bulunduğunu göstermiştir. D6 sorgusu iki satır döndürmüştür:

| sale_id | sold_at |
|---:|---|
| 1 | 2026-10-07 10:00:00 |
| 4 | 2026-10-09 09:00:00 |

Bu çıktı, yukarıdaki **küçük D6 test verisi** için sorgunun beklenen sonucu verdiğini doğrular. İlk çalıştırmada `DROP TABLE IF EXISTS` nedeniyle bazı tabloların bulunmadığını bildiren `NOTICE` mesajları alınmıştır. Bunlar hata değildir; tablolar henüz bulunmadığı için silme işleminin atlandığını bildirir.

**Kapsam notu:** Bu başarılı OneCompiler testi yalnızca D6 sorgusunun kullandığı dört tabloyu ve bu test için eklenen örnek kayıtları kapsar. Projenin tam `schema.sql` dosyasındaki 10 tablonun, tüm constraint'lerin veya `violations.sql` testlerinin çalıştığını kanıtlamaz. İlk denemede `relation "sale" does not exist` hatası alınmasının nedeni, D6 sorgusu çalıştırılırken `sale` tablosunun o oturumda oluşturulmamış olmasıdır. Dört tabloluk kurulum kodu eklendikten sonra yapılan yukarıdaki denemede D6 sonucu başarıyla alınmıştır.

### 5. Yanıltıcı veriler ve hata analizi

Projenin `week-05/seed.sql` dosyasında iki yanıltıcı örnek bulunmaktadır:

- **Satış 2:** Üç farklı ürün (1, 2 ve 6) içerir; ancak ürün 6 atıştırmalık kategorisindedir. Kategori filtresi kullanmadan yalnızca fişteki farklı ürün sayısını aktif Bira ürünlerinin sayısıyla karşılaştıran basit bir `COUNT` yaklaşımı bu fişi yanlışlıkla uygun kabul edebilir.
- **Satış 5:** Ürün 1, 2 ve 9'u içerir. Ürün 9 Bira kategorisindedir ancak durumu `discontinued` olduğu için hedef kümeye dahil değildir. Aktif Bira ürünlerinden ürün 3 bu fişte bulunmadığından satış 5 uygun değildir. Aktiflik filtresini doğru uygulamayan bir `COUNT` yaklaşımı bu fişi yanlışlıkla uygun kabul edebilir.

Çift `NOT EXISTS` çözümü hedef kümeyi açıkça `category_name = 'Bira'` ve `status = 'active'` koşullarıyla oluşturur; ardından bu hedef kümede satış fişinde bulunmayan herhangi bir ürün olup olmadığını denetler. Böylece proje seed verisinde satış 2 ve 5 elenir; beklenen sonuç yalnızca satış 1 ve 4'tür.

## Kullanım ve sorumluluk notu

Yapay zekâ çıktıları doğrudan ve kontrolsüz biçimde nihai çalışma kabul edilmemiştir. Öneriler proje şeması, örnek veri ve ders yönergesiyle karşılaştırılmıştır. OneCompiler'da alınan başarılı D6 çıktısı yukarıda, test kapsamı belirtilerek kaydedilmiştir. Tam 10 tabloluk proje şeması ile tüm constraint ve ihlal testlerinin PostgreSQL üzerinde ayrıca çalıştırılması gerekir. Claude ile yapılan önceki yardıma ait tam konuşma dökümü saklanmadığından Claude'a ait uydurma bir prompt veya yanıt eklenmemiştir.
