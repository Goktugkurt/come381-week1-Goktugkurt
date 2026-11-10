# Bölüm C: Silme politikaları

| Foreign key | Ebeveyn → çocuk | Seçim | Neden | Diğer seçenek neden olmadı |
|---|---|---|---|---|
| `fk_product_category` | category → product | `RESTRICT` | Kategorisiz ürün kalmamalı. | `CASCADE` kategorideki tüm ürünleri silerdi. |
| `fk_product_preferred_supplier` | supplier → product | `SET NULL` | Tercihli tedarikçi isteğe bağlı; ürün ve stoğu kalmalı. | `CASCADE` ürünleri silerdi; `RESTRICT` tedarikçiyi gereksiz kilitlerdi. |
| `fk_purchase_order_supplier` | supplier → purchase_order | `RESTRICT` | Eski siparişlerin tedarikçisi bilinmeli. | `CASCADE` sipariş geçmişini silerdi; `SET NULL` sipariş sütunu `NOT NULL` olduğu için hata verirdi. |
| `fk_poi_order` | purchase_order → purchase_order_item | `CASCADE` | Siparişsiz kalemin anlamı yok. | `RESTRICT` siparişi silmeyi imkânsız kılardı. |
| `fk_poi_product` | product → purchase_order_item | `RESTRICT` | Sipariş geçmişindeki ürün silinmemeli. | `CASCADE` sipariş kalemlerini silerdi. |
| `fk_risk_customer` | customer → credit_risk_assessment | `RESTRICT` | Risk geçmişi yanlışlıkla kaybolmamalı. | `CASCADE` risk geçmişini silerdi. |
| `fk_sale_customer` | customer → sale | `RESTRICT` | Satış (özellikle kredi satışı) müşterisini kaybetmemeli. | `SET NULL`, kredi satışında `chk_sale_credit_customer`'a takılırdı. |
| `fk_sale_item_sale` | sale → sale_item | `RESTRICT` | Satırlı fişin finansal kaydı korunur. | `CASCADE` satış geçmişini silerdi. |
| `fk_sale_item_product` | product → sale_item | `RESTRICT` | Satılan ürün ve geçmiş kâr bilinmeli. | `CASCADE` satış satırlarını silerdi. |
| `fk_sensor_product` | product → shelf_sensor | `SET NULL` | Ürün kalksa da fiziksel sensör kalır. | `CASCADE` sensörü silerdi. |

## CASCADE kanıtı

`seed.sql` çalıştırıldıktan sonra:

```sql
SELECT count(*) AS orders_before FROM purchase_order;
SELECT count(*) AS items_before FROM purchase_order_item;
DELETE FROM purchase_order WHERE order_id = 1;
SELECT count(*) AS orders_after FROM purchase_order;
SELECT count(*) AS items_after FROM purchase_order_item;
SELECT count(*) AS order_1_items_after FROM purchase_order_item WHERE order_id = 1;
```

| Ölçüm | Önce | Sonra |
|---|---:|---:|
| `purchase_order` | 6 | 5 |
| `purchase_order_item` | 8 | 6 |
| `order_id = 1` kalemleri | 2 | 0 |

Test sonrası `seed.sql` yeniden çalıştırılarak veri eski haline getirilir.

## RESTRICT ve NO ACTION farkı

`RESTRICT` kontrolü hemen yapar ve ertelenemez; `NO ACTION` (varsayılan) kontrolü ifadenin sonunda yapar ve `DEFERRABLE` ise transaction sonuna ertelenebilir. Hata kodları da farklıdır: `RESTRICT` ihlali `23001` (restrict_violation), `NO ACTION` ihlali `23503` (foreign_key_violation) verir. Bu şemada `RESTRICT` kullanan FK'lerde silme testleri (T60–T63) `23001`, ebeveyn anahtarını değiştiren `UPDATE` testi (T64, varsayılan `NO ACTION`) `23503` döndürdü.
