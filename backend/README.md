# Market Space Backend — دليل المعمارية والتطوير

> **المعمارية الأساسية:** Modular Monolith مبني باستخدام NestJS 10 (TypeScript) + Fastify + PostgreSQL 16 (Prisma ORM) + Redis 7 + BullMQ.

هذا المشروع مصمم لخدمة منصة الإعلانات المبوبة في مصر (**Market Space - سوق سبيس**)، ومبني وفق أعلى معايير هندسة البرمجيات بحيث يكون **كل جزء قابلاً للتطوير، الفهم، والتعديل المستقل** دون إحداث فوضى أو اعتماديات متداخلة.

---

## 🏛️ 1. المبادئ المعمارية (Architectural Principles)

1. **Modular Monolith (أحادية معيارية):**
   - كل مجال عمل (Domain) معزول داخل مجلد مستقل في `src/modules/` يحتوي على الـ Controller, Service, DTOs, Guards, Tests الخاصة به.
   - سهولة التحويل مستقبلاً إلى Microservices إذا استدعت الحاجة، مع بقاء سهولة وسرعة الصيانة والتطوير حالياً.
2. **عزل البنية التحتية في `src/core/` (Clean Infrastructure):**
   - الاتصال بقاعدة البيانات، الكاش (Redis)، معالجة الأخطاء (RFC 7807)، والـ Interceptors موحدة ومعزولة في مجلد `core/`.
3. **المرونة وتجنب حجب الخدمات الخارجية (Decoupled Adapters):**
   - خدمات مثل رفع الوسائط (S3/R2)، بوابات الدفع (Paymob)، مزودي الرسائل (SMS OTP)، والفيديو (Cloudflare Stream) مبرمجة بطريقة تقبل استبدال المزود دون المساس بمنطق العمل الداخلي.
4. **دعم التراجع الآمن والمرونة (Resilience & Fallbacks):**
   - تم تصميم `RedisService` ليعمل مع Memory Fallback تلقائياً أثناء التطوير أو الاختبار إذا كان خادم Redis غير متصل.
5. **معالجة المهام في الخلفية (Background Workers):**
   - معالجة انتهاء صلاحية الإعلانات، تنظيف الوسائط المهملة، إعادة تسوية المدفوعات المعلقة، وإرسال إشعارات الـ Push تتم بشكل منفصل داخل `src/workers/`.

---

## 📂 2. الهيكل التنظيمي للمشروع (Directory Structure)

```
backend/
├── src/
│   ├── main.ts                         # نقطة انطلاق التطبيق (Fastify, CORS, Helmet, Swagger, Pipes)
│   ├── app.module.ts                   # الموديول الجذري لربط جميع الوحدات والخدمات
│   ├── core/                           # الخدمات والبنية التحتية المشتركة
│   │   ├── config/                     # التحقق من المتغيرات البيئية عبر Zod (env.config.ts)
│   │   ├── database/                   # خدمة PrismaService وإدارة اتصالات PostgreSQL
│   │   ├── redis/                      # خدمة الـ Redis والكاش، والعدادات اللحظية، ومحدد المعدل
│   │   ├── errors/                     # فلتر الأخطاء الموحد (RFC 7807 Error Response)
│   │   ├── guards/                     # حراس الحماية (RolesGuard, RateLimitGuard, JwtAuthGuard)
│   │   ├── interceptors/               # تسجيل الطلبات وتنسيق مخرجات الـ API (Logging, Transform)
│   │   └── health/                     # نقاط فحص صحة النظام (/health/live, /health/ready)
│   ├── modules/                        # مجالات الأعمال الوظيفية (Domain Modules)
│   │   ├── auth/                       # تسجيل الدخول برقم الهاتف ورمز OTP والتحقق بـ JWT
│   │   ├── users/                      # الملف الشخصي وتفضيلات المستخدمين
│   │   ├── categories/                 # شجرة الأقسام والحقول الديناميكية (Dynamic Specs)
│   │   ├── listings/                   # إدارة الإعلانات ودورة حياتها (State Machine)
│   │   ├── media/                      # توليد روابط الرفع المؤقتة (Presigned URLs R2/S3)
│   │   ├── search/                     # محرك البحث باللغة العربية والفلترة (Trigram Matching)
│   │   ├── chat/                       # المحادثات والتواصل ورسائل المشترين
│   │   ├── video/                      # تكامل فيديوهات ريلز 30 ثانية (Cloudflare Stream)
│   │   ├── payments/                   # تكامل المدفوعات المصرية (Paymob Webhooks & HMAC)
│   │   ├── moderation/                 # طابور المراجعة والبلاغات وسجلات التدقيق (Audit Logs)
│   │   └── notifications/              # إرسال إشعارات الهواتف المحمولة (FCM Push)
│   └── workers/                        # معالجات المهام المجدولة والخلفية
│       ├── worker.module.ts
│       ├── worker.service.ts
│       ├── listing-expiry.processor.ts        # أرشفة الإعلانات المنتهية تلقائياً
│       ├── media-cleanup.processor.ts         # حذف روابط الصور المتروكة
│       ├── payment-reconciliation.processor.ts# فحص المدفوعات المعلقة
│       └── notification.processor.ts          # طابور إرسال الإشعارات
├── prisma/
│   ├── schema.prisma                   # مخطط قاعدة البيانات (PostgreSQL)
│   └── seeds/seed.ts                   # بذر بيانات المحافظات والمدن المصرية والأقسام
└── test/                               # اختبارات الوحدة والتكامل
```

---

## 🛠️ 3. كيفية التعديل والتطوير في أجزاء النظام

### أ) إضافة قسم جديد أو حقل ديناميكي:
- التعديل يتم برمجياً أو عبر لوحة الإدارة من خلال `POST /api/v1/admin/categories` و `PUT /api/v1/admin/categories/{id}/fields`.
- تدعم الحقول الأنواع: `TEXT`, `NUMBER`, `SELECT`, `MULTI_SELECT`, `BOOLEAN`.
- تُحفظ قيم الحقول الديناميكية داخل حقل `attributes` بصيغة `JSONB` عالي الأداء مع الحفاظ على التوافقية العكسية.

### ب) تعديل آلية تسجيل الدخول (SMS OTP):
- المنطق موجود في [auth.service.ts](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend/src/modules/auth/auth.service.ts).
- يتم التحقق من أرقام الهواتف المصرية بنمط `+2010...`, `+2011...`, `+2012...`, `+2015...`.
- يتم عمل تدرج للحماية ومنع الإغراق (Sliding-window: حد أقصى 3 رسائل كل 15 دقيقة).
- للتبديل بين المحاكاة ومزود SMS حقيقي (مثل SMS Misr أو Infobip)، عدّل الدالة `sendOtp` لحقن واجهة الـ Gateway.

### ج) إضافة حارس صلاحيات أو تحديد معدل (Rate Limiting):
- استخدم الديكوريتور `@RateLimit(limit, ttlSeconds)` متبوعاً بـ `@UseGuards(RateLimitGuard)` على أي مسار لحمايته عبر Redis.

### د) إدارة دورة حياة الإعلانات (Listings State Machine):
- المعيارية محددة بوضوح في [listings-state-machine.ts](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend/src/modules/listings/listings-state-machine.ts).
- الحالات: `DRAFT` -> `PENDING_REVIEW` -> `PUBLISHED` -> `EXPIRED` -> `SOLD` -> `ARCHIVED`.

---

## 🚀 4. التشغيل والاختبار محلياً

```bash
# 1. تثبيت الحزم
npm install

# 2. توليد عميل Prisma وتطبيق المخطط
npm run prisma:generate

# 3. بذر بيانات مصر الأولية (27 محافظة وأقسام السوق)
npm run prisma:seed

# 4. تشغيل الاختبارات الشاملة (11 جنائب اختبار - 38 فحص وحدة)
npm test

# 5. تشغيل خادم التطوير
npm run start:dev
```

- رابط توثيق الـ API التفاعلي (Swagger UI): `http://localhost:3000/api/docs`
- فحص صحة النظام (Health Check): `http://localhost:3000/health/live`
