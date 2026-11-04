# 02 — Master Screen Inventory & Application Catalog

## 1. Executive Summary & Inventory Statistics

This document establishes the **authoritative master screen inventory** for the Deal One mobile application. It captures every screen discovered within the existing Flutter codebase (`market_space/lib`), cross-referenced with all approved requirements in the Product Documentation (`Deal_One_SRS.md`, `Deal_One_Business_Analysis.md`, `Deal_One_Architecture_Decisions.md`) and the Backend Blueprint API specification.

### 1.1 Master Catalog Metrics

| Inventory Metric | Metric Count | Architectural Interpretation |
|---|:---:|---|
| **Total Cataloged Screens & Surfaces** | **68** | Complete scope across all 14 functional modules |
| **Existing Discovered Flutter Screens** | **38** | Screens physically implemented in `market_space/lib` |
| **Approved V1 Required Screens** | **44** | Mandatory screens for production V1 launch |
| **Existing Prototype-Only Screens** | **14** | Mock screens present in Flutter that belong to future milestones (e.g. Cart, Checkout, Orders, Booking Wizard) |
| **Planned Future Screens (V2 / V3)** | **18** | Future roadmap screens (Saved Searches, Cart/Checkout, Full OMS, Booking Engine) |
| **Commercial Verticals Covered** | **6 / 6** | Real Estate, Building Materials, Services, Appliances, Cars, Fashion |

---

## 2. Complete Master Inventory Table (Modules A through N)

### Module A: Application Foundation

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-FND-001` | شاشة البداية والتحميل<br/>Splash & Bootstrapping | `lib/features/navigation/` (Missing) | **NOT IMPLEMENTED** | **APPROVED V1** | Guest / User | App Cold Boot | `RouteNames.root` (`/`), `/auth/login` |
| `SCR-FND-002` | شاشات التهيئة والتعريف<br/>Onboarding Carousel | `lib/core/storage/storage_keys.dart` | **NOT IMPLEMENTED** | **FUTURE / DECISION** | First-Time User | `SCR-FND-001` | `RouteNames.root`, `/auth/login` |
| `SCR-FND-003` | الهيكل العام والتنقل الرئيسي<br/>Global Navigation Scaffold | `lib/features/navigation/presentation/pages/global_navigation_scaffold.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `RouteNames.root` | 5 Persistent Tabs (`0` to `4`) |
| `SCR-FND-004` | قائمة اختيار اللغة<br/>Language Selection Sheet | `lib/features/profile/presentation/pages/profile_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | Profile / Header Icon | Returns to caller (State updated) |
| `SCR-FND-005` | تبديل مظهر التطبيق (فاتح/داكن)<br/>Theme Toggle Sheet | `lib/features/profile/presentation/pages/profile_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | Profile / Header Icon | Returns to caller (State updated) |
| `SCR-FND-006` | عن التطبيق والمساعدة القانونية<br/>Help, Support & About | `lib/features/profile/presentation/pages/profile_page.dart` | **PARTIAL** | **APPROVED V1** | All | Profile Settings | External links, In-App Chat |
| `SCR-FND-007` | صفحة غير موجودة (404)<br/>Page Not Found View | `lib/shared/widgets/app_error_view.dart` | **IMPLEMENTED** | **APPROVED V1** | All | Invalid URL / Route | `RouteNames.root` |

---

### Module B: Authentication & Account

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-AUT-001` | تسجيل الدخول برقم الهاتف<br/>Phone Number Sign-In | `lib/core/routing/route_guards.dart` (Missing UI) | **NOT IMPLEMENTED** | **APPROVED V1** | Guest | Guest Action Trigger | `SCR-AUT-002` (OTP), `SCR-AUT-003` |
| `SCR-AUT-002` | تأكيد رمز التحقق السريع<br/>SMS OTP Verification | `lib/core/routing/route_guards.dart` (Missing UI) | **NOT IMPLEMENTED** | **APPROVED V1** | Guest | `SCR-AUT-001` | Originating Screen / Profile |
| `SCR-AUT-003` | الدخول بالبريد الإلكتروني<br/>Email & Password Fallback | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Registered User | `SCR-AUT-001` | Originating Screen / Profile |
| `SCR-AUT-004` | الملف الشخصي للمستخدم<br/>User Profile Page | `lib/features/profile/presentation/pages/profile_page.dart` | **IMPLEMENTED** | **APPROVED V1** | Registered User | Tab 4 (`/profile`) | `SCR-AUT-005`, `SCR-SEL-001`, `SCR-FND-004` |
| `SCR-AUT-005` | تعديل البيانات الشخصية<br/>Edit Personal Profile Modal | `lib/features/profile/presentation/pages/profile_page.dart` | **IMPLEMENTED** | **APPROVED V1** | Registered User | `SCR-AUT-004` | Dismiss with updated data |
| `SCR-AUT-006` | دفتر العناوين المحفوظة<br/>Saved Addresses Manager | `lib/features/profile/presentation/pages/profile_page.dart` | **IMPLEMENTED** | **APPROVED V1** | Registered User | `SCR-AUT-004` | Add / Edit Address Modal |
| `SCR-AUT-007` | تأكيد حذف أو تعطيل الحساب<br/>Account Deactivation Dialog | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Registered User | `SCR-AUT-004` | Log out $\to$ `RouteNames.root` |
| `SCR-AUT-008` | تنبيه انتهاء الجلسة<br/>Session Expiration Dialog | `lib/core/security/session_state.dart` | **NOT IMPLEMENTED** | **APPROVED V1** | Expired Session | Automatic on 401 | `SCR-AUT-001` (Sign-In) |

---

### Module C: Home & Discovery

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-HOM-001` | الرئيسية واستكشاف الأقسام<br/>Multi-Sector Home Feed | `lib/features/home/presentation/pages/home_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | Tab 0 (`/`) | Vertical Feeds, Search, Listing Details |
| `SCR-HOM-002` | شريط تبديل القطاعات التجارية<br/>Sector Filter Bar | `lib/shared/widgets/market_widgets/market_sector_filter_bar.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `SCR-HOM-001` | Switches active sector view |
| `SCR-HOM-003` | شريط الإعلانات الترويجية المميزة<br/>Hero Promotional Carousel | `lib/features/home/widgets/hero_carousel/hero_carousel.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `SCR-HOM-001` | Filtered Feed / Promotion Detail |
| `SCR-HOM-004` | شبكة التصنيفات الرئيسية<br/>Main Categories Grid | `lib/features/home/widgets/main_categories/main_categories_section.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `SCR-HOM-001` | Vertical Category Feeds |
| `SCR-HOM-005` | شريط الإعلانات القريبة جغرافياً<br/>Nearby Listings Carousel | `lib/shared/models/home_feed_models.dart` | **PARTIAL** | **APPROVED V1** | All | `SCR-HOM-001` | Listing Details (`API-SRC-001`) |
| `SCR-HOM-006` | الإعلانات الأكثر طلباً ومميزة<br/>Most Requested / Featured Section | `lib/features/home/widgets/most_requested_services/` | **IMPLEMENTED** | **APPROVED V1** | All | `SCR-HOM-001` | Service / Listing Details |
| `SCR-HOM-007` | الحالة الفارغة للرئيسية<br/>Home Empty Discovery State | `lib/shared/widgets/app_empty_state.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `SCR-HOM-001` | Pull-to-refresh / Reset filters |

---

### Module D: Real Estate

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-RES-001` | سوق العقارات وتغذية الوحدات<br/>Real Estate Home & Feed | `lib/features/real_estate/presentation/pages/real_estate_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/real-estate` | `SCR-RES-002`, `SCR-RES-004`, `SCR-RES-008` |
| `SCR-RES-002` | تفاصيل الوحدة العقارية<br/>Property Listing Detail | `lib/features/real_estate/presentation/pages/real_estate_detail_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/real-estate/detail` | `SCR-RES-003`, `SCR-CHT-002`, Advertiser |
| `SCR-RES-003` | معرض صور وفيديوهات العقار<br/>Property Fullscreen Gallery | `lib/features/real_estate/widgets/real_estate_detail/property_gallery/` | **IMPLEMENTED** | **APPROVED V1** | All | `SCR-RES-002` | Dismiss back to details |
| `SCR-RES-004` | البحث العقاري التفاعلي بالخريطة<br/>Interactive Map Search | `lib/features/real_estate/map/presentation/pages/real_estate_map_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/real-estate/map` | `SCR-RES-002` |
| `SCR-RES-005` | ريلز وفيديوهات العقارات القصيرة<br/>Property Video Reels Feed | `lib/features/real_estate/reels/presentation/pages/reels_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/real-estate/reels` | `SCR-RES-002`, Fullscreen Player |
| `SCR-RES-006` | نشر فيديو ريلز جديد<br/>Reel Publish Screen | `lib/features/real_estate/reels/presentation/pages/reel_publish_page.dart` | **IMPLEMENTED** | **PROTOTYPE / V2** | Advertiser | `/real-estate/reels/publish` | Return to Reels Feed |
| `SCR-RES-007` | إحصائيات مشاهدات الريلز<br/>Reel Analytics Dashboard | `lib/features/real_estate/reels/presentation/pages/reel_analytics_page.dart` | **IMPLEMENTED** | **PROTOTYPE / V2** | Advertiser | `/real-estate/reels/analytics` | Dismiss |
| `SCR-RES-008` | لوحة فلاتر البحث العقاري<br/>Real Estate Filter Sheet | `lib/features/real_estate/widgets/real_estate_filter_sheet/` | **IMPLEMENTED** | **APPROVED V1** | All | Filter Bar on `SCR-RES-001` | Apply $\to$ `SCR-RES-001` |
| `SCR-RES-009` | مفضلة العقارات المخصصة<br/>Real Estate Favorites | `lib/features/real_estate/favorites/presentation/pages/real_estate_favorites_page.dart` | **IMPLEMENTED** | **PROTOTYPE (DUPLICATE)** | All | `/real-estate/favorites` | Replaced by Global `SCR-ACT-001` |
| `SCR-RES-010` | إشعارات قطاع العقارات<br/>Real Estate Sector Alerts | `lib/features/real_estate/notifications/presentation/pages/real_estate_notifications_page.dart` | **IMPLEMENTED** | **PROTOTYPE (DUPLICATE)** | All | `/real-estate/notifications` | Replaced by Global `SCR-NOT-001` |
| `SCR-RES-011` | صفحة المشروع / الكمبوند العقاري<br/>Compound / Project Detail | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | All | Listing Detail / Filter | Listing Feed of Compound |
| `SCR-RES-012` | الملف التعريفي للوسيط / المطور<br/>Broker / Developer Profile | `lib/features/real_estate/widgets/real_estate_detail/advertiser_profile_card/` | **IMPLEMENTED** | **APPROVED V1** | All | Listing Detail (`SCR-RES-002`) | Merchant Active Ads, Contact |

---

### Module E: Building Materials & Electrical Supplies

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-MAT-001` | سوق مواد البناء وتحديثات الأسعار<br/>Materials Home & Price Ticker | `lib/features/building_materials/presentation/pages/building_materials_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/building-materials` | `SCR-MAT-003`, `SCR-MAT-004`, `SCR-MAT-005` |
| `SCR-MAT-002` | دليل تصنيفات مواد البناء والكهرباء<br/>Materials All Categories Grid | `lib/features/building_materials/presentation/pages/building_materials_categories_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/building-materials/categories` | `SCR-MAT-003` |
| `SCR-MAT-003` | تغذية منتجات التصنيف الصناعي<br/>Material Category Listing Feed | `lib/features/building_materials/presentation/pages/building_material_category_detail_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/building-materials/category-detail` | `SCR-MAT-005`, Filters |
| `SCR-MAT-004` | شاشة حديد التسليح وبورصة الأسعار<br/>Steel Rebar Specialized Listing | `lib/features/building_materials/presentation/pages/steel_rebar_listing_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/building-materials/steel-rebar` | `SCR-MAT-005`, Contact Factory |
| `SCR-MAT-005` | بطاقة تفاصيل مادة البناء أو المنتج<br/>Material Product / Listing Detail | `lib/features/building_materials/presentation/pages/building_material_product_detail_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/building-materials/product-detail` | `SCR-CHT-002`, Supplier Profile |
| `SCR-MAT-006` | الملف التعريفي للمصنع / المورد<br/>Supplier Profile & Branches | `backend_blueprint/02_DATABASE_DESIGN.md` | **PARTIAL** | **APPROVED V1** | All | `SCR-MAT-005` | Branch list, Contact channels |
| `SCR-MAT-007` | نموذج طلب عروض أسعار (RFQ)<br/>Request For Quotation Creation | `lib/features/building_materials/presentation/pages/rfq_create_page.dart` | **IMPLEMENTED** | **PROTOTYPE / V2** | Contractor | `/building-materials/rfq` | Submit $\to$ Activity Feed |
| `SCR-MAT-008` | سلة طلبات مواد البناء<br/>Building Materials Cart | `lib/features/building_materials/presentation/pages/building_materials_cart_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Buyer | `/building-materials/cart` | Checkout (`SCR-MAT-009`) |
| `SCR-MAT-009` | إتمام شراء وتوريد مواد البناء<br/>Building Materials Checkout | `lib/features/building_materials/presentation/pages/building_materials_checkout_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Buyer | `/building-materials/checkout` | Order Confirmed |
| `SCR-MAT-010` | سجل طلبيات وتوريدات المقاولات<br/>Materials Orders Feed | `lib/features/building_materials/presentation/pages/building_materials_orders_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Buyer | `/building-materials/orders` | Order Detail (`SCR-MAT-011`) |
| `SCR-MAT-011` | تفاصيل بوليصة الشحن والتوريد<br/>Materials Order Detail Page | `lib/features/building_materials/presentation/pages/building_material_order_detail_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Buyer | `/building-materials/orders/detail` | Driver tracking |
| `SCR-MAT-012` | إشعارات أسعار وتوريد مواد البناء<br/>Materials Sector Notifications | `lib/features/building_materials/presentation/pages/building_materials_notifications_page.dart` | **IMPLEMENTED** | **PROTOTYPE (DUPLICATE)** | All | `/building-materials/notifications` | Replaced by Global `SCR-NOT-001` |

---

### Module F: Home & Engineering Services

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-SRV-001` | دليل الخدمات الهندسية والمنزلية<br/>Home Services Home Directory | `lib/features/home_services/presentation/pages/home_services_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/home-services` | `SCR-SRV-002`, `SCR-SRV-003`, `SCR-SRV-005` |
| `SCR-SRV-002` | كتالوج تصنيفات الصيانة والتشطيب<br/>Services Catalog View | `lib/features/home_services/presentation/views/home_services_catalog_view.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/home-services/catalog` | `SCR-SRV-003` |
| `SCR-SRV-003` | تفاصيل الخدمة وبطاقة الاعتماد<br/>Service Listing Detail Page | `lib/features/home_services/presentation/pages/home_service_detail_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/home-services/service-detail` | `SCR-SRV-005`, `SCR-CHT-002`, Phone |
| `SCR-SRV-004` | بطاقة صيانة وغسيل التكييفات<br/>AC Maintenance Specialized Detail | `lib/features/home_services/presentation/pages/ac_service_detail_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/home-services/ac-service-detail` | `SCR-SRV-005`, Call Technician |
| `SCR-SRV-005` | الملف التعريفي لمقدم الخدمة / المكتب<br/>Service Provider Profile & Coverage | `lib/features/home_services/presentation/pages/service_provider_detail_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/home-services/provider-detail` | Coverage Areas, Contact Provider |
| `SCR-SRV-006` | معالج حجز زيارة الفني<br/>Service Booking Wizard | `lib/features/home_services/presentation/pages/home_services_booking_wizard_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Customer | `/home-services/book` | Booking Confirmed |
| `SCR-SRV-007` | تفاصيل موعد الزيارة والتسعير<br/>Service Booking Detail Page | `lib/features/home_services/presentation/pages/home_service_booking_detail_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Customer | `/home-services/booking-detail` | `SCR-SRV-008` (Tracking) |
| `SCR-SRV-008` | التتبع الحي لمسار وصول الفني<br/>Technician Live GPS Tracking | `lib/features/home_services/presentation/pages/technician_tracking_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Customer | `/home-services/tracking` | Service Completed |
| `SCR-SRV-009` | سجل مواعيد الزيارات السابقة<br/>Bookings History View | `lib/features/home_services/presentation/views/home_services_bookings_view.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Customer | `/home-services/bookings` | Booking Detail (`SCR-SRV-007`) |
| `SCR-SRV-010` | مفضلة مزودي الخدمات المعتمدين<br/>Home Services Favorites View | `lib/features/home_services/presentation/views/home_services_favorites_view.dart` | **IMPLEMENTED** | **PROTOTYPE (DUPLICATE)** | All | `/home-services/favorites` | Replaced by Global `SCR-ACT-001` |
| `SCR-SRV-011` | تنبيهات قطاع الخدمات والصيانة<br/>Home Services Notifications View | `lib/features/home_services/presentation/views/home_services_notifications_view.dart` | **IMPLEMENTED** | **PROTOTYPE (DUPLICATE)** | All | `/home-services/notifications` | Replaced by Global `SCR-NOT-001` |

---

### Module G: Home Appliances & Decoration

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-APP-001` | معرض الأجهزة المنزلية والديكور<br/>Home Appliances Home Feed | `lib/features/home_appliances/presentation/pages/home_appliances_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/home-appliances` | `SCR-APP-002`, `SCR-APP-003`, `SCR-APP-004` |
| `SCR-APP-002` | دليل تصنيفات الأجهزة والمفروشات<br/>Appliances Categories Grid | `lib/features/home_appliances/categories/presentation/pages/home_appliances_categories_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/home-appliances/categories` | `SCR-APP-003` |
| `SCR-APP-003` | تغذية إعلانات أجهزة تصنيف محدد<br/>Appliance Category Listing Feed | `lib/features/home_appliances/presentation/pages/appliance_category_listing_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/home-appliances/category` | `SCR-APP-004`, Filters |
| `SCR-APP-004` | بطاقة تفاصيل الجهاز أو الأثاث<br/>Appliance Listing Detail Page | `lib/shared/models/home_feed_models.dart` | **PARTIAL** | **APPROVED V1** | All | Listing Tap | `SCR-CHT-002`, Store Profile |
| `SCR-APP-005` | الملف التعريفي لمعرض الأجهزة<br/>Appliance Showroom Store Profile | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | All | `SCR-APP-004` | Branch Showroom Map, Contacts |
| `SCR-APP-006` | سلة شراء الأجهزة المنزلية<br/>Home Appliances Cart | `lib/features/home_appliances/cart/presentation/pages/home_appliances_cart_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Buyer | `/home-appliances/cart` | Checkout (`SCR-APP-007`) |
| `SCR-APP-007` | الدفع والشحن للأجهزة المنزلية<br/>Home Appliances Checkout | `lib/features/home_appliances/checkout/presentation/pages/home_appliances_checkout_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Buyer | `/home-appliances/checkout` | Order Placed |
| `SCR-APP-008` | سجل طلبيات وتوصيل الأجهزة<br/>Appliances Orders Feed | `lib/features/home_appliances/orders/presentation/pages/home_appliances_orders_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Buyer | `/home-appliances/orders` | Order Tracking |
| `SCR-APP-009` | تنبيهات عروض الأجهزة والتخفيضات<br/>Appliances Sector Notifications | `lib/features/home_appliances/notifications/presentation/pages/home_appliances_notifications_page.dart` | **IMPLEMENTED** | **PROTOTYPE (DUPLICATE)** | All | `/home-appliances/notifications` | Replaced by Global `SCR-NOT-001` |

---

### Module H: Cars & Automotive

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-CAR-001` | حراج وسوق السيارات والمركبات<br/>Cars Home & Search Feed | `lib/features/cars/presentation/pages/cars_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/cars` | `SCR-CAR-002`, `SCR-CAR-003`, Dealerships |
| `SCR-CAR-002` | تفاصيل السيارة والمواصفات الفنية<br/>Vehicle Listing Detail Page | `lib/features/cars/presentation/pages/car_detail_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/cars/detail` | `SCR-CHT-002`, Inspection Dialog, Phone |
| `SCR-CAR-003` | لوحة فلاتر السيارات المتقدمة<br/>Automotive Filter Bottom Sheet | `lib/features/cars/widgets/car_filter_modal.dart` | **IMPLEMENTED** | **APPROVED V1** | All | Filter Icon on `SCR-CAR-001` | Apply $\to$ `SCR-CAR-001` |
| `SCR-CAR-004` | الملف التعريفي لمعرض السيارات<br/>Car Dealership / Showroom Profile | `backend_blueprint/02_DATABASE_DESIGN.md` | **PARTIAL** | **APPROVED V1** | All | `SCR-CAR-002` | Dealership Cars Feed, Showroom Location |
| `SCR-CAR-005` | موقع فحص ومعاينة السيارة<br/>Vehicle Inspection Location Dialog | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Buyer | `SCR-CAR-002` | Map Navigation / Centroid |

---

### Module I: Clothes & Fashion Accessories

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-FAS-001` | سوق الأزياء والملابس<br/>Fashion Home & Department Tabs | `lib/features/fashion/presentation/pages/fashion_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/fashion` | `SCR-FAS-002`, `SCR-FAS-003` |
| `SCR-FAS-002` | دليل أقسام الأزياء (رجالي/نسائي/أطفال)<br/>Fashion Categories Page | `lib/features/fashion/presentation/pages/fashion_categories_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/fashion/categories` | `SCR-FAS-001` (Filtered) |
| `SCR-FAS-003` | بطاقة تفاصيل القطعة والمقاسات<br/>Fashion Product Detail Page | `lib/features/fashion/presentation/pages/fashion_product_detail_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/fashion/detail` | `SCR-CHT-002`, Boutique Profile |
| `SCR-FAS-004` | الملف التعريفي لمتجر الأزياء<br/>Fashion Boutique Store Profile | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | All | `SCR-FAS-003` | Boutique Inventory Feed, Contacts |
| `SCR-FAS-005` | حقيبة تسوق الأزياء والمقاسات<br/>Fashion Shopping Bag / Cart | `lib/features/fashion/presentation/pages/fashion_cart_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Shopper | `/fashion/cart` | Checkout Flow |

---

### Module J: Communication & In-App Chat

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-CHT-001` | قائمة المحادثات والرسائل الفورية<br/>Active Conversations Feed | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Buyer / Seller | Profile / Header / Nav | `SCR-CHT-002` (Chat Room) |
| `SCR-CHT-002` | غرفة الدردشة المباشرة حول الإعلان<br/>Listing-Bound Chat Room | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Buyer / Seller | `SCR-CHT-001`, Listing Detail | `SCR-CHT-003`, Listing Detail |
| `SCR-CHT-003` | نافذة كشف أرقام التواصل الخارجي<br/>External Contact Action Sheet | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Buyer | Listing Contact Button | Native WhatsApp / Phone Dialer |
| `SCR-CHT-004` | نافذة الإبلاغ عن محتوى أو احتيال<br/>Abuse & Fraud Report Dialog | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | All | Listing / Chat Menu | Confirm $\to$ Toast acknowledgment |
| `SCR-CHT-005` | شاشة المحادثات الفارغة وانقطاع الشبكة<br/>Empty Chat & Offline State | `lib/shared/widgets/app_empty_state.dart` | **NOT IMPLEMENTED** | **APPROVED V1** | User | `SCR-CHT-001` (No chats) | Explore Feed |

---

### Module K: Favorites & My Activity

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-ACT-001` | المفضلة الموحدة لكافة الأقسام<br/>Global Unified Favorites Page | `lib/features/favorites/presentation/pages/global_favorites_page.dart` | **IMPLEMENTED** | **APPROVED V1** | Registered User | Tab 3 (`/favorites`) | Listing Details across sectors |
| `SCR-ACT-002` | إدارة إعلاناتي وحالات النشر<br/>My Advertisements Management Hub | `lib/features/activity/presentation/pages/my_activity_page.dart` | **PARTIAL** | **APPROVED V1** | Seller / User | Tab 2 (`/my-activity`) | `SCR-ACT-004`, `SCR-LST-007` (Edit) |
| `SCR-ACT-003` | تبويبات دورة حياة الإعلان (مفعل/معلق/مرفوض/مخفي/مباع)<br/>Listing Lifecycle Filter Bar | `lib/features/activity/presentation/controllers/` | **PARTIAL** | **APPROVED V1** | Seller / User | `SCR-ACT-002` | Filtered list by status |
| `SCR-ACT-004` | تفاصيل سبب رفض الإعلان والدعم<br/>Moderation Rejection Notes Modal | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller | `SCR-ACT-002` (Rejected Ad) | `SCR-LST-007` (Edit & Resubmit) |
| `SCR-ACT-005` | قائمة التحكم السريع في الإعلان<br/>Listing Quick Actions Bottom Sheet | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller | `SCR-ACT-002` Item Menu | Toggle Visibility, Mark Sold, Delete |
| `SCR-ACT-006` | نشاط المعاملات والطلبات المجمعة<br/>Unified Activity Orders Prototype | `lib/features/activity/presentation/pages/my_activity_page.dart` | **IMPLEMENTED** | **PROTOTYPE / FUTURE V3** | Buyer | Tab 2 (Current Code) | Replaced by `SCR-ACT-002` in V1 |

---

### Module L: Seller Account & Verification

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-SEL-001` | مركز الحسابات التجارية ولوحة التحكم<br/>Seller Account Hub & Overview | `lib/features/profile/presentation/pages/profile_page.dart` | **PARTIAL** | **APPROVED V1** | Seller Owner | Profile Page (`SCR-AUT-004`) | `SCR-SEL-002`, `SCR-SEL-005`, `SCR-SEL-007` |
| `SCR-SEL-002` | محول الحسابات التجارية المتعددة<br/>Multi-Account Context Switcher | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | User / Owner | Header / Profile | Switch active account context |
| `SCR-SEL-003` | معالج إنشاء حساب تجاري جديد<br/>Create Seller Account Wizard | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | User | `SCR-SEL-001` | `SCR-SEL-004`, `SCR-SEL-005` |
| `SCR-SEL-004` | اختيار الكيان التجاري (فرد/شركة/مصنع/مكتب/متجر)<br/>Seller Type Selection Step | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | User | `SCR-SEL-003` Step 1 | `SCR-SEL-005` (Document Upload) |
| `SCR-SEL-005` | رفع المستندات الرسمية للتوثيق<br/>Verification Documents Upload | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller | `SCR-SEL-003` Step 2 | `SCR-SEL-006` (Submission Status) |
| `SCR-SEL-006` | شاشة حالة التوثيق وملاحظات الإدارة<br/>Account Verification Status Screen | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller | `SCR-SEL-001` Banner | Re-upload docs if rejected |
| `SCR-SEL-007` | إدارة فروع المنشأة التجارية<br/>Commercial Branches Manager | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Owner / Manager | `SCR-SEL-001` | `SCR-SEL-008` (Add Branch Form) |
| `SCR-SEL-008` | نموذج إضافة أو تعديل فرع تجاري<br/>Add / Edit Branch Form | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Owner / Manager | `SCR-SEL-007` | Save Branch $\to$ `SCR-SEL-007` |
| `SCR-SEL-009` | تحديد نطاق ومناطق تغطية الخدمة<br/>Service Area Coverage Config | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Provider / Factory | `SCR-SEL-001` | Save Coverage Areas |
| `SCR-SEL-010` | إدارة فريق العمل والصلاحيات (RBAC)<br/>Team Members & Roles Manager | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Account Owner | `SCR-SEL-001` | Invite Member Dialog |
| `SCR-SEL-011` | مؤشر الحصص والحدود اليومية<br/>Daily Quota Usage & Limits Bar | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller | `SCR-SEL-001` / Listing Post | Platform Support Contact |

---

### Module M: Global Notifications & Search

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-NOT-001` | مركز الإشعارات التشغيلية الموحد<br/>Global Notifications Center | `lib/features/notifications/presentation/pages/global_notifications_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | `/notifications` / Header Icon | Deep links to Ad, Chat, or Quota |
| `SCR-NOT-002` | تفاصيل الإشعار والربط التلقائي<br/>Notification Deep Link Router | `lib/core/notifications/presentation/` | **PARTIAL** | **APPROVED V1** | All | `SCR-NOT-001` Tap | Resolves target screen |
| `SCR-NOT-003` | إعدادات وتفضيلات التنبيهات<br/>Notification Preferences Settings | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Registered User | Profile Settings | Save preferences |
| `SCR-SRC-001` | محرك البحث والاستكشاف الشامل<br/>Cross-Sector Explore & Search Page | `lib/features/explore/presentation/pages/explore_page.dart` | **IMPLEMENTED** | **APPROVED V1** | All | Tab 1 (`/explore`) | `SCR-SRC-003`, Listing Details |
| `SCR-SRC-002` | سجل وسجل اقتراحات البحث الحديثة<br/>Search History & Suggestions Sheet | `lib/features/explore/widgets/` | **IMPLEMENTED** | **APPROVED V1** | All | Search Input Focus | Executes search on selection |
| `SCR-SRC-003` | لوحة الفلاتر الشاملة متعددة الأقسام<br/>Universal Search Filter Sheet | `backend_blueprint/03_API_SPECIFICATION.md` | **PARTIAL** | **APPROVED V1** | All | `SCR-SRC-001` Filter Icon | Apply $\to$ `SCR-SRC-001` Feed |
| `SCR-SRC-004` | نافذة اختيار الموقع والمحافظة<br/>Administrative Location Selector | `lib/core/mock_data/locations.json` | **PARTIAL** | **APPROVED V1** | All | Header / Filter Location | Updates `area_id` context |

---

### Module N: Listing Creation & Editing

| Screen ID | Screen Name (AR / EN) | Flutter Source Path | Current Status | V1 Status | Primary Role | Entry Route | Primary Exit Routes |
|---|---|---|:---:|:---:|---|---|---|
| `SCR-LST-001` | اختيار قسم الإعلان الرئيسي والفرعي<br/>Create Listing: Category Selector | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller / Owner | Global "+" FAB / Hub | `SCR-LST-002` (Dynamic Form) |
| `SCR-LST-002` | نموذج الحقول الديناميكية حسب القسم<br/>Dynamic Category Listing Form | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller / Owner | `SCR-LST-001` | `SCR-LST-003` (Media Upload) |
| `SCR-LST-003` | رفع وترتيب صور وفيديوهات الإعلان<br/>Media Upload & Sort (Presigned R2) | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller / Owner | `SCR-LST-002` | `SCR-LST-004` (Location Picker) |
| `SCR-LST-004` | محدد الموقع ذو المستويين (سري/عام)<br/>Two-Tier Location & Privacy Picker | `backend_blueprint/02_DATABASE_DESIGN.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller / Owner | `SCR-LST-003` | `SCR-LST-005` (Review) |
| `SCR-LST-005` | مراجعة مسودة الإعلان وتأكيد النشر<br/>Listing Draft Preview & Submit | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller / Owner | `SCR-LST-004` | Submit $\to$ `SCR-LST-006` |
| `SCR-LST-006` | شاشة تأكيد الإرسال وقيد المراجعة<br/>Submission Confirmation & Status | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller / Owner | `SCR-LST-005` Submit | `SCR-ACT-002` (My Activity Feed) |
| `SCR-LST-007` | تعديل بيانات إعلان موجود أو مرفوض<br/>Edit Existing Listing Form | `backend_blueprint/03_API_SPECIFICATION.md` | **NOT IMPLEMENTED** | **APPROVED V1** | Seller / Owner | `SCR-ACT-002` / `SCR-ACT-004` | Resubmit for Moderation |

