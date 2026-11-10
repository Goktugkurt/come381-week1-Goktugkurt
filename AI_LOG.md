# Yapay Zekâ Kullanım Kaydı

Kullanılan araçlar: ChatGPT (projenin önceki sürümleri) ve Claude (Anthropic).

## Ödev 1

Tablo/ilişki yapısının gözden geçirilmesi, M:N ilişkilerin ara tabloyla çözülmesi ve Mermaid sözdiziminin kontrolü için kullanıldı. Tasarım kararlarını (fiyat ve maliyetin `sale_item` içinde saklanması, kredi satışında zorunlu müşteri) ben verdim.

## Ödev 2

Kullanım alanı: `constraints.sql` kural ve yorumları, `violations.sql` düzeni, `seed.sql`, `algebra.md` / `algebra.sql` taslakları. Son aşamada Claude ile kodları sadeleştirdim: tetikleyiciler (Hafta 8 konusu) çıkarıldı, ihlal testleri tek deyimlik testlere indirildi, seed ve sorgular SQLite'ta denendi.

### D6 (division) denemesi

**1. Prompt (aynen):**

> [TODO: D6 için yapay zekâ aracına gerçekten yazdığın prompt]

**2. Gelen sorgu (aynen):**

```sql
-- [TODO: aracın verdiği SQL]
```

**3. Kendi verimde çalıştırma:** [TODO: sonuç; doğru sonuç fiş 1 ve 4]

**4. Hata nerede / yanıltıcı veri:** Seed'e iki tuzak eklendi. Fiş 2: üç farklı ürün var ama biri Bira değil. Fiş 5: üç Bira var ama ürün 9 pasif. Yalnızca ürün sayan `COUNT` sorgusu 1, 2, 4, 5; aktiflik filtresi sadece paydada olan `COUNT` sorgusu 1, 4, 5 döndürür; doğrusu 1 ve 4'tür.
