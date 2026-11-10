# ER Diyagramı — Otonom Stok Takibi ve Kredi Risk Kontrollü Perakende Veritabanı Mimarisi

Proje; perakende dükkânı, ürün kategorileri, tedarikçiler, satın alma kalemleri, satışlar, müşteriler, kredi risk değerlendirmeleri ve raf sensörlerinden oluşur. İki M:N ilişki (`purchase_order`–`product`, `sale`–`product`) ara tablolarda çözülmüştür.

```mermaid
erDiagram
    CATEGORY ||--o{ PRODUCT : "kategori"
    SUPPLIER o|--o{ PRODUCT : "tercihli_tedarikci"
    SUPPLIER ||--o{ PURCHASE_ORDER : "tedarik"
    PURCHASE_ORDER ||--o{ PURCHASE_ORDER_ITEM : "kalem"
    PRODUCT ||--o{ PURCHASE_ORDER_ITEM : "siparis_urunu"
    CUSTOMER ||--o{ CREDIT_RISK_ASSESSMENT : "risk_kaydi"
    CUSTOMER o|--o{ SALE : "istege_bagli_musteri"
    SALE ||--o{ SALE_ITEM : "satis_satiri"
    PRODUCT ||--o{ SALE_ITEM : "satilan_urun"
    PRODUCT o|--o{ SHELF_SENSOR : "sensor_eslesmesi"

    CATEGORY {
        int category_id PK
        text category_name UK
        boolean is_age_restricted
    }
    SUPPLIER {
        int supplier_id PK
        text supplier_name UK
        text supplier_type
        text phone
        text status
        int lead_time_days
    }
    CUSTOMER {
        int customer_id PK
        text customer_name
        text phone UK
        decimal credit_limit
        decimal credit_used
        text status
    }
    PRODUCT {
        int product_id PK
        text barcode UK
        text product_name
        int category_id FK
        int preferred_supplier_id FK
        decimal cost_price
        decimal sale_price
        int stock_qty
        int min_stock_qty
        int max_stock_qty
        text status
    }
    PURCHASE_ORDER {
        int order_id PK
        int supplier_id FK
        date order_date
        date expected_date
        text status
    }
    PURCHASE_ORDER_ITEM {
        int order_item_id PK
        int order_id FK
        int product_id FK
        int ordered_qty
        int delivered_qty
        decimal unit_cost
    }
    CREDIT_RISK_ASSESSMENT {
        int assessment_id PK
        int customer_id FK
        int risk_score
        text decision
        datetime assessed_at
        date expires_at
        text notes
    }
    SALE {
        int sale_id PK
        int customer_id FK
        datetime sold_at
        text payment_type
    }
    SALE_ITEM {
        int sale_item_id PK
        int sale_id FK
        int product_id FK
        int quantity
        decimal unit_price
        decimal unit_cost
        decimal discount_rate
    }
    SHELF_SENSOR {
        int sensor_id PK
        text sensor_code UK
        int product_id FK
        text shelf_location
        text status
        int last_reading_qty
        datetime last_seen_at
    }
```

## İlişki ve davranış açıklaması

Her ürün tam bir kategoriye aittir; tercihli tedarikçi isteğe bağlıdır. Her sipariş bir tedarikçiye, her sipariş kalemi bir siparişe ve bir ürüne bağlıdır. Her kredi risk değerlendirmesi bir müşteriye aittir. Satışın müşterisi isteğe bağlıdır; **kredi satışında müşteri zorunludur** (`chk_sale_credit_customer`). Raf sensörünün ürünü NULL olabilir.

`purchase_order_item` ve `sale_item` ara tabloları iki çoktan-çoğa ilişkiyi çözer. `sale_item.unit_price` ve `unit_cost`, satış anındaki fiyat/maliyetin kopyasıdır; fiyat sonradan değişse de geçmiş satışın kârı değişmez.
