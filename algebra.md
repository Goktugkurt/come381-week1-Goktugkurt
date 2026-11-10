# Bölüm D: İlişkisel cebir ve hesap

`seed.sql` her tabloya 5–14 satır ekler. Her soru için SQL karşılığı `algebra.sql` içinde aynı numarayla bulunur.

## D1 — Seçim (σ) ve izdüşüm (π)
**Soru:** Stoğu asgari seviyeye eşit veya altında olan aktif ürünler.
```
π product_id, product_name, stock_qty, min_stock_qty ( σ status='active' ∧ stock_qty<=min_stock_qty (PRODUCT) )
```
| product_id | product_name | stock_qty | min_stock_qty |
|---:|---|---:|---:|
| 6 | Patates Cipsi 120 g | 3 | 10 |
| 7 | LPG Tupu | 4 | 5 |
| 8 | Enerji Icecegi 250 ml | 0 | 3 |

**DISTINCT:** Gerekmez; tek tablo ve `product_id` PK. (Ürün 9 pasif olduğu için elenir.)

## D2 — Join (⋈)
**Soru:** Her sipariş kaleminin tedarikçisi, ürünü ve miktarları.
```
π order_id, supplier_name, product_name, ordered_qty, delivered_qty
  ( PURCHASE_ORDER ⋈ SUPPLIER ⋈ PURCHASE_ORDER_ITEM ⋈ PRODUCT )
```
| order_id | supplier_name | product_name | ordered_qty | delivered_qty |
|---:|---|---|---:|---:|
| 1 | Tuborg Dagitim | Tuborg Gold 50 cl | 24 | 24 |
| 1 | Tuborg Dagitim | Efes Malt 50 cl | 20 | 20 |
| 2 | Ege Icecek | Carlsberg 50 cl | 18 | 18 |
| 2 | Ege Icecek | Kavaklidere Kirmizi Sarap | 6 | 6 |
| 3 | Ege Can Yakit | LPG Tupu | 4 | 2 |
| 4 | Metro Atistirmalik | Patates Cipsi 120 g | 30 | 0 |
| 5 | Marmara Icecek | Kola 1 L | 24 | 24 |
| 6 | Tuborg Dagitim | Tuborg Gold 50 cl | 12 | NULL |

**DISTINCT:** Gerekmez; her satır ayrı bir sipariş kalemi (`order_id, product_id` biricik).

## D3 — Birleşim (∪)
**Soru:** Satılmış veya sipariş edilmiş ürünler.
```
π product_id (SALE_ITEM) ∪ π product_id (PURCHASE_ORDER_ITEM)
```
Sonuç `product_id`: 1, 2, 3, 4, 5, 6, 7, 9.

**DISTINCT:** Gerekmez; `UNION` tekrarları zaten kaldırır.

## D4 — Fark (−)
**Soru:** Hiç satılmamış ürünler. SQL'de iki yol var: `EXCEPT` (D4-A) ve `NOT EXISTS` (D4-B); ikisi aynı sonucu verir.
```
π product_id, product_name (PRODUCT)  −  π product_id, product_name (PRODUCT ⋈ SALE_ITEM)
```
| product_id | product_name |
|---:|---|
| 4 | Kavaklidere Kirmizi Sarap |
| 7 | LPG Tupu |
| 8 | Enerji Icecegi 250 ml |

**DISTINCT:** `EXCEPT` küme farkıdır; `NOT EXISTS` sürümünde `product_id` PK olduğu için gerekmez.

## D5 — Rename (ρ) ve self-join
**Soru:** Aynı türde çalışan farklı tedarikçi çiftleri.
```
π s1.supplier_name, s1.supplier_type, s2.supplier_name
  ( σ s1.supplier_type=s2.supplier_type ∧ s1.supplier_id<s2.supplier_id ( ρ s1(SUPPLIER) × ρ s2(SUPPLIER) ) )
```
| supplier_1 | supplier_type | supplier_2 |
|---|---|---|
| Tuborg Dagitim | beverage | Ege Icecek |
| Tuborg Dagitim | beverage | Marmara Icecek |
| Ege Icecek | beverage | Marmara Icecek |
| Metro Atistirmalik | snack | Yerel Gida |

**DISTINCT:** Gerekmez; `s1.supplier_id < s2.supplier_id` her çifti bir kez üretir.

## D6 — Bölme (÷)
**Soru:** *Bira* kategorisindeki bütün aktif ürünleri içeren satış fişleri.
```
π sale_id, product_id (SALE_ITEM)  ÷  π product_id ( σ category_name='Bira' ∧ status='active' (PRODUCT ⋈ CATEGORY) )
```
| sale_id | sold_at |
|---:|---|
| 1 | 2026-10-07 10:00 |
| 4 | 2026-10-09 09:00 |

**Neden çift `NOT EXISTS`:** "Hedef kümedeki hiçbir ürün bu fişte eksik değil" demenin doğrudan yazımıdır; sayım yapmadığı için pasif ürün veya başka kategori sayımı bozamaz.
**DISTINCT:** Gerekmez; dış sorgu PK'sı benzersiz `sale` tablosunu dolaşır.

**Yanıltıcı veri:** Fiş 2'de üç farklı ürün var ama biri Bira değil; fiş 5'te üç Bira var ama ürün 9 pasif (eksik olan aktif Bira: ürün 3). Yalnızca ürün sayan sorgu 1, 2, 4, 5'i; aktiflik filtresi sadece paydada olan `COUNT` sorgusu 1, 4, 5'i döndürür; doğru sorgu yalnızca 1 ve 4'ü döndürür.

## Tuple relational calculus
```
D1: { p.product_id, p.product_name, p.stock_qty, p.min_stock_qty | PRODUCT(p) ∧ p.status='active' ∧ p.stock_qty <= p.min_stock_qty }
D4: { p.product_id, p.product_name | PRODUCT(p) ∧ ¬∃ si ( SALE_ITEM(si) ∧ si.product_id = p.product_id ) }
```
