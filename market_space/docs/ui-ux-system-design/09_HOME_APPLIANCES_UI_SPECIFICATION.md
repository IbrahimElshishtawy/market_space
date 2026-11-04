# 09 — Home Appliances & Decoration UI Specification

## 1. Vertical Overview & Commercial Scope

The **Home Appliances & Decoration** vertical (`/home-appliances`) caters to Egyptian consumers seeking large household appliances (refrigerators, automatic washing machines, cookers), small domestic appliances, entertainment electronics (smart TVs, sound systems), and interior home furnishings and decor.

Sellers range from authorized electronics distributors (B.TECH, Raya, Elaraby Group) to local retail showrooms and individual sellers offering pre-owned appliances.

---

## 2. Strict Scope Boundary & Prototype UI Classification

> [!IMPORTANT]
> **Prototype UI Disclaimer**: The Flutter codebase currently includes screens for Shopping Cart (`HomeAppliancesCartPage`), Checkout (`HomeAppliancesCheckoutPage`), and Order Tracking (`HomeAppliancesOrdersPage`).
> 
> Under approved decisions **ADR-008 (Transaction Modes)** and **ADR-009 (Commerce Module Boundary)**, a digital cart and direct online payment gateway are **strictly Tier 3 (Deferred to V3)**.
> 
> In the approved V1 release:
> - The application functions as an authoritative discovery and classifieds catalog.
> - Buyers inspect technical specifications, compare showroom prices, verify dealer warranties, and initiate direct communication with the seller via **In-App Chat (`SCR-CHT-002`)**, **Direct Phone Call**, or **WhatsApp**.
> - The prototype cart and checkout flows are cataloged as future commerce artifacts and hidden from V1 navigation.

---

## 3. Screen Specifications

### Screen: Home Appliances Home Feed (`SCR-APP-001`)

#### 1. Screen Identity
- **Screen ID:** `SCR-APP-001`
- **Module:** Module G: Home Appliances & Decor
- **Screen Name (AR):** معرض الأجهزة المنزلية والديكور
- **Screen Name (EN):** Home Appliances Home Feed
- **Current Status:** **IMPLEMENTED** ([lib/features/home_appliances/presentation/pages/home_appliances_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/home_appliances/presentation/pages/home_appliances_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Consumer / Buyer
- **Entry Routes:** Home Category Tap, Bottom Nav Switcher (`/home-appliances`)
- **Exit Routes:** `SCR-APP-002` (Categories), `SCR-APP-003` (Category Feed), `SCR-APP-004` (Product Detail)

#### 2. Layout Structure
```
+-------------------------------------------------------------+
| APP BAR: "الأجهزة والديكور"  [Search Appliances] [Favorites]  |
+-------------------------------------------------------------+
| SEASONAL APPLIANCE PROMO CAROUSEL                           |
| "عروض جهاز العروسة: تخفيضات على البكجات الكاملة والضمان"    |
+-------------------------------------------------------------+
| POPULAR APPLIANCE CATEGORIES CHIPS                          |
| [شاشات وتلفزيونات]  [غسالات]  [ثلاجات]  [تكييفات]  [أثاث]   |
+-------------------------------------------------------------+
| TOP AUTHORIZED BRANDS CAROUSEL                              |
| [توشيبا / العربي]  [سامسونج]  [إل جي]  [زانوسي]  [فريش]     |
+-------------------------------------------------------------+
| LATEST APPLIANCE & FURNITURE LISTINGS FEED                  |
| (2-column masonry grid of ApplianceProductCard items)       |
+-------------------------------------------------------------+
```

---

### Screen: Appliance Listing Detail Page (`SCR-APP-004`)

#### 1. Screen Identity
- **Screen ID:** `SCR-APP-004`
- **Module:** Module G: Home Appliances & Decor
- **Screen Name (AR):** بطاقة تفاصيل الجهاز أو الأثاث
- **Screen Name (EN):** Appliance Listing Detail Page
- **Current Status:** **PARTIAL** (Served via shared classifieds layout)
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Buyer
- **Entry Routes:** Product card tap from `SCR-APP-001` or `SCR-APP-003`
- **Exit Routes:** `SCR-APP-005` (Store Profile), `SCR-CHT-002` (Chat Room)

#### 2. UI Components & Content
1. **Interactive Image Gallery:** Multi-angle product photos, energy efficiency label tag, and packaging condition.
2. **Core Price & Condition Header:**
   - Price: `١٨,٩٠٠ ج.م`
   - Condition Badge: `جديد بالكرتونة` (New in Box) / `فرز ثاني معتمد` (Refurbished) / `مستعمل بحالة ممتازة` (Used).
   - Warranty Badge: `ضمان ٥ سنوات من الوكيل (العربي جروب)`.
3. **Key Technical Specifications Table:**
   - Brand / Manufacturer: `توشيبا (Toshiba)`
   - Model / Serial: `GR-EF40P-H`
   - Capacity / Dimensions: `٣٩٥ لتر - ١٦ قدم`
   - Energy Rating: `Class A+ (أعلى كفاءة وأقل استهلاك)`
   - Color / Finish: `ستانلس ستيل فضي مقاوم للبصمات`
4. **Seller / Showroom Profile Card (`SCR-APP-005`):** Showroom name, branch city/neighborhood, official authorized dealer badge.
5. **Persistent Bottom Action Bar (V1 Approved):**
   - "محادثة التاجر" (Direct In-App Chat $\to$ `SCR-CHT-002`).
   - "واتساب المعرض" (Opens WhatsApp with appliance SKU).
   - "اتصال هاتفي بالفرع" (Launches phone dialer).

---

## 4. Appliance Listing Card System Specification

```
+--------------------------------------------------------------+
| ApplianceProductCard Specification (2-Column Grid Item)      |
| Width: ~170dp (Adaptive), Corner Radius: AppRadii.lg (16.0dp)|
| Border: 1.0dp AppColors.border, Elevation: Level 1           |
+--------------------------------------------------------------+
| Image Container: Square 1:1 Aspect Ratio                     |
| - Top Right: Condition Chip ("جديد" / "مستعمل")              |
| - Top Left: Heart Favorite Icon Button                       |
+--------------------------------------------------------------+
| Content Block: Padding 8.0 dp                                |
| - Brand Name: Cairo Regular 12sp (e.g. "سامسونج")            |
| - Product Title: Cairo Bold 14sp, Max 2 lines with ellipsis  |
|   (شاشة ٥٥ بوصة 4K UHD سمارت)                                |
| - Price: Cairo Bold 16sp (١٦,٥٠٠ ج.م)                        |
| - Warranty Badge: [Shield Icon] "ضمان سنتين"                 |
| - Location / Store: [Pin Icon] "مدينة نصر - القاهرة"          |
+--------------------------------------------------------------+
```

---

## 5. Home Appliances Dynamic Attributes Schema (`category_fields`)

| Field Key | Label (AR) | Field Type | Required? | Validation Rules & Options |
|---|---|:---:|:---:|---|
| `appliance_type` | نوع الجهاز / القطعة | `select` | **Yes** | `refrigerator`, `washer`, `cooker`, `tv_screens`, `air_conditioner`, `furniture`, `small_appliances` |
| `brand` | الماركة / الشركة المصنعة | `text` | **Yes** | e.g. Samsung, LG, Toshiba, Sharp, Zanussi, Beko, Fresh |
| `condition` | حالة الجهاز | `select` | **Yes** | `brand_new` (جديد أصلي), `open_box` (مفتوح للتجربة), `refurbished` (فرز ثاني معتمد), `used` (مستعمل) |
| `warranty_status` | حالة الضمان | `select` | **Yes** | `official_agent` (ضمان وكيل معتمد), `store_warranty` (ضمان معرض), `no_warranty` (بدون ضمان) |
| `warranty_duration_years`| مدة الضمان بالسنوات | `number` | No | `1`, `2`, `3`, `5`, `10` |
| `energy_efficiency_class`| بطاقة كفاءة الطاقة | `select` | No | `A+++`, `A++`, `A+`, `A`, `B`, `C` |
| `capacity` | السعة أو الحجم | `text` | No | e.g. 14 قدم، 8 كيلو، 55 بوصة |
