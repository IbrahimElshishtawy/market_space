# 11 — Clothes & Fashion Accessories UI Specification

## 1. Vertical Overview & Commercial Scope

The **Clothes & Fashion Accessories** vertical (`/fashion`) serves Egypt's vibrant textile, ready-made garments, and lifestyle apparel retail market. The section spans three core consumer departments:
1. **Men's Fashion (رجالي):** Formal suits, casual shirts, denim, sportswear, leather footwear.
2. **Women's Fashion (حريمي):** Dresses, abayas, formal wear, casual apparel, handbags, jewelry.
3. **Kids & Infants (أطفال ورضع):** Boys, girls, and newborn clothing sets.

---

## 2. Strict Scope Boundary & Prototype UI Classification

> [!IMPORTANT]
> **Prototype UI Disclaimer**: The Flutter codebase includes a prototype shopping bag screen (`FashionCartPage`). 
> 
> In compliance with **ADR-008 (Transaction Modes)** and **ADR-009 (Commerce Module Boundary)**, multi-item garment carts and online checkout are **strictly Tier 3 (Deferred to V3)**.
> 
> In the approved V1 release:
> - Shoppers browse curated apparel listings and review available sizes and colors.
> - Transaction completion, sizing inquiries, and delivery arrangements are handled directly via **In-App Chat (`SCR-CHT-002`)**, **Direct Phone Call**, or **WhatsApp**.
> - The prototype cart screen is cataloged as a future commerce artifact and hidden from primary navigation.

---

## 3. Screen Specifications

### Screen: Fashion Home & Department Feed (`SCR-FAS-001`)

#### 1. Screen Identity
- **Screen ID:** `SCR-FAS-001`
- **Module:** Module I: Fashion
- **Screen Name (AR):** سوق الأزياء والملابس
- **Screen Name (EN):** Fashion Home & Department Feed
- **Current Status:** **IMPLEMENTED** ([lib/features/fashion/presentation/pages/fashion_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/fashion/presentation/pages/fashion_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Shopper / Buyer
- **Entry Routes:** Home Category Tap, Bottom Nav Switcher (`/fashion`)
- **Exit Routes:** `SCR-FAS-002` (Categories), `SCR-FAS-003` (Product Detail), Boutique Profile

#### 2. Layout Structure
```
+-------------------------------------------------------------+
| APP BAR: "الأزياء والموضة"  [Search Fashion] [Favorites]    |
+-------------------------------------------------------------+
| DEPARTMENT SEGMENTED PILLS BAR                              |
| [ الكل ]    [ رجالي ]    [ حريمي ]    [ أطفال ]             |
+-------------------------------------------------------------+
| SEASONAL FASHION PROMOTIONAL HERO BANNER                    |
| "تشكيلة الشتاء الجديدة: كولكشن الصوف والجلد الطبيعي"        |
+-------------------------------------------------------------+
| FASHION SUB-CATEGORIES HORIZONTAL CHIPS                     |
| [قمصان وبدلات]  [فساتين وعبايات]  [أحذية كلاسيك]  [حقائب]    |
+-------------------------------------------------------------+
| CURATED APPAREL FEED (2-Column Masonry of FashionProductCard)|
+-------------------------------------------------------------+
```

---

### Screen: Fashion Product Detail Page (`SCR-FAS-003`)

#### 1. Screen Identity
- **Screen ID:** `SCR-FAS-003`
- **Module:** Module I: Fashion
- **Screen Name (AR):** بطاقة تفاصيل القطعة والمقاسات
- **Screen Name (EN):** Fashion Product Detail Page
- **Current Status:** **IMPLEMENTED** ([lib/features/fashion/presentation/pages/fashion_product_detail_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/fashion/presentation/pages/fashion_product_detail_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Shopper
- **Entry Routes:** Product card tap (`/fashion/detail?id=:id`)
- **Exit Routes:** `SCR-FAS-004` (Boutique Profile), `SCR-CHT-002` (Chat Room)

#### 2. UI Components & Content
1. **Vertical Model Photography Slider:** 3:4 aspect ratio portrait images showing garment on model, fabric weave close-up, and sizing chart.
2. **Title & Price Block:**
   - Price: `١,٤٥٠ ج.م`
   - Garment Title: `بليزر رجالي صوف إيطالي - قصة سليم فت`
   - Brand / Boutique Name: `Zara / كلاسيك مان بوتيك`
3. **Color Swatch Selector:** Interactive circular swatches (e.g. كحلي داكن، رمادي فحمي، جملي).
4. **Available Size Chips Selector:** Sizing chips (`S`, `M`, `L`, `XL`, `XXL`) with out-of-stock strike-through visual indicator.
5. **Fabric & Care Specification Table:**
   - Fabric Composition: `٧٠% صوف طبيعي، ٣٠% فيسكوز`
   - Country of Origin: `صنع في مصر (أقطان مصرية فاخرة)`
   - Care Instructions: `غسيل جاف فقط (Dry Clean Only)`
6. **Boutique Profile Card (`SCR-FAS-004`):** Store name, showroom location (e.g. جنينة مول، مدينة نصر), opening hours.
7. **Persistent Contact Bar (V1 Approved):**
   - "محادثة البوتيك للسؤال عن المقاس" (Direct Chat $\to$ `SCR-CHT-002`).
   - "طلب فوري واتساب" (WhatsApp with size and color pre-selected).
   - "اتصال هاتفي بالمتجر" (Direct dialer).

---

## 3. Fashion Card System Specification

```
+--------------------------------------------------------------+
| FashionProductCard Specification (2-Column Masonry Item)     |
| Corner Radius: AppRadii.lg (16.0 dp), Elevation: Level 1     |
| Border: 1.0dp AppColors.border                               |
+--------------------------------------------------------------+
| Image Box: Portrait 3:4 Aspect Ratio                         |
| - Top Right: Brand Tag ("Zara" / "Defacto")                  |
| - Top Left: Heart Favorite Icon Button                       |
+--------------------------------------------------------------+
| Content Block: Padding 8.0 dp                                |
| - Price: Cairo Bold 16sp (١,٤٥٠ ج.م)                         |
| - Garment Title: Cairo Medium 13sp, Max 2 lines              |
| - Available Sizes Pill: [ S • M • L • XL ]                   |
| - Color Dots: (● ● ●) (Preview of available shades)          |
| - Boutique / City: [Pin Icon] "مصر الجديدة - القاهرة"        |
+--------------------------------------------------------------+
```

---

## 4. Fashion Dynamic Attributes Schema (`category_fields`)

| Field Key | Label (AR) | Field Type | Required? | Validation Rules & Options |
|---|---|:---:|:---:|---|
| `department` | القسم الرئيسي | `select` | **Yes** | `men`, `women`, `kids_boys`, `kids_girls`, `baby` |
| `apparel_category` | تصنيف القطعة | `select` | **Yes** | `suits`, `shirts`, `dresses`, `abayas`, `shoes`, `bags`, `sportswear` |
| `size_options` | المقاسات المتاحة | `multi_select`| **Yes** | `XS`, `S`, `M`, `L`, `XL`, `XXL`, `3XL`, `38`, `40`, `42`, `44` |
| `colors_available` | الألوان المتوفرة | `multi_select`| **Yes** | `black`, `white`, `navy`, `beige`, `grey`, `brown`, `red`, `green` |
| `fabric_material` | نوع القماش والخامة | `text` | No | e.g. قطن مصري ١٠٠%، صوف، كتان، جلد طبيعي |
| `origin_country` | بلد المنشأ | `text` | No | e.g. مصر، تركيا، إيطاليا |
| `condition` | حالة القطعة | `select` | **Yes** | `brand_new_tags` (جديد بالتيكت), `vintage` (فينتاج بحالة ممتازة) |

