# 10 — Cars & Automotive Sector UI Specification

## 1. Vertical Overview & Commercial Scope

The **Cars & Automotive** vertical (`/cars`) connects Egyptian vehicle buyers, private owners, automotive showrooms, and licensed dealerships. The marketplace handles used and new passenger cars, commercial transport vehicles, motorcycles, and automotive spare parts.

In accordance with **ADR-001, ADR-006, and ADR-008**, all vehicle transactions occur in **`contact_only`** mode. Exact physical inspection coordinates are guarded to protect individual car owners, while public listings show the city or district inspection centroid (`SCR-CAR-005`).

---

## 2. Screen Specifications

### Screen: Cars Home & Search Feed (`SCR-CAR-001`)

#### 1. Screen Identity
- **Screen ID:** `SCR-CAR-001`
- **Module:** Module H: Cars & Automotive
- **Screen Name (AR):** حراج وسوق السيارات والمركبات
- **Screen Name (EN):** Cars Home & Search Feed
- **Current Status:** **IMPLEMENTED** ([lib/features/cars/presentation/pages/cars_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/cars/presentation/pages/cars_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Car Seeker / Buyer
- **Entry Routes:** Home Category Tap, Bottom Nav Switcher (`/cars`)
- **Exit Routes:** `SCR-CAR-002` (Car Detail), `SCR-CAR-003` (Car Filter Modal), Dealership Profile

#### 2. Layout Structure
```
+-------------------------------------------------------------+
| APP BAR: "سوق السيارات"  [Search Make/Model] [Filter Icon]  |
+-------------------------------------------------------------+
| POPULAR MAKES HORIZONTAL LOGO BAR                           |
| (Hyundai) (Toyota) (Mercedes) (Kia) (MG) (Nissan) (BMW)     |
+-------------------------------------------------------------+
| QUICK FILTER CHIPS ROW                                      |
| [سعر أقل من ٥٠٠ ألف] [كسر زيرو] [أوتوماتيك] [فابريكا بالكامل]|
+-------------------------------------------------------------+
| ACTIVE APPLIED FILTER BAR (If any filters selected)         |
| "تويوتا • ٢٠٢٠-٢٠٢٤ • أوتوماتيك"  [مسح الكل (X)]            |
+-------------------------------------------------------------+
| VEHICLE LISTING FEED (SliverList of CarCard items)          |
| +---------------------------------------------------------+ |
| | [CAR PHOTO (16:9)] [Badge: كسر زيرو] [Heart Icon]       | |
| | ٩٥٠,٠٠٠ ج.م                                             | |
| | تويوتا كورولا ٢٠٢٢ - الفئة الثانية Smart                | |
| | [ عداد: ٣٥,٠٠٠ كم ] • [ أوتوماتيك ] • [ ١٦٠٠ سي سي ]     | |
| | [ دهان: فابريكا بالكامل ] • [ رخصة سنة ]                | |
| | [Pin: التجمع الخامس - القاهرة]  [معرض معتمد: أوتو ستار] | |
| +---------------------------------------------------------+ |
+-------------------------------------------------------------+
```

---

### Screen: Vehicle Listing Detail Page (`SCR-CAR-002`)

#### 1. Screen Identity
- **Screen ID:** `SCR-CAR-002`
- **Module:** Module H: Cars & Automotive
- **Screen Name (AR):** تفاصيل السيارة والمواصفات الفنية
- **Screen Name (EN):** Vehicle Listing Detail Page
- **Current Status:** **IMPLEMENTED** ([lib/features/cars/presentation/pages/car_detail_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/cars/presentation/pages/car_detail_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Buyer
- **Entry Routes:** Car card tap (`/cars/detail?id=:id`)
- **Exit Routes:** `SCR-CAR-004` (Dealership Profile), `SCR-CAR-005` (Inspection Location), `SCR-CHT-002` (Chat Room)

#### 2. UI Components & Content
1. **Vehicle Photo Carousel:** Multi-angle photography covering exterior profile, dashboard & odometer, front/rear seats, engine bay, and tire tread.
2. **Key Financial & Vehicle Identity Block:**
   - Price: `٩٥٠,٠٠٠ ج.م` (قابل للتفاوض / نهائي).
   - Vehicle Title: `تويوتا كورولا موديل ٢٠٢٢ - الفئة الثانية`.
   - Publication Date & View Count.
3. **Core Specification Chips Matrix (2x4 Grid):**
   - Odometer / Mileage: `٣٥,٠٠٠ كم`
   - Manufacturing Year: `٢٠٢٢`
   - Transmission: `أوتوماتيك (CVT)`
   - Engine Capacity: `١٦٠٠ سي سي`
   - Fuel Type: `بنزين ٩٢ / ٩٥`
   - Body Type: `سيدان (Sedan)`
   - Color: `فضي ميتاليك`
   - License Status: `رخصة سارية لمدة سنة - مرور النزهة`
4. **Body & Paint Condition Card (حالة الهيكل والدهان):**
   - Factory Original (فابريكا بالكامل دواخل وخوارج).
   - Inspection report availability badge ("تقرير فحص معتمد متاح").
5. **Vehicle Seller Card (`SCR-CAR-004`):** Showroom name, verification badge, total active cars on lot.
6. **Persistent Bottom Contact Bar (V1 Approved):**
   - "محادثة البائع" (In-App Chat $\to$ `SCR-CHT-002`).
   - "اتصال هاتف مباشر" (Direct Phone dialer $\to$ `SCR-CHT-003`).
   - "تواصل واتساب" (WhatsApp with car specs auto-populated).

---

### Screen: Automotive Multi-Parameter Filter Sheet (`SCR-CAR-003`)

#### 1. Screen Identity
- **Screen ID:** `SCR-CAR-003`
- **Module:** Module H: Cars & Automotive
- **Screen Name (AR):** لوحة فلاتر السيارات المتقدمة
- **Screen Name (EN):** Automotive Multi-Parameter Filter Bottom Sheet
- **Current Status:** **IMPLEMENTED** (`CarFilterModal`)
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Car Seeker
- **Entry Routes:** Filter Icon on `SCR-CAR-001`
- **Exit Routes:** Dismiss / Apply Filters $\to$ Reloads `SCR-CAR-001`

#### 2. Filter Controls & Sections
- **Make & Model Selector:** Cascading dropdown (e.g. Toyota $\to$ Corolla).
- **Price Range Inputs:** Dual numeric inputs (Min Price / Max Price in EGP).
- **Model Year Range:** Slider or dual dropdown (e.g. 2018 to 2024).
- **Mileage Limit:** Chips (أقل من ٣٠ ألف كم، أقل من ٦٠ ألف كم، أقل من ١٠٠ ألف كم).
- **Transmission Filter:** Radio segment (الكل، أوتوماتيك، مانيوال).
- **Condition:** Checkboxes (فابريكا بالكامل، كسر زيرو، رش نظافة خارجي).
- **Governorate & City:** Multi-select area picker.

---

## 3. Cars Listing Card System Specification

```
+--------------------------------------------------------------+
| CarCard Specification                                        |
| Corner Radius: AppRadii.lg (16.0 dp), Elevation: Level 1     |
| Border: 1.0dp AppColors.border                               |
+--------------------------------------------------------------+
| Image Box: Landscape 16:9 Aspect Ratio                       |
| - Top Right: Condition Badge ("كسر زيرو" / "فابريكا")        |
| - Top Left: Heart Favorite Button (with haptic feedback)     |
| - Bottom Right: Year Badge ("موديل ٢٠٢٢")                    |
+--------------------------------------------------------------+
| Content Block: Padding 12.0 dp                               |
| - Price: AppTextStyles.priceCard (٩٥٠,٠٠٠ ج.م)               |
| - Car Title: Cairo SemiBold 16sp (تويوتا كورولا ٢٠٢٢ Smart)  |
| - Specs Row: [٣٥,٠٠٠ كم] • [أوتوماتيك] • [١٦٠٠ سي سي]        |
| - Location Row: [Pin Icon] "التجمع الخامس - القاهرة"         |
| - Seller Footer: [Avatar 22dp] "أوتو ستار للتجارة" [موثق]   |
+--------------------------------------------------------------+
```

---

## 4. Cars Dynamic Attributes Schema (`category_fields`)

| Field Key | Label (AR) | Field Type | Required? | Validation Rules & Options |
|---|---|:---:|:---:|---|
| `vehicle_type` | نوع المركبة | `select` | **Yes** | `passenger_car`, `suv_4x4`, `commercial_truck`, `motorcycle`, `spare_parts` |
| `make` | الماركة | `select` | **Yes** | Toyota, Hyundai, Mercedes-Benz, Kia, Nissan, BMW, Chevrolet, MG, Chery, etc. |
| `model` | الموديل | `text` | **Yes** | Corolla, Elantra, C180, Sportage, Sunny, etc. |
| `manufacturing_year`| سنة الصنع | `number` | **Yes** | Min: `1970`, Max: `2027` |
| `mileage_km` | قراءة العداد (كم) | `number` | **Yes** | Min: `0`, Max: `999999` |
| `transmission` | ناقل الحركة | `select` | **Yes** | `automatic`, `manual` |
| `engine_capacity_cc`| سعة المحرك (سي سي) | `number` | **Yes** | e.g. 1000, 1200, 1500, 1600, 2000, 2500+ |
| `fuel_type` | نوع الوقود | `select` | **Yes** | `petrol`, `natural_gas`, `diesel`, `hybrid`, `electric` |
| `body_condition` | حالة الدهان والهيكل | `select` | **Yes** | `factory_original` (فابريكا بالكامل), `exterior_repaint` (رش خارجي نظافة), `restored` (مجدد) |
| `license_validity` | سريان الرخصة | `select` | No | `less_than_year`, `one_year`, `two_years`, `three_years`, `expired` |
