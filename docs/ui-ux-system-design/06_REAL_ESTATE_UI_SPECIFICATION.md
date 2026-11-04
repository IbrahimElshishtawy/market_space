# 06 — Real Estate Sector UI Specification

## 1. Vertical Overview & Business Scope

The **Real Estate** vertical (`/real-estate`) is Deal One's flagship property discovery environment. It serves buyers, tenants, brokers, and real estate developers across Egypt. In compliance with **ADR-001 and ADR-008**, the V1 real estate vertical operates exclusively in **`contact_only`** transaction mode. Users can discover residential and commercial properties, inspect high-resolution galleries, explore nearby properties via an interactive PostGIS map, watch vertical video reels, and initiate direct communication with verified brokers via in-app chat or phone.

---

## 2. Screen Specifications

### Screen: Real Estate Home & Property Feed (`SCR-RES-001`)

#### 1. Screen Identity
- **Screen ID:** `SCR-RES-001`
- **Module:** Module D: Real Estate
- **Screen Name (AR):** سوق العقارات وتغذية الوحدات
- **Screen Name (EN):** Real Estate Home & Property Feed
- **Current Status:** **IMPLEMENTED** ([lib/features/real_estate/presentation/pages/real_estate_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/real_estate/presentation/pages/real_estate_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** All (Guest & Authenticated Property Seeker)
- **Entry Routes:** Home Category Tap (`/real-estate`), Bottom Nav Switcher
- **Exit Routes:** `SCR-RES-002` (Detail), `SCR-RES-004` (Map Search), `SCR-RES-005` (Reels), `SCR-RES-008` (Filters)

#### 2. Screen Purpose
Allows users to explore residential and commercial property listings in Egypt with category filtering (شقق للبيع، شقق للإيجار، فيلات، تجاري), view featured compounds, and toggle between feed, map, and reel views.

#### 3. Layout Structure
```
+-------------------------------------------------------------+
| APP BAR: [Back Chevron] "سوق العقارات"  [Map Icon] [Reels Icon] |
+-------------------------------------------------------------+
| SEARCH BAR & FILTER DOCK                                    |
| [Search Property] [Filter Button with Active Count Badge]   |
+-------------------------------------------------------------+
| TRANSACTION TYPE SEGMENTED BAR                              |
| [ الكل ]  [ للبيع ]  [ للإيجار ]  [ كمبوندات ومشاريع ]      |
+-------------------------------------------------------------+
| PROPERTY SUB-CATEGORIES HORIZONTAL CHIPS                    |
| (• شقق سكني) (• دوبلكس) (• فيلات مستقلة) (• مكاتب تجارية)   |
+-------------------------------------------------------------+
| MAIN FEED (SliverList of RealEstateCard items)              |
| +---------------------------------------------------------+ |
| | [IMAGE (16:10)] [Badge: للبيع] [Heart Icon]             | |
| | ٤,٥٠٠,٠٠٠ ج.م                                           | |
| | شقة للبيع في كمبوند بالم هيلز - التجمع الخامس           | |
| | [٣ غرف] • [٢ حمام] • [١٨٥ م²] • [الدور الثالث]          | |
| | [Pin: التجمع الخامس، القاهرة الجديدة]  [Broker Verified] | |
| +---------------------------------------------------------+ |
+-------------------------------------------------------------+
| FLOATING ACTION BUTTON (Optional): [ + أضف عقارك ]          |
+-------------------------------------------------------------+
```

---

### Screen: Property Listing Detail Page (`SCR-RES-002`)

#### 1. Screen Identity
- **Screen ID:** `SCR-RES-002`
- **Module:** Module D: Real Estate
- **Screen Name (AR):** تفاصيل الوحدة العقارية
- **Screen Name (EN):** Property Listing Detail Page
- **Current Status:** **IMPLEMENTED** ([lib/features/real_estate/presentation/pages/real_estate_detail_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/real_estate/presentation/pages/real_estate_detail_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Property Seeker / Buyer
- **Entry Routes:** Deep link `/real-estate/detail?id=:id`, Card tap from `SCR-RES-001`, Map tap
- **Exit Routes:** `SCR-RES-003` (Fullscreen Gallery), `SCR-CHT-002` (Chat Room), `SCR-RES-012` (Broker Profile)

#### 2. Screen Purpose
Provides comprehensive architectural and legal specifications for a single property, transparent pricing and payment plan details, approximate area location map, and contact options.

#### 3. Layout Structure & UI Components
1. **PropertyGallery Header (`SCR-RES-003`):** Paged image slider (height 280dp) with indicator dots, 360-degree virtual tour badge (if present), and total photo count pill ("١ / ١٢").
2. **Main Property Header:**
   - Price tag (`٤,٥٠٠,٠٠٠ ج.م`) with rental/sale indicator.
   - Property Title: High-emphasis Cairo Bold text.
   - Compound or Neighborhood reference with publication timestamp.
3. **Property Specs Grid (`PropertySpecsGrid`):** 2x4 attribute grid displaying:
   - Area: `١٨٥ م²`
   - Bedrooms: `٣ غرف نوم`
   - Bathrooms: `٢ حمام`
   - Floor Level: `الدور الرابع`
   - Finishing Status: `تشطيب ألترا سوبر لوكس`
   - Furnished: `نعم / مفروشة بالكامل`
   - Building Age / Delivery Year: `استلام فوري / ٢٠٢٤`
4. **Description Card (`PropertyDescriptionCard`):** Full Arabic narrative with "اقرأ المزيد" expansion toggle.
5. **Two-Tier Geographic Map Preview (ADR-006):** Static map card showing the **approximate district centroid** (`display_location`), explicitly protecting homeowner privacy.
6. **Advertiser Profile Card (`AdvertiserProfileCard`):** Verified broker name, commercial logo, verification badge ("شركة موثقة"), active listing count, and member since date.
7. **Bottom Persistent Contact Bar:**
   - "محادثة فورية" (Start In-App Chat $\to$ `SCR-CHT-002`).
   - "واتساب" (Reveal & open WhatsApp $\to$ `SCR-CHT-003`).
   - "اتصال هاتف" (Direct phone dialer $\to$ `SCR-CHT-003`).

---

### Screen: Real Estate Interactive Map Search (`SCR-RES-004`)

#### 1. Screen Identity
- **Screen ID:** `SCR-RES-004`
- **Module:** Module D: Real Estate
- **Screen Name (AR):** البحث العقاري التفاعلي بالخريطة
- **Screen Name (EN):** Real Estate Interactive Map Search
- **Current Status:** **IMPLEMENTED** ([lib/features/real_estate/map/presentation/pages/real_estate_map_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/real_estate/map/presentation/pages/real_estate_map_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Property Seeker
- **Entry Routes:** Map button on `SCR-RES-001` (`/real-estate/map`)
- **Exit Routes:** `SCR-RES-002` (Property Detail)

#### 2. Layout & Interaction Behavior
- **Full-Screen Vector Map:** Map centered on active Egyptian governorate/city.
- **Cluster Markers:** Numeric circle badges indicating listing density per district.
- **Single Property Markers:** Price pill markers (e.g. `٤.٥ م`). Tapping a marker expands `PropertyMapPreviewCard` at the bottom of the screen.
- **PropertyMapPreviewCard:** Horizontal card featuring primary thumbnail, title, price, bedroom count, and "عرض التفاصيل" button.

---

### Screen: Property Short Video Reels (`SCR-RES-005`, `SCR-RES-006`, `SCR-RES-007`)

#### 1. Screen Identity
- **Screen ID:** `SCR-RES-005` (Reels Feed), `SCR-RES-006` (Reel Publish), `SCR-RES-007` (Reel Analytics)
- **Status Classification:**
  - `SCR-RES-005`: **APPROVED V1 (Browsing)**
  - `SCR-RES-006` & `SCR-RES-007`: **PROTOTYPE / FUTURE V2**
- **Purpose:** TikTok/Reels style vertical 9:16 video feed showcasing property walkthroughs.
- **UI Components:** Vertical `PageView.builder`, sound toggle, floating broker avatar, property summary overlay, and "استفسر عن العقار" button directly launching in-app chat.

---

## 3. Real Estate Card System Specifications

```
+--------------------------------------------------------------+
| RealEstateCard Specification                                 |
| Dimensions: Width 100%, Outer Padding: 16dp horizontal       |
| Corner Radius: AppRadii.lg (16.0 dp), Elevation: Level 1     |
| Border: 1.0dp AppColors.border                               |
+--------------------------------------------------------------+
| Image Container: Aspect Ratio 16:10, Radius: Top 16dp        |
| - Top Right: Status Badge ("للبيع" / "للإيجار")               |
| - Top Left: Favorite Icon (Heart button with haptic tap)     |
| - Bottom Right: Photos Counter Pill ("١ / ٨")                |
+--------------------------------------------------------------+
| Body Content: Padding 12.0 dp                                |
| - Price: AppTextStyles.priceCard (e.g. ٤,٥٠٠,٠٠٠ ج.م)         |
| - Title: Cairo SemiBold 16sp, Max 2 lines with ellipsis      |
| - Spec Chips Row: [٣ غرف] • [٢ حمام] • [١٨٥ م²]             |
| - Location Row: [Pin Icon] "التجمع الخامس، القاهرة الجديدة"  |
| - Footer Row: [Broker Avatar (24dp)] "شركة إعمار" [Verified] |
+--------------------------------------------------------------+
```

---

## 4. Real Estate Dynamic Attributes Schema (`category_fields`)

In accordance with **ADR-003**, the real estate listing form dynamically enforces these attributes:

| Field Key | Label (AR) | Field Type | Required? | Options / Validation Rules |
|---|---|:---:|:---:|---|
| `property_type` | نوع العقار | `select` | **Yes** | `apartment`, `villa`, `townhouse`, `duplex`, `commercial`, `land` |
| `transaction_type` | نوع العرض | `select` | **Yes** | `sale` (للبيع), `rent` (للإيجار) |
| `area_sqm` | المساحة بالمتر المربع | `number` | **Yes** | Min: `20`, Max: `100000` |
| `rooms` | عدد الغرف | `select` | **Yes** | `studio`, `1`, `2`, `3`, `4`, `5+` |
| `bathrooms` | عدد دورات المياه | `select` | **Yes** | `1`, `2`, `3`, `4+` |
| `floor_level` | الدور / الطابق | `select` | No | `ground`, `1`, `2`, `3`, `4`, `5+`, `roof` |
| `finishing_type` | مستوى التشطيب | `select` | **Yes** | `without`, `semi_finished`, `finished`, `ultra_lux` |
| `furnished` | مفروش | `boolean` | No | `true`, `false` |
| `compound_name` | اسم الكمبوند / المشروع | `text` | No | String (Linked to `projects` table if exists) |
| `delivery_status` | حالة الاستلام | `select` | **Yes** | `immediate` (فوري), `within_year`, `under_construction` |

