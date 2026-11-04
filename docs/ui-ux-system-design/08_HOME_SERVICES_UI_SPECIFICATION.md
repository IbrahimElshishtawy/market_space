# 08 — Home & Engineering Services UI Specification

## 1. Vertical Overview & Commercial Scope

The **Home & Engineering Services** vertical (`/home-services`) connects Egyptian homeowners, tenants, facility managers, and business operators with certified technicians, engineering offices, and maintenance contractors.

The vertical encompasses critical domestic and commercial trades:
- **HVAC & Air Conditioning:** Cleaning, refrigerant charging, compressor repairs, split/central AC installation.
- **Plumbing & Sanitary:** Water line installations, leak detection, fixture repairs, water heater maintenance.
- **Electrical & Smart Home:** Distribution board repairs, lighting installation, UPS/inverter setup.
- **Carpentry & Joinery:** Furniture assembly, door/window repairs, custom cabinetry.
- **Finishing & Painting:** Interior plastering, wall coatings, wallpaper installation.

---

## 2. Strict Scope Boundary & Prototype UI Classification

> [!IMPORTANT]
> **Prototype UI Disclaimer**: The Flutter codebase currently includes interactive screens for a multi-step Booking Wizard (`HomeServicesBookingWizardPage`), Booking Management (`HomeServicesBookingDetailPage`, `HomeServicesBookingsView`), and Live GPS Technician Tracking (`TechnicianTrackingPage`).
> 
> Under approved decisions **ADR-008 (Transaction Modes)** and **ADR-010 (Booking Module Boundary)**, a full automated booking and real-time dispatch engine is **strictly Tier 3 (Deferred to V3)**.
> 
> In the approved V1 release:
> - Users discover verified technicians and engineering providers through their profile and service listings.
> - Scheduling and service agreements occur directly through **In-App Chat (`SCR-CHT-002`)**, **Direct Phone Call**, or **WhatsApp**.
> - The prototype booking wizard and tracking screens are preserved in the codebase as architectural scaffolding for V3, but are hidden from the primary V1 user journey.

---

## 3. Screen Specifications

### Screen: Home Services Home & Directory (`SCR-SRV-001`)

#### 1. Screen Identity
- **Screen ID:** `SCR-SRV-001`
- **Module:** Module F: Home Services
- **Screen Name (AR):** دليل الخدمات الهندسية والمنزلية
- **Screen Name (EN):** Home Services Home & Directory
- **Current Status:** **IMPLEMENTED** ([lib/features/home_services/presentation/pages/home_services_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/home_services/presentation/pages/home_services_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Homeowner, Facility Seeker
- **Entry Routes:** Home Category Tap, Bottom Nav Switcher (`/home-services`)
- **Exit Routes:** `SCR-SRV-002` (Catalog), `SCR-SRV-003` (Service Detail), `SCR-SRV-005` (Provider Detail)

#### 2. Layout Structure
```
+-------------------------------------------------------------+
| APP BAR: "الخدمات والصيانة"  [Search Services] [Emergency 24/7] |
+-------------------------------------------------------------+
| EMERGENCY / QUICK RESPONSE BANNER                           |
| "طوارئ سباكة أو كهرباء؟ فنيون متاحون خلال ٦٠ دقيقة"         |
+-------------------------------------------------------------+
| SERVICE TRADES HORIZONTAL GRID                              |
| [تكييفات]  [سباكة]  [كهرباء]  [نجارة]  [نقاشة]  [أجهزة]     |
+-------------------------------------------------------------+
| VERIFIED SERVICE PROVIDERS & CONTRACTORS FEED               |
| (Vertical list of ServiceProviderCard components)           |
| +---------------------------------------------------------+ |
| | [Provider Avatar (64dp)] [Verified Office Badge]        | |
| | المهندس للتكييف والتبريد - م. أحمد عبد الرحمن           | |
| | ★ ٤.٩ (١٤٢ تقييم) • معتمد من كاريير وشارب               | |
| | تغطية: [طنطا] • [المحلة الكبرى] • [كفر الشيخ]           | |
| | [زر محادثة فورية]        [زر اتصال فوري 📞]            | |
| +---------------------------------------------------------+ |
+-------------------------------------------------------------+
```

---

### Screen: Service Listing Detail Page (`SCR-SRV-003` & `SCR-SRV-004`)

#### 1. Screen Identity
- **Screen ID:** `SCR-SRV-003` (Generic Service Detail) & `SCR-SRV-004` (AC Service Detail)
- **Module:** Module F: Home Services
- **Screen Name (AR):** تفاصيل الخدمة وبطاقة الاعتماد
- **Screen Name (EN):** Service Listing Detail Page
- **Current Status:** **IMPLEMENTED** ([lib/features/home_services/presentation/pages/home_service_detail_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/home_services/presentation/pages/home_service_detail_page.dart))
- **V1 Status:** **APPROVED V1**
- **Primary User Role:** Customer
- **Entry Routes:** Service card tap (`/home-services/service-detail?id=:id`)
- **Exit Routes:** `SCR-SRV-005` (Provider Profile), `SCR-CHT-002` (Chat Room)

#### 2. UI Components & Content
1. **Hero Service Banner:** Visual representation of technical service execution (e.g. pressure washing split AC coils).
2. **Pricing Transparency Card:**
   - Standard Inspection Fee (رسوم الكشف والمعاينة): `١٥٠ ج.م` (خصم من تكلفة الصيانة عند الإصلاح).
   - Estimated Service Cost: `٣٥٠ - ٦٠٠ ج.م`.
3. **Scope of Work (تفاصيل الخدمة):**
   - Bulleted checklist of included tasks (e.g., غسيل الفلاتر، تسليك خرطوم الصرف، فحص ضغط غاز الفريون).
   - Exclusions (e.g., قطع الغيار المستبدلة تُحسب بفاتورة منفصلة).
4. **Warranty & Guarantee Badge (`TrustGuaranteeCard`):** `ضمان معتمد لمدة ٣٠ يوماً على أعمال الصيانة وقطع الغيار`.
5. **Provider Identity & Coverage Area (`SCR-SRV-005`):** Displays technician certifications and confirmed coverage districts.
6. **Bottom Contact Bar (V1 Approved):**
   - "تواصل واتساب" (WhatsApp with service pre-selected).
   - "اتصال مباشر بالفني" (Direct cellular call).
   - "محادثة فورية بالتطبيق" (In-App Chat $\to$ `SCR-CHT-002`).

---

## 4. Service Provider Card System Specification

```
+--------------------------------------------------------------+
| ServiceProviderCard Specification                            |
| Corner Radius: AppRadii.lg (16.0 dp), Elevation: Level 1     |
| Border: 1.0dp AppColors.border                               |
+--------------------------------------------------------------+
| Header Row:                                                  |
| - Right: Provider Avatar / Logo (52x52 dp, Radius full)      |
| - Center: Provider Name + Trade Title ("فني تكييفات معتمد")  |
| - Left: Verification Badge (Shield Icon + "موثق رسمي")       |
+--------------------------------------------------------------+
| Metrics & Trust Row:                                         |
| - Rating: ★ 4.9 (84 reviews)                                 |
| - Experience: خبرة ٨ سنوات                                   |
| - Warranty: ضمان شهر على الصيانة                             |
+--------------------------------------------------------------+
| Geographic Service Coverage:                                 |
| [Pin Icon] يخدم: طنطا، كفر الزيات، قطور (نصف قطر ٢٥ كم)      |
+--------------------------------------------------------------+
| Action Buttons Row:                                          |
| [محادثة شات (Outlined)]        [اتصال مباشر بالفني (Primary)]|
+--------------------------------------------------------------+
```

---

## 5. Home Services Dynamic Attributes Schema (`category_fields`)

| Field Key | Label (AR) | Field Type | Required? | Validation Rules & Options |
|---|---|:---:|:---:|---|
| `service_category` | تخصص الخدمة | `select` | **Yes** | `ac`, `plumbing`, `electrical`, `carpentry`, `painting`, `appliances_repair` |
| `pricing_model` | نموذج التسعير | `select` | **Yes** | `fixed_price` (سعر ثابت), `inspection_fee` (كشف ومعاينة), `quote_based` (تسعير حسب المعاينة) |
| `inspection_fee_amount`| قيمة رسوم الكشف | `number` | No | In EGP (e.g. 150) |
| `warranty_duration_days`| مدة الضمان (أيام)| `number` | **Yes** | `0`, `30`, `60`, `90`, `180` |
| `emergency_support` | توفر خدمة الطوارئ ٢٤ ساعة | `boolean` | **Yes** | `true`, `false` |
| `service_radius_km` | نطاق التغطية بالكيلومتر | `number` | **Yes** | Min: `5`, Max: `100` |
| `license_number` | رقم القيد المهني / الترخيص | `text` | No | String |

