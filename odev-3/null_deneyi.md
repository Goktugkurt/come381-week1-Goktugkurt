# NULL deneyi

## Deney 1

```sql
SELECT COUNT(*), COUNT(phone) FROM customer;
```

**Tahminim:** 16

**Sonuç:** `COUNT(*)` = 8, `COUNT(phone)` = 5

**Yorum:** `COUNT(*)` NULL olsun olmasın tüm satırları sayar (8 müşteri). `COUNT(phone)` ise yalnızca telefonu dolu olan satırları sayar. Mehmet Kaya, Can Arslan ve Selin Öztürk'ün telefonu NULL olduğu için 8 - 3 = 5 çıktı.

## Deney 2

```sql
SELECT AVG(age), SUM(age) / COUNT(*) FROM customer;
```

**Tahminim:** 20

**Sonuç:** `AVG(age)` = 20.8333..., `SUM(age) / COUNT(*)` = 15

**Yorum:** `AVG` NULL yaşları (Elif Yıldız ve Can Arslan) hesaba katmaz: 125 / 6 = 20.83. İkinci ifadede `SUM(age)` yine 125 verir ama `COUNT(*)` 8 satırı da saydığı için 125 / 8 olur. İki sayı da tam sayı (integer) olduğundan PostgreSQL tam sayı bölmesi yapar ve ondalık kısmı yuvarlamadan atar: 15.625 yerine 15 çıkar. Yani NULL'ı yok sayıp ortalama almak ile NULL'ı da paydaya katmak farklı sonuç verir.
