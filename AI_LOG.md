# Yapay Zekâ Kullanım Kaydı

**Proje:** Otonom Stok Takibi ve Kredi Risk Kontrollü Perakende Veritabanı Mimarisi  
**Ders:** COME 381  
**Öğrenci:** Göktuğ Kurt — Yönetim Bilişim Sistemleri — 202502009061

Bu projede **ChatGPT (OpenAI)** ve **Claude (Anthropic)** yapay zekâ araçlarından yararlanılmıştır. Yapay zekâ önerileri taslak oluşturma, kodu gözden geçirme ve açıklamaları iyileştirme amacıyla kullanılmış; proje senaryosu ve nihai tasarım tercihleri öğrenci tarafından belirlenmiştir.

## Ödev 1 — ER diyagramı ve veritabanı şeması

ChatGPT ve Claude; tablo/alan adlarının gözden geçirilmesi, varlıklar arasındaki ilişkilerin kontrol edilmesi, M:N ilişkilerin ara tablolarla modellenmesi ve Mermaid ER diyagramının düzenlenmesi aşamalarında yardımcı olarak kullanılmıştır.

Nihai modelde `purchase_order_item`, sipariş–ürün M:N ilişkisini; `sale_item` ise satış–ürün M:N ilişkisini çözer. Satış anındaki `unit_price` ve `unit_cost` değerlerinin `sale_item` tablosunda saklanması kararı, ürün fiyatları sonradan değiştiğinde geçmiş satış kârının değişmemesi amacıyla verilmiştir. Kredi satışında müşteri bulunması gerekliliği `chk_sale_credit_customer` kuralıyla ifade edilmiştir.

## Ödev 2 — Constraint'ler, ihlal testleri ve ilişkisel cebir

ChatGPT ve Claude; `constraints.sql` dosyasındaki iş kurallarının ve açıklama yorumlarının gözden geçirilmesi, `violations.sql` test düzeninin oluşturulması, `seed.sql` örnek verilerinin hazırlanması ve `algebra.md` / `algebra.sql` taslaklarının kontrol edilmesi aşamalarında kullanılmıştır.

Claude'dan alınan inceleme/sadeleştirme önerileri doğrultusunda Hafta 8 kapsamında ele alınacak tablolar arası otomasyon kuralları (örneğin satış sırasında stok güncelleme) bu ödevin kapsamından ayrı tutulmuştur. Önceki geliştirme aşamasında seed ve sorgular için SQLite üzerinde ön kontrol yapıldığı belirtilmiştir; bu kontrol PostgreSQL üzerinde çalıştırma ve doğrulama yerine geçmez. Teslimde esas alınan veritabanı PostgreSQL'dir.

### D6 — İlişkisel bölme (division) deneyi

Bu bölümdeki D6 istemi ve ChatGPT yanıtı, AI kullanım kaydını tamamlamak için bu çalışma sırasında oluşturulup kontrol edilmiştir. Claude ile yapılan önceki sadeleştirme çalışmasının tam konuşma dökümü saklanmadığından Claude için uydurma bir prompt veya yanıt eklenmemiştir.

**1. D6 için kullanılan ChatGPT istemi**

> COME 381 projemde `product`, `category`, `sale` ve `sale_item` tabloları bulunuyor. `product` tablosunda `product_id`, `category_id` ve `status`; `category` tablosunda `category_id` ve `category_name`; `sale` tablosunda `sale_id` ve `sold_at`; `sale_item` tablosunda `sale_id` ve `product_id` alanları var. İlişkisel bölme (division) mantığıyla, Bira kategorisindeki bütün aktif ürünleri içeren satış fişlerini bulan PostgreSQL sorgusunu yaz. Sorguyu iç içe iki `NOT EXISTS` kullanarak kur. Başka kategorideki ürünlerin veya `discontinued` durumundaki bira ürünlerinin sonucu yanlışlıkla sağlamasını önle. Sorgunun neden division işlemini karşıladığını ve nasıl çalıştığını açıkla.

**2. ChatGPT'nin ürettiği SQL yanıtı**

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

Bu sorgu, her satış fişi için Bira kategorisindeki aktif ürünleri tarar. İçteki `NOT EXISTS`, ilgili ürünün fişte bulunmadığını; dıştaki `NOT EXISTS` ise eksik aktif bira ürünü kalmadığını ifade eder. Böylece yalnızca hedef kümedeki bütün ürünleri içeren fişler döner.

**3. Proje sorgusuyla karşılaştırma ve seed verisinden beklenen sonuç**

Üretilen sorgu, `week-05/algebra.sql` dosyasındaki D6 sorgusuyla aynı çift `NOT EXISTS` mantığını kullanır. `week-05/seed.sql` içindeki aktif Bira ürünleri `product_id` 1, 2 ve 3'tür. Bu üç ürünü birlikte içeren satışlar `sale_id` 1 ve 4'tür. Bu nedenle seed verisine göre beklenen sonuç şöyledir:

| sale_id | Beklenen açıklama |
|---:|---|
| 1 | Aktif Bira ürünleri 1, 2 ve 3'ün tamamı var. |
| 4 | Aktif Bira ürünleri 1, 2 ve 3'ün tamamı var. |

**Çalıştırma doğrulaması hakkında:** Bu kayıt hazırlanırken sorgu yerel PostgreSQL sunucusunda çalıştırılmamıştır. Yukarıdaki 1 ve 4 sonucu, `seed.sql` kayıtları sorgu koşuluna göre incelenerek belirlenen beklenen sonuçtur; gerçek `psql` çıktısı olarak sunulmamaktadır. PostgreSQL'de doğrulama için `psql -d come381 -f week-05/algebra.sql` komutu çalıştırılmalı ve gerçek terminal sonucu bu kayda eklenmelidir.

**4. Yanıltıcı veriler ve hata analizi**

Seed verisinde iki yanıltıcı örnek bulunmaktadır:

- **Satış 2:** Üç farklı ürün içerir; ancak bunlardan biri atıştırmalıktır. Yalnızca fişteki farklı ürün sayısını aktif Bira ürünlerinin sayısıyla karşılaştıran ve kategori filtresi uygulamayan bir `COUNT` sorgusu bu fişi yanlışlıkla uygun kabul edebilir.
- **Satış 5:** Üç Bira ürünü içeriyor gibi görünür; fakat ürün 9'un durumu `discontinued`'dır. Aktiflik koşulunu doğru ürün kümesine uygulamayan bir `COUNT` sorgusu bu fişi yanlışlıkla uygun kabul edebilir. Aktif Bira ürünlerinden ürün 3 bu fişte yoktur.

Çift `NOT EXISTS` çözümü, önce hedef kümesini açıkça `category_name = 'Bira'` ve `status = 'active'` koşullarıyla kurar; sonra bu hedef kümede satış fişinde bulunmayan herhangi bir ürün olup olmadığını sınar. Bu nedenle satış 2 ve 5 elenir; seed verisine göre doğru adaylar yalnızca 1 ve 4'tür.

## Kullanım ve sorumluluk notu

Yapay zekâ çıktıları doğrudan ve kontrolsüz biçimde nihai çalışma kabul edilmemiştir. SQL ve tasarım kararları proje şeması, seed verisi ve ders yönergesiyle karşılaştırılmıştır. Gerçek PostgreSQL çalıştırma sonuçları yalnızca veritabanında çalıştırıldıktan sonra doğrulanmış sonuç olarak raporlanacaktır.
