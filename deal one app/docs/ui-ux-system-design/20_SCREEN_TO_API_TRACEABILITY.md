# 20 — Screen to API Traceability Matrix

## 1. Traceability Architecture & Governance

This matrix establishes an immutable, bidirectional bridge between every **Screen ID** in the Deal One UI inventory, its **Product Requirement / ADR anchor**, its **Flutter Source Location**, and its corresponding **Backend REST API Endpoint** from the 52 endpoints defined in the Backend Blueprint (`backend_blueprint/03_API_SPECIFICATION.md`).

---

## 2. Master Screen-to-API Traceability Matrix

| Screen ID | Screen Name (AR / EN) | Product Requirement / ADR | Flutter Source File | Backend API Dependency | HTTP Method & Path | V1 Status |
|---|---|---|---|---|---|:---:|
| `SCR-FND-001` | شاشة البداية<br/>Splash & Bootstrapping | App Startup Protocol | `lib/bootstrap/bootstrap.dart` | `API-AUTH-003` | `POST /api/v1/auth/token/refresh` | **APPROVED V1** |
| `SCR-FND-003` | الهيكل العام والتنقل<br/>Global Navigation Shell | Global Shell Architecture | `lib/features/navigation/` | Client-Side / Registry | N/A | **APPROVED V1** |
| `SCR-FND-004` | اختيار اللغة<br/>Language Selector | i18n Requirement | `lib/core/localization/` | `API-USR-002` | `PATCH /api/v1/users/me` | **APPROVED V1** |
| `SCR-AUT-001` | تسجيل الدخول بالهاتف<br/>Phone Number Sign-In | ADR-003 / SRS 3.1 | `lib/core/routing/route_guards.dart` | `API-AUTH-001` | `POST /api/v1/auth/otp/send` | **APPROVED V1** |
| `SCR-AUT-002` | تأكيد رمز التحقق<br/>SMS OTP Verification | ADR-003 / SRS 3.1 | `lib/core/routing/route_guards.dart` | `API-AUTH-002` | `POST /api/v1/auth/otp/verify` | **APPROVED V1** |
| `SCR-AUT-003` | الدخول بالبريد<br/>Email Sign-In Fallback | SRS 3.1 | `backend_blueprint/` | `API-AUTH-004` | `POST /api/v1/auth/login` | **APPROVED V1** |
| `SCR-AUT-004` | الملف الشخصي<br/>User Profile Page | SRS 3.2 | `lib/features/profile/` | `API-USR-001` | `GET /api/v1/users/me` | **APPROVED V1** |
| `SCR-AUT-005` | تعديل الملف الشخصي<br/>Edit Profile Modal | SRS 3.2 | `lib/features/profile/` | `API-USR-002` | `PATCH /api/v1/users/me` | **APPROVED V1** |
| `SCR-AUT-007` | حذف الحساب<br/>Account Deletion Dialog | Store Policies | `lib/features/profile/` | `API-USR-004` | `DELETE /api/v1/users/me` | **APPROVED V1** |
| `SCR-HOM-001` | الرئيسية واستكشاف الأقسام<br/>Home Discovery Feed | ADR-001 / SRS 3.3 | `lib/features/home/` | `API-SRC-002` | `GET /api/v1/search/feed/home` | **APPROVED V1** |
| `SCR-RES-001` | سوق العقارات وتغذية الوحدات<br/>Real Estate Home | ADR-003 / SRS 3.4 | `lib/features/real_estate/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-RES-002` | تفاصيل الوحدة العقارية<br/>Property Detail Page | ADR-006 / ADR-008 | `lib/features/real_estate/` | `API-LST-007` | `GET /api/v1/listings/:id` | **APPROVED V1** |
| `SCR-RES-004` | البحث العقاري بالخريطة<br/>Interactive Map Search | ADR-006 / SRS 3.4 | `lib/features/real_estate/map/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-RES-005` | ريلز العقارات<br/>Property Video Reels | SRS 3.4 (Reels) | `lib/features/real_estate/reels/`| `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-RES-008` | فلاتر العقارات<br/>Real Estate Filter Sheet | ADR-003 / Filter Arch | `lib/features/real_estate/widgets/`| `API-CAT-002` | `GET /api/v1/categories/:id/fields` | **APPROVED V1** |
| `SCR-RES-011` | صفحة الكمبوند / المشروع<br/>Compound Project Detail | SRS 3.4 | `backend_blueprint/` | `API-LST-007` | `GET /api/v1/projects/:id` | **APPROVED V1** |
| `SCR-RES-012` | بروفايل الوسيط العقاري<br/>Broker Profile | ADR-004 / ADR-005 | `lib/features/real_estate/widgets/`| `API-ACC-004` | `GET /api/v1/accounts/:id` | **APPROVED V1** |
| `SCR-MAT-001` | سوق مواد البناء وبورصة الأسعار<br/>Materials Home | ADR-003 / SRS 3.5 | `lib/features/building_materials/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-MAT-002` | تصنيفات مواد البناء<br/>Materials Categories Grid | SRS 3.5 | `lib/features/building_materials/` | `API-CAT-001` | `GET /api/v1/categories` | **APPROVED V1** |
| `SCR-MAT-004` | بورصة حديد التسليح<br/>Steel Rebar Specialized | SRS 3.5 | `lib/features/building_materials/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-MAT-005` | تفاصيل مادة البناء<br/>Material Product Detail | ADR-008 / SRS 3.5 | `lib/features/building_materials/` | `API-LST-007` | `GET /api/v1/listings/:id` | **APPROVED V1** |
| `SCR-MAT-006` | بروفايل المصنع والمستودعات<br/>Supplier Profile | ADR-004 / ADR-005 | `backend_blueprint/` | `API-ACC-004` | `GET /api/v1/accounts/:id` | **APPROVED V1** |
| `SCR-MAT-008` | سلة مواد البناء<br/>Materials Cart | Out of Scope (V3) | `lib/features/building_materials/` | N/A (Deferred) | N/A | **PROTOTYPE / V3** |
| `SCR-MAT-009` | إتمام شراء مواد البناء<br/>Materials Checkout | Out of Scope (V3) | `lib/features/building_materials/` | N/A (Deferred) | N/A | **PROTOTYPE / V3** |
| `SCR-SRV-001` | دليل الخدمات والصيانة<br/>Home Services Home | ADR-003 / SRS 3.6 | `lib/features/home_services/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-SRV-003` | تفاصيل الخدمة الهندسية<br/>Service Detail Page | ADR-008 / SRS 3.6 | `lib/features/home_services/` | `API-LST-007` | `GET /api/v1/listings/:id` | **APPROVED V1** |
| `SCR-SRV-004` | بطاقة صيانة التكييفات<br/>AC Service Detail | SRS 3.6 | `lib/features/home_services/` | `API-LST-007` | `GET /api/v1/listings/:id` | **APPROVED V1** |
| `SCR-SRV-005` | بروفايل مقدم الخدمة<br/>Service Provider Profile | ADR-004 / ADR-006 | `lib/features/home_services/` | `API-ACC-004` | `GET /api/v1/accounts/:id` | **APPROVED V1** |
| `SCR-SRV-006` | معالج حجز زيارة الفني<br/>Booking Wizard | ADR-010 (Deferred) | `lib/features/home_services/` | N/A (Deferred) | N/A | **PROTOTYPE / V3** |
| `SCR-SRV-008` | تتبع الفني بالـ GPS<br/>Technician Tracking | ADR-010 (Deferred) | `lib/features/home_services/` | N/A (Deferred) | N/A | **PROTOTYPE / V3** |
| `SCR-APP-001` | معرض الأجهزة والديكور<br/>Home Appliances Home | ADR-003 / SRS 3.7 | `lib/features/home_appliances/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-APP-004` | تفاصيل الجهاز المنزلي<br/>Appliance Listing Detail | ADR-008 / SRS 3.7 | `lib/shared/models/` | `API-LST-007` | `GET /api/v1/listings/:id` | **APPROVED V1** |
| `SCR-APP-006` | سلة الأجهزة المنزلية<br/>Appliances Cart | Out of Scope (V3) | `lib/features/home_appliances/` | N/A (Deferred) | N/A | **PROTOTYPE / V3** |
| `SCR-CAR-001` | حراج وسوق السيارات<br/>Cars Home Feed | ADR-003 / SRS 3.8 | `lib/features/cars/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-CAR-002` | تفاصيل السيارة الفنية<br/>Vehicle Detail Page | ADR-006 / ADR-008 | `lib/features/cars/` | `API-LST-007` | `GET /api/v1/listings/:id` | **APPROVED V1** |
| `SCR-CAR-003` | فلاتر السيارات المتقدمة<br/>Automotive Filter Sheet | ADR-003 / Filter Arch | `lib/features/cars/widgets/` | `API-CAT-002` | `GET /api/v1/categories/:id/fields` | **APPROVED V1** |
| `SCR-CAR-004` | بروفايل معرض السيارات<br/>Dealership Profile | ADR-004 / ADR-005 | `backend_blueprint/` | `API-ACC-004` | `GET /api/v1/accounts/:id` | **APPROVED V1** |
| `SCR-FAS-001` | سوق الأزياء والملابس<br/>Fashion Home Feed | ADR-003 / SRS 3.9 | `lib/features/fashion/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-FAS-003` | تفاصيل القطعة والمقاسات<br/>Fashion Product Detail | ADR-008 / SRS 3.9 | `lib/features/fashion/` | `API-LST-007` | `GET /api/v1/listings/:id` | **APPROVED V1** |
| `SCR-FAS-005` | حقيبة تسوق الأزياء<br/>Fashion Cart | Out of Scope (V3) | `lib/features/fashion/` | N/A (Deferred) | N/A | **PROTOTYPE / V3** |
| `SCR-CHT-001` | قائمة المحادثات النشطة<br/>Active Conversations | ADR-008 / SRS 3.10 | `backend_blueprint/` | `API-CHT-002` | `GET /api/v1/chat/conversations` | **APPROVED V1** |
| `SCR-CHT-002` | غرفة الدردشة المباشرة<br/>Listing-Bound Chat Room | ADR-008 / SRS 3.10 | `backend_blueprint/` | `API-CHT-003` | `GET /api/v1/chat/conversations/:id/messages` | **APPROVED V1** |
| `SCR-CHT-003` | كشف أرقام التواصل<br/>External Contact Sheet | ADR-008 / SRS 3.10 | `backend_blueprint/` | `API-SRC-003` | `POST /api/v1/search/listings/:id/reveal-contact` | **APPROVED V1** |
| `SCR-CHT-004` | الإبلاغ عن احتيال<br/>Abuse Report Dialog | Platform Safety | `backend_blueprint/` | `API-REP-001` | `POST /api/v1/reports` | **APPROVED V1** |
| `SCR-ACT-001` | المفضلة الموحدة<br/>Global Favorites Page | SRS 3.11 | `lib/features/favorites/` | `API-FAV-001` | `GET /api/v1/favorites` | **APPROVED V1** |
| `SCR-ACT-002` | إدارة إعلاناتي وحالاتها<br/>My Advertisements Feed | ADR-007 / SRS 3.11 | `lib/features/activity/` | `API-LST-008` | `GET /api/v1/listings/merchant` | **APPROVED V1** |
| `SCR-ACT-004` | ملاحظات رفض الإعلان<br/>Moderation Rejection Notes | ADR-007 | `backend_blueprint/` | `API-LST-007` | `GET /api/v1/listings/:id` | **APPROVED V1** |
| `SCR-ACT-005` | تحكم الإعلان السريع<br/>Listing Quick Actions Sheet | ADR-007 | `backend_blueprint/` | `API-LST-004` | `PATCH /api/v1/listings/:id/visibility` | **APPROVED V1** |
| `SCR-SEL-001` | مركز الحسابات التجارية<br/>Seller Account Hub | ADR-004 / ADR-005 | `lib/features/profile/` | `API-ACC-004` | `GET /api/v1/accounts/:id` | **APPROVED V1** |
| `SCR-SEL-002` | محول الحسابات التجارية<br/>Multi-Account Switcher | ADR-005 | `backend_blueprint/` | `API-ACC-001` | `GET /api/v1/accounts/my` | **APPROVED V1** |
| `SCR-SEL-003` | إنشاء حساب تجاري جديد<br/>Create Seller Account | ADR-004 / ADR-005 | `backend_blueprint/` | `API-ACC-002` | `POST /api/v1/accounts` | **APPROVED V1** |
| `SCR-SEL-005` | رفع مستندات التوثيق<br/>Upload Verification Docs | ADR-004 | `backend_blueprint/` | `API-ACC-003` | `POST /api/v1/accounts/:id/verifications` | **APPROVED V1** |
| `SCR-SEL-007` | إدارة فروع المنشأة<br/>Branch Manager | ADR-006 | `backend_blueprint/` | `API-GEO-004` | `GET /api/v1/accounts/:id/branches` | **APPROVED V1** |
| `SCR-SEL-008` | إضافة أو تعديل فرع<br/>Add Branch Form | ADR-006 | `backend_blueprint/` | `API-GEO-003` | `POST /api/v1/accounts/:id/branches` | **APPROVED V1** |
| `SCR-SEL-009` | نطاق ومناطق التغطية<br/>Service Area Config | ADR-006 | `backend_blueprint/` | `API-GEO-005` | `POST /api/v1/accounts/:id/service-areas` | **APPROVED V1** |
| `SCR-SEL-010` | إدارة فريق العمل (RBAC)<br/>Team Roles Manager | ADR-005 | `backend_blueprint/` | `API-ACC-005` | `GET /api/v1/accounts/:id/members` | **APPROVED V1** |
| `SCR-SEL-011` | مؤشر الحصص اليومية<br/>Daily Quota Dashboard | Daily Quota Rules | `backend_blueprint/` | `API-QTA-001` | `GET /api/v1/quotas/my` | **APPROVED V1** |
| `SCR-NOT-001` | مركز الإشعارات الموحد<br/>Global Notifications Center | ADR-011 | `lib/features/notifications/` | `API-NOT-001` | `GET /api/v1/notifications` | **APPROVED V1** |
| `SCR-SRC-001` | محرك البحث والاستكشاف<br/>Cross-Sector Explore | ADR-005 / Filter Arch | `lib/features/explore/` | `API-SRC-001` | `POST /api/v1/search` | **APPROVED V1** |
| `SCR-SRC-004` | اختيار المحافظة والمدينة<br/>Location Selector | ADR-006 | `lib/core/mock_data/` | `API-GEO-001` | `GET /api/v1/locations/governorates` | **APPROVED V1** |
| `SCR-LST-001` | اختيار قسم الإعلان<br/>Create Listing: Categories | ADR-003 | `backend_blueprint/` | `API-CAT-001` | `GET /api/v1/categories` | **APPROVED V1** |
| `SCR-LST-002` | نموذج الحقول الديناميكية<br/>Dynamic Listing Form | ADR-003 | `backend_blueprint/` | `API-CAT-002` | `GET /api/v1/categories/:id/fields` | **APPROVED V1** |
| `SCR-LST-003` | رفع وترتيب الصور (R2)<br/>Media Upload & Sort | Storage Architecture | `backend_blueprint/` | `API-MED-001` | `POST /api/v1/media/upload/presign` | **APPROVED V1** |
| `SCR-LST-004` | محدد الموقع ذو المستويين<br/>Two-Tier Location Picker | ADR-006 | `backend_blueprint/` | `API-GEO-002` | `GET /api/v1/locations/cities/:id/areas` | **APPROVED V1** |
| `SCR-LST-005` | مراجعة مسودة الإعلان<br/>Listing Draft Preview | ADR-007 | `backend_blueprint/` | `API-LST-001` | `POST /api/v1/listings` | **APPROVED V1** |
| `SCR-LST-006` | شاشة تأكيد المراجعة<br/>Submission Status Screen | ADR-007 | `backend_blueprint/` | `API-LST-002` | `POST /api/v1/listings/:id/submit` | **APPROVED V1** |
| `SCR-LST-007` | تعديل إعلان موجود<br/>Edit Existing Listing Form | ADR-007 | `backend_blueprint/` | `API-LST-003` | `PUT /api/v1/listings/:id` | **APPROVED V1** |
