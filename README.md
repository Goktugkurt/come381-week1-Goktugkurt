# week-05 — Ödev 2

## Çalıştırma sırası

```bash
psql -d come381 -f sql/schema.sql
psql -d come381 -f week-05/constraints.sql
psql -d come381 -f week-05/violations.sql > week-05/violations_output.txt 2>&1
psql -d come381 -f week-05/seed.sql
psql -d come381 -f week-05/algebra.sql
```

Sıra önemli: `violations.sql` tabloları boşaltarak başladığı için `seed.sql` ondan sonra gelir. Windows'ta komutlara `-U postgres` ekle.

## NULL testi (T69)

`sale_item.discount_rate` sütununda `CHECK (discount_rate BETWEEN 0 AND 100)` var ama `NOT NULL` yok. `NULL` için `BETWEEN` sonucu "bilinmiyor" (`UNKNOWN`) olur; `CHECK` yalnızca `false` sonucunu reddettiği için satır **kabul edilir**. NULL istenmiyorsa ayrıca `NOT NULL` gerekir.

## Beklenmeyen şey ve öğrendiğim

D6'yı `COUNT` ile yazınca doğru görünen sorgu, pasif bir ürünü (ürün 9) saydığında yanlış fişi (fiş 5) seçti; yalnızca ürün sayısına bakan sorgu fiş 2'yi de seçti. Çift `NOT EXISTS` sayım yapmadığı için bu tuzaklara düşmüyor.

## Tablolar arası kurallar

"Kredi satışı için geçerli ve onaylı bir risk kaydı olmalı", "satış stoktan düşmeli" gibi birden çok tabloya bakan kurallar `CHECK` ile yazılamaz (PostgreSQL `CREATE ASSERTION` desteklemez). Bunları Hafta 8'de trigger ile yazacağım.
