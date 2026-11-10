[AI_LOG.md](https://github.com/user-attachments/files/34652440/AI_LOG.md)
# Yapay Zekâ Kullanım Kaydı

**Proje:** Otonom Stok Takibi ve Kredi Risk Kontrollü Perakende Veritabanı Mimarisi  
**Ders:** COME 381  
**Öğrenci:** Göktuğ Kurt — Yönetim Bilişim Sistemleri — 202502009061

Bu projede **ChatGPT (OpenAI)** ve **Claude (Anthropic)** yapay zekâ araçlarından yararlanılmıştır. Araçlar; taslak oluşturma, kod ve ilişkilerin gözden geçirilmesi, sorgu mantığının açıklanması ve metinlerin düzenlenmesi amacıyla kullanılmıştır. Proje senaryosu, nihai tasarım tercihleri ve teslim edilecek içerik üzerindeki son karar öğrenciye aittir.

## Ödev 1 — ER diyagramı ve veritabanı şeması

ChatGPT ve Claude; tablo ve alan adlarının gözden geçirilmesi, varlıklar arasındaki ilişkilerin kontrol edilmesi, çoktan-çoğa (M:N) ilişkilerin ara tablolarla modellenmesi ve Mermaid ER diyagramının düzenlenmesi aşamalarında yardımcı olarak kullanılmıştır.

Nihai modelde `purchase_order_item`, sipariş–ürün M:N ilişkisini; `sale_item` ise satış–ürün M:N ilişkisini çözer. Satış anındaki `unit_price` ve `unit_cost` değerlerinin `sale_item` tablosunda saklanması, ürün fiyatları sonradan değiştiğinde geçmiş satış kârının değişmemesi amacıyla tercih edilmiştir. Kredi satışında müşteri bulunması gerekliliği `chk_sale_credit_customer` kuralıyla ifade edilmiştir.

## Ödev 2 — Constraint'ler, ihlal testleri ve ilişkisel cebir

ChatGPT ve Claude; `constraints.sql` dosyasındaki iş kurallarının ve açıklama yorumlarının gözden geçirilmesi, `violations.sql` testlerinin düzenlenmesi, `seed.sql` örnek verilerinin hazırlanması ve `algebra.md` / `algebra.sql` taslaklarının kontrol edilmesi aşamalarında kullanılmıştır.

Birden fazla tabloyu ilgilendiren otomasyon kuralları (örneğin satış sırasında stok güncelleme veya kredi satışında geçerli risk değerlendirmesini kontrol etme) bu ödevde `CHECK` kısıtlarıyla uygulanmamıştır. Bu tür kuralların PostgreSQL'de tablo seviyesini aşan kontrol gerektirdiği ve ileride trigger gibi veritabanı mekanizmalarıyla ele alınabileceği not edilmiştir.

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

### 3. Sorgunun açıklaması ve seed verisiyle beklenen sonuç

Sorgu, her satış fişi için Bira kategorisindeki aktif ürünleri hedef küme olarak belirler. İçteki `NOT EXISTS`, hedef kümedeki bir ürünün ilgili satış fişinde bulunmadığını kontrol eder. Dıştaki `NOT EXISTS` ise böyle eksik bir ürün kalmadığını doğrular. Başka bir ifadeyle, satış fişinde hedef kümedeki **bütün** aktif Bira ürünleri bulunmalıdır. Bu, ilişkisel bölme (division) işleminin mantığıdır.

`week-05/seed.sql` verisinde aktif Bira ürünlerinin `product_id` değerleri 1, 2 ve 3'tür. Satış kalemleri incelendiğinde bu üç ürünü birlikte içeren fişler 1 ve 4'tür. Seed verisine göre sorgunun beklenen sonucu şöyledir:

| sale_id | sold_at | Açıklama |
|---:|---|---|
| 1 | 2026-10-07 10:00 | Aktif Bira ürünleri 1, 2 ve 3'ün tamamı bulunur. |
| 4 | 2026-10-09 09:00 | Aktif Bira ürünleri 1, 2 ve 3'ün tamamı bulunur. |

**Çalıştırma doğrulaması:** OneCompiler PostgreSQL editöründe D6 sorgusu tek başına çalıştırıldığında `ERROR: relation "sale" does not exist` hatası alınmıştır. Sonraki tablo kontrolünde `sale`, `sale_item`, `product` ve `category` tablolarının da mevcut olmadığı görülmüştür. Bu, sorgunun çalıştırıldığı oturumda şemanın oluşturulmadığını gösterir; sorgunun başarılı PostgreSQL çalıştırma sonucu değildir. Bu nedenle yukarıdaki 1 ve 4 numaralı fişler, `seed.sql` verisi sorgu koşullarına göre incelenerek belirlenen **beklenen sonuçtur**; gerçek PostgreSQL çıktısı olarak sunulmamaktadır. Başarılı doğrulama için şema, constraint'ler ve seed verisi aynı PostgreSQL veritabanında oluşturulduktan sonra D6 sorgusu yeniden çalıştırılmalıdır.

### 4. Yanıltıcı veriler ve hata analizi

Seed verisinde iki yanıltıcı örnek bulunmaktadır:

- **Satış 2:** Üç farklı ürün (1, 2 ve 6) içerir; ancak ürün 6 atıştırmalık kategorisindedir. Kategori filtresi kullanmadan yalnızca fişteki farklı ürün sayısını aktif Bira ürünlerinin sayısıyla karşılaştıran basit bir `COUNT` yaklaşımı bu fişi yanlışlıkla uygun kabul edebilir.
- **Satış 5:** Ürün 1, 2 ve 9'u içerir. Ürün 9 Bira kategorisindedir ancak durumu `discontinued` olduğu için hedef kümesine dahil değildir. Aktiflik koşulunu doğru uygulamayan bir `COUNT` yaklaşımı bu fişi yanlışlıkla uygun kabul edebilir. Aktif Bira ürünlerinden ürün 3 bu fişte bulunmaz.

Çift `NOT EXISTS` çözümü hedef kümeyi açıkça `category_name = 'Bira'` ve `status = 'active'` koşullarıyla oluşturur; ardından hedef kümedeki eksik bir ürün bulunup bulunmadığını denetler. Bu nedenle satış 2 ve 5 elenir; seed verisine göre beklenen sonuç yalnızca satış 1 ve 4'tür.

## Kullanım ve sorumluluk notu

Yapay zekâ çıktıları doğrudan ve kontrolsüz biçimde nihai çalışma kabul edilmemiştir. Öneriler proje şeması, örnek veri ve ders yönergesiyle karşılaştırılmıştır. Gerçek PostgreSQL çalıştırma sonuçları ancak ilgili SQL kodları PostgreSQL ortamında başarıyla çalıştırıldıktan sonra doğrulanmış sonuç olarak raporlanacaktır.
