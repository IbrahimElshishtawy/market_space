# معمارية تطبيقات Flutter: Deal One
## الإصدار المحدث المتوافق مع القرارات المعمارية المعتمدة (ADR-001 إلى ADR-012)

**الإصدار:** 2.0  
**التاريخ:** 1 نوفمبر 2026  
**الحالة:** معتمد رسمياً (Approved)  
**المراجع المرتبطة:** `Deal_One_Architecture_Decisions.md`، `Deal_One_Master_Architecture.md`، `Deal_One_System_Design.md`، `Deal_One_SRS.md`

---

**الإصدار:** 1.0
**التاريخ:** 1 نوفمبر 2026
**الحالة:** مسودة للمراجعة
**المراجع المرتبطة:** Deal_One_System_Design.md، Deal_One_SRS.md، Deal_One_Apps_Workflows.md، Deal_One_Filter_Architecture.md

---

## 1. الهدف من الوثيقة

تحديد المعمارية الأفضل لتطبيقين Flutter (تطبيق العميل وتطبيق التاجر) بيشاركوا نفس الـ backend ونفس مكونات التصميم، مع تحقيق:
- كود منظم وقابل للاختبار.
- مشاركة الكود المشترك بين التطبيقين بدون تكرار.
- أداء جيد على الأجهزة المتوسطة (شائعة في مصر).
- دعم كامل للعربية (RTL) والوضع الداكن.
- سهولة الصيانة والتوسع للمراحل الجاية.

---

## 2. القرارات المعمارية الكبرى

| القرار | الاختيار | السبب |
|---|---|---|
| **إطار العمل** | Flutter (أحدث نسخة stable) | كود واحد لـ Android وiOS، وأداء جيد |
| **هيكل المشروع** | Monorepo بـ Melos | مشاركة الكود بين التطبيقين بدون نسخ |
| **إدارة الحالة** | Riverpod (مع code generation) | قابل للاختبار، وآمن من الـ context، ومناسب للتطبيقات الكبيرة |
| **Navigation** | go_router | يدعم deep links، و redirects للصلاحيات، و RTL |
| **الشبكة** | Dio + Retrofit | interceptors للـ tokens والـ retry، وتوليد الكود من الـ API |
| **النماذج (Models)** | Freezed + json_serializable | immutability، ومقارنة بالقيمة، و copyWith |
| **معالجة الأخطاء** | Result type (Success / Failure) | أخطاء صريحة في الكود، من غير exceptions متناثرة |
| **التخزين المحلي** | Drift (SQLite) للبيانات، Secure Storage للـ tokens | Drift بيدعم queries مع type safety، والـ tokens لازم تتخزن بشكل آمن |
| **الإشعارات** | firebase_messaging + flutter_local_notifications | FCM للـ push، والـ local للإشعارات داخل التطبيق |
| **Real-time (الشات)** | socket_io_client أو web_socket_channel | WebSocket مع reconnect تلقائي |
| **الخرائط والموقع** | google_maps_flutter + geolocator | خرائط، وGPS، وإدارة الصلاحيات |
| **الصور** | cached_network_image + image_picker + flutter_image_compress | تحميل وتخزين مؤقت، واختيار وضغط قبل الرفع |
| **الترجمة والـ RTL** | flutter_localizations + intl + ARB | عربي أساسي، وإنجليزي لاحقاً |
| **Analytics والأعطال** | Firebase Crashlytics + Analytics (أو Sentry) | تتبع الأعطال والسلوك |
| **Feature flags** | Firebase Remote Config | تفعيل وتعطيل الميزات من غير تحديث التطبيق |

---

## 3. هيكل المشروع (Monorepo)

```
deal_one/
├── melos.yaml
├── apps/
│   ├── customer/                 # تطبيق العميل (المشتري والمستأجر)
│   │   ├── lib/
│   │   │   ├── main_dev.dart
│   │   │   ├── main_staging.dart
│   │   │   ├── main_prod.dart
│   │   │   ├── app.dart
│   │   │   └── features/         # الميزات الخاصة بالعميل فقط
│   │   ├── android/
│   │   ├── ios/
│   │   └── pubspec.yaml
│   └── merchant/                 # تطبيق التاجر
│       ├── lib/
│       │   ├── main_dev.dart
│       │   ├── main_staging.dart
│       │   ├── main_prod.dart
│       │   ├── app.dart
│       │   └── features/         # الميزات الخاصة بالتاجر فقط
│       └── pubspec.yaml
├── packages/
│   ├── core/                     # مشترك بين التطبيقين
│   │   ├── lib/
│   │   │   ├── config/           # env, flavors, constants
│   │   │   ├── network/          # dio, interceptors, retry, error mapping
│   │   │   ├── auth/             # session, tokens, guards
│   │   │   ├── storage/          # drift, secure storage, prefs
│   │   │   ├── realtime/         # websocket client
│   │   │   ├── notifications/    # FCM, local notifications
│   │   │   ├── location/         # GPS service, permissions
│   │   │   ├── turnstile/        # widget التحقق
│   │   │   ├── errors/           # Failure types, Result
│   │   │   ├── analytics/
│   │   │   └── utils/
│   │   └── pubspec.yaml
│   ├── domain_listings/          # منطق الإعلانات (مشترك)
│   │   ├── lib/
│   │   │   ├── models/           # Listing, Category, Field...
│   │   │   ├── repositories/     # interfaces
│   │   │   └── usecases/
│   │   └── pubspec.yaml
│   ├── domain_accounts/          # منطق الحسابات (مشترك)
│   ├── domain_chat/              # منطق الشات (مشترك)
│   ├── data/                     # تنفيذ الـ repositories (API + DB)
│   │   ├── lib/
│   │   │   ├── api/              # Retrofit clients
│   │   │   ├── dto/              # Data Transfer Objects
│   │   │   ├── mappers/          # DTO → Domain
│   │   │   └── repositories/     # implementations
│   │   └── pubspec.yaml
│   ├── design_system/            # مكونات الواجهة المشتركة
│   │   ├── lib/
│   │   │   ├── theme/            # ألوان، خطوط، spacing، dark mode
│   │   │   ├── components/       # أزرار، كروت، inputs، badges
│   │   │   ├── icons/
│   │   │   └── tokens/           # design tokens
│   │   └── pubspec.yaml
│   └── l10n/                     # ملفات الترجمة (ARB)
└── tools/                        # سكريبتات، CI helpers
```

### 3.1 ليه الفصل ده؟
- **`apps/`:** كل تطبيق له entry point ونقط بناء خاصة به، وميزاته الخاصة بيه بس.
- **`packages/core`:** البنية التحتية المشتركة (شبكة، تخزين، أخطاء). أي تغيير هنا يأثر على التطبيقين، فلازم يكون مستقر.
- **`packages/domain_*`:** المنطق المشترك بدون أي اعتماد على Flutter UI. ده بيخلي الاختبار أسهل والمنطق قابل لإعادة الاستخدام.
- **`packages/data`:** التنفيذ الفعلي للـ repositories (API وDB). مفصول عن الـ domain.
- **`packages/design_system`:** الألوان والخطوط والمكونات، عشان التطبيقين يبانوا متناسقين.

---

## 4. طبقات المعمارية (Layers)

كل ميزة (feature) مقسمة لثلاث طبقات، والاعتماد بيكون في اتجاه واحد من الخارج للداخل:

```
┌─────────────────────────────────────────────┐
│  Presentation (UI + State)                  │
│  - Screens, Widgets                         │
│  - Riverpod Notifiers / Providers           │
└──────────────────┬──────────────────────────┘
                   │ يعتمد على
┌──────────────────▼──────────────────────────┐
│  Domain (منطق خالص بدون Flutter)            │
│  - Models (Freezed)                         │
│  - Repository interfaces                    │
│  - Use cases                                │
└──────────────────┬──────────────────────────┘
                   │ يعتمد عليه
┌──────────────────▼──────────────────────────┐
│  Data (تنفيذ)                               │
│  - Retrofit API clients                     │
│  - DTOs + Mappers                           │
│  - Drift DAOs                               │
│  - Repository implementations               │
└─────────────────────────────────────────────┘
```

### 4.1 قواعد الاعتماد
- **الـ UI ما يعرفش الـ API ولا الـ DB.** بيتكلم مع الـ provider بس.
- **الـ domain ما يستوردش Flutter ولا Dio.** بيتعامل مع interfaces.
- **الـ data بينفذ الـ interfaces** ويحول الـ DTOs للـ models.
- **الـ core ما يعرفش أي feature.** لو احتاج معلومة من feature، يعرّف interface ويطلبها.

---

## 5. إدارة الحالة (Riverpod)

### 5.1 لماذا Riverpod
- بيشتغل بدون `BuildContext`، فالاختبار أسهل.
- الـ providers مُعرّفين على مستوى التطبيق، ومش مرتبطين بشجرة الـ widgets.
- بيدعم code generation (`@riverpod`)، فالكود أقصر وأأمن.
- بيدعم الـ dependency injection بشكل طبيعي.

### 5.2 أنواع الـ providers المستخدمة
| النوع | الاستخدام |
|---|---|
| `Provider` | خدمات ثابتة (repositories، API clients) |
| `FutureProvider` | بيانات بتتحمل مرة (تفاصيل الإعلان) |
| `AsyncNotifierProvider` | حالات معقدة بتتغير (قائمة الإعلانات مع pagination) |
| `StreamProvider` | بيانات real-time (الشات، الإشعارات) |
| `StateProvider` | حالة بسيطة (فلتر مختار حالياً) |

### 5.3 مثال: قائمة الإعلانات مع pagination

```dart
@riverpod
class ListingsFeed extends _$ListingsFeed {
  String? _cursor;
  bool _hasMore = true;

  @override
  Future<List<Listing>> build(SearchFilters filters) async {
    _cursor = null;
    _hasMore = true;
    return _fetch();
  }

  Future<List<Listing>> _fetch() async {
    final repo = ref.read(listingRepositoryProvider);
    final result = await repo.search(filters: filters, cursor: _cursor);
    return result.when(
      success: (page) {
        _cursor = page.nextCursor;
        _hasMore = page.nextCursor != null;
        return page.items;
      },
      failure: (f) => throw f,
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current);
    final next = await _fetch();
    state = AsyncValue.data([...current, ...next]);
  }
}
```

**ملاحظة:** الكود ده توضيحي، وتفاصيل الـ pagination (منع التكرار، إعادة المحاولة، حالة الخطأ أثناء التحميل) تتكتب بشكل كامل في التنفيذ.

---

## 6. نموذج البيانات في الـ Flutter

### 6.1 Models (Domain) بـ Freezed

```dart
@freezed
class Listing with _$Listing {
  const factory Listing({
    required String id,
    required String accountId,
    required String categoryId,
    required String title,
    required ListingKind kind,
    required ModerationStatus moderationStatus,
    required PublicationStatus publicationStatus,
    required AvailabilityStatus availabilityStatus,
    required ContactChannel contactChannel,
    num? price,
    required String currency,
    @Default(false) bool priceNegotiable,
    required ListingLocation location,
    @Default([]) List<String> imageUrls,
    @Default({}) Map<String, dynamic> attributes,
    DateTime? approvedAt,
    DateTime? expiresAt,
  }) = _Listing;
}

enum ModerationStatus { draft, pending, approved, rejected }
enum PublicationStatus { unpublished, published, hidden, archived }
enum AvailabilityStatus { available, reserved, sold, rented, outOfStock, discontinued }
enum ContactChannel { inApp, external }

@freezed
class ListingLocation with _$ListingLocation {
  const factory ListingLocation({
    required String areaId,
    required String cityName,
    required String areaName,
    required double displayLat,
    required double displayLng,
    // الإحداثيات الفعلية الدقيقة لا تتوفر إلا لصاحب الإعلان وفي سياق الإدارة
    double? physicalLat,
    double? physicalLng,
  }) = _ListingLocation;
}
```

### 6.2 Result type للأخطاء

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}

sealed class AppFailure {
  const AppFailure();
}
class NetworkFailure extends AppFailure { const NetworkFailure(); }
class UnauthorizedFailure extends AppFailure { const UnauthorizedFailure(); }
class QuotaExceededFailure extends AppFailure {
  final DateTime retryAfter;
  const QuotaExceededFailure(this.retryAfter);
}
class ValidationFailure extends AppFailure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(this.fieldErrors);
}
class ServerFailure extends AppFailure {
  final String? code;
  const ServerFailure([this.code]);
}
```

**الفايدة:** الـ UI بيتعامل مع كل حالة بشكل صريح، والـ `QuotaExceededFailure` بيتعرض برسالة واضحة بوقت التجديد (من الـ SRS).

---

## 7. الشبكة (Networking)

### 7.1 الطبقات
```
Retrofit Client
   ↓
Dio (با interceptors)
   ├── AuthInterceptor      ← يضيف الـ access token، ويجدد عند 401
   ├── RetryInterceptor     ← يعيد المحاولة للأخطاء المؤقتة (503، timeout)
   ├── LoggingInterceptor   ← logs في dev فقط، مش في prod
   ├── TurnstileInterceptor ← يضيف الـ token للطلبات المحمية
   └── ErrorMapper          ← يحول الأخطاء لـ AppFailure
```

### 7.2 Refresh token بدون تكرار
- لو أكتر من طلب رجع 401 في نفس الوقت، الـ AuthInterceptor يعمل **refresh واحد** بس، والباقي يستنى نتيجته.
- لو الـ refresh فشل، الجلسة تتقفل، والمستخدم يتوجه لشاشة الدخول.

### 7.3 Turnstile في Flutter
**ملاحظة مهمة:** Cloudflare Turnstile ما عندوش SDK رسمي لـ Flutter، فالحل العملي:
- يتعرض الـ widget داخل WebView (`webview_flutter` أو `flutter_inappwebview`) بصفحة HTML بسيطة بتحمل Turnstile.
- الـ token يرجع للـ Dart عن طريق JavaScript channel.
- الـ token بيتبعت للـ backend مع الطلب المحمي.

**تنبيه:** ده حل شغال، لكن لازم اختبار على أجهزة أندرويد وiOS مختلفة، وتتابع تحديثات Turnstile لأن الـ WebView بيتأثر بيها.

### 7.4 Error mapping
كل خطأ من الـ backend بيتحول لـ `AppFailure` في الـ `ErrorMapper`، والـ UI ما يشوفش HTTP codes خام.

---

## 8. الـ Real-time (الشات)

### 8.1 الاتصال
- WebSocket واحد للتطبيق، مش واحد لكل محادثة.
- الـ connection بيتقفل لما التطبيق يروح للخلفية، ويرجع لما يرجع للمقدمة (AppLifecycleState).
- Reconnect بـ exponential backoff (1 ثانية، 2، 4، 8، لحد 30 ثانية).

### 8.2 الـ Outbox للرسائل
الرسالة بتتخزن محلياً في Drift بحالة `pending` قبل ما تتبعت:
1. المستخدم يبعت رسالة → تتخزن محلياً وتظهر فوراً في الشاشة.
2. الـ worker يبعتها للسيرفر.
3. لو نجحت، الحالة تتحدث لـ `sent`.
4. لو فشلت، تفضل `pending` وتتبعت تاني لما الاتصال يرجع.

### 8.3 الـ Stream
```dart
@riverpod
Stream<Message> conversationMessages(ConversationMessagesRef ref, String conversationId) {
  final socket = ref.watch(chatSocketProvider);
  return socket.messagesFor(conversationId);
}
```

---

## 9. التخزين المحلي

| البيانات | المكان | السبب |
|---|---|---|
| الـ access & refresh tokens | Secure Storage (Keychain / Keystore) | أمان |
| بيانات المستخدم الأساسية | Drift | استعلامات سريعة |
| الإعلانات المحفوظة (المفضلة) | Drift | يشتغل offline |
| آخر نتايج بحث | Drift (cache) | عرض سريع عند فتح التطبيق |
| الرسايل (والـ outbox) | Drift | offline وإعادة الإرسال |
| إعدادات المستخدم (لغة، ثيم) | SharedPreferences | بيانات بسيطة |
| الـ cache للصور | cached_network_image (disk cache) | تحميل سريع |

### 9.1 سياسة الـ cache
- الإعلانات بتتخزن لمدة 10 دقايق، وبعدها بتتحدث في الخلفية.
- البيانات الحساسة (الـ tokens) ما تتخزنش في Drift أبداً.
- عند تسجيل الخروج، كل البيانات الشخصية تتمسح.

---

## 10. الـ Navigation (go_router)

### 10.1 المسارات
```
/                     → الرئيسية (Customer) أو لوحة التاجر (Merchant)
/search               → البحث
/listings/:id         → تفاصيل الإعلان
/favorites            → المفضلة
/chats                → المحادثات
/chats/:id            → محادثة
/account              → حسابي
/account/edit         → تعديل الملف
/merchant/listings/new → إضافة إعلان (Merchant)
/auth/login           → تسجيل الدخول
/auth/otp             → التحقق من OTP
```

### 10.2 Guards
- المسارات المحمية (مثل `/chats`) بتتحول لتسجيل الدخول لو الجلسة مش موجودة.
- بعد تسجيل الدخول، المستخدم يرجع للمسار اللي كان عايزه (`redirect` parameter).
- مسارات التاجر بتتحمي بحساب تجاري نشط.

### 10.3 Deep links
- `dealone://listings/:id`: فتح إعلان من رابط خارجي.
- Universal Links (iOS) وApp Links (Android) لمشاركة الإعلانات.
- لو التطبيق مش متثبت، الرابط يفتح صفحة ويب عامة للإعلان.

---

## 11. الـ Design System والـ Theming

### 11.1 Design Tokens
- الألوان، المسافات، أحجام الخطوط، الـ radius، كلها في ملف tokens واحد.
- الـ tokens بتتحول لـ `ThemeData` للوضع الفاتح والداكن.
- أي تغيير في الـ tokens بيأثر على التطبيقين فوراً.

### 11.2 الـ RTL
- التطبيق بيبدأ بـ `Directionality` عربي.
- نستخدم `EdgeInsetsDirectional` و`AlignmentDirectional` بدل `left` و`right` عشان الاتجاه يتعكس تلقائياً.
- الأيقونات اللي بتحمل اتجاه (سهم رجوع) بتتعكس في RTL.
- الأرقام: نعرضها بالأرقام الإنجليزية أو العربية حسب إعداد المستخدم.

### 11.3 الخطوط
- خط عربي واضح (مثل Cairo أو Tajawal) للعناوين والنصوص.
- الخط بيتحمل كـ asset، مش من الإنترنت، عشان يشتغل offline.

### 11.4 الوضع الداكن
- الألوان بتتعرف كـ semantic tokens (`surface`, `onSurface`, `primary`)، مش ألوان ثابتة.
- كل شاشة تتختبر في الوضعين.

---

## 12. الإشعارات

### 12.1 الأنواع
| النوع | الحالة | العرض |
|---|---|---|
| Push (FCM) والتطبيق مقفول | الإشعار يظهر في الـ system tray | عنوان ونص |
| Push والتطبيق مفتوح | local notification أو banner داخلي | حسب النوع |
| Data-only | يتعالج في الخلفية بدون عرض | تحديث البيانات |

### 12.2 التعامل مع الضغط
- الإشعار بيحمل `route` (مثل `/chats/123`).
- عند الضغط، go_router يوجه للمسار المناسب بعد التحقق من الجلسة.

### 12.3 صلاحيات الإشعارات
- نطلب الإذن بعد ما المستخدم يعمل أول إجراء مفيد (مش عند فتح التطبيق)، عشان نزود نسبة الموافقة.
- لو رفض، نعرض شرح مختصر وزر "فعّل من الإعدادات".

---

## 13. الموقع والخرائط

### 13.1 الصلاحيات
- طلب صلاحية الموقع بعد ما المستخدم يختار "قريب مني" أو يفتح الخريطة.
- لو رفض، الفلترة بالمنطقة بس (حسب SRS 3.7).
- الصلاحية "عند استخدام التطبيق" (While in use) بس، مش دايماً.

### 13.2 الخرائط
- خريطة تعرض الإعلانات كـ markers، مع clustering لما تكتر.
- الإعلانات بتظهر بموقعها التقريبي (من الـ backend، مش الدقيق).
- Markers مع thumbnails مضغوطة، عشان الأداء.

---

## 14. الصور

### 14.1 رفع الصور (تاجر)
1. اختيار الصور من الـ gallery أو الكاميرا.
2. ضغط وتصغير على الجهاز (الحد الأقصى 1600px، جودة 80%).
3. إزالة الـ EXIF (الموقع).
4. رفع مباشر لـ presigned URL من الـ backend.
5. عرض progress لكل صورة.

**ملاحظة:** الضغط على الجهاز بيقلل الـ bandwidth ويسرّع الرفع، وده مهم في الشبكات الضعيفة.

### 14.2 عرض الصور (عميل)
- Thumbnails صغيرة في القوائم، والصورة الكاملة في التفاصيل.
- Lazy loading وplaceholder أثناء التحميل.
- Cache على القرص.

---

## 15. الأداء

### 15.1 قواعد عامة
- استخدام `const` للـ widgets الثابتة.
- `ListView.builder` و`SliverList` للقوائم الطويلة، مش `Column` مع `children` كبيرة.
- تقليل إعادة البناء بـ `select` في Riverpod (بيراقب جزء من الـ state بس).
- تجنب العمليات الثقيلة في الـ UI thread، ونقلها لـ `compute` أو Isolate.

### 15.2 الأجهزة المتوسطة
- الاختبار على جهاز أندرويد متوسط (4GB RAM) مش بس الأجهزة الحديثة.
- قياس الـ frame rate (60fps كهدف)، و الـ jank في الشاشات الثقيلة (القوائم، الخريطة).
- تقليل حجم الـ APK/AAB (tree shaking، split per ABI).

### 15.3 بدء التشغيل
- Splash خفيف، وتحميل الـ config والـ auth بشكل متوازي.
- الشاشة الرئيسية تظهر بسرعة مع skeleton، والبيانات تتحمل بعدين.

---

## 16. الاختبار

| النوع | الأداة | ما الذي يُختبر |
|---|---|---|
| **Unit** | `test` + `mocktail` | منطق الـ domain، الـ use cases، الـ mappers |
| **Repository** | `test` + mock API | تحويل الـ DTOs، معالجة الأخطاء |
| **Widget** | `flutter_test` | شاشات مفردة، حالات (loading، error، empty) |
| **Golden** | `golden_toolkit` أو `alchemist` | الشكل البصري للمكونات، وضعي فاتح وداكن |
| **Integration** | `patrol` أو `integration_test` | تدفقات كاملة (تسجيل، نشر إعلان) |

### 16.1 نسبة التغطية
- 70% على الأقل للـ domain والـ data (من SRS NFR-MNT-001).
- Widget tests للشاشات الحرجة (تسجيل، إنشاء إعلان، الشات).

### 16.2 اختبار الـ RTL
- Golden tests بـ `Directionality.rtl` لكل شاشة رئيسية.

---

## 17. الـ Flavors والبيئات

### 17.1 البيئات
| البيئة | الاستخدام | الـ API |
|---|---|---|
| dev | التطوير المحلي | API تجريبي |
| staging | الاختبار قبل الإطلاق | API staging |
| prod | الإنتاج | API الإنتاج |

### 17.2 الـ Flavors
- كل تطبيق عنده ثلاث flavors (dev، staging، prod).
- الـ flavor بيحدد: الـ base URL، الـ Firebase config، اسم التطبيق، الـ bundle ID.
- **ممنوع** وضع أي secret في الكود. الـ keys الحساسة بتتجاب من الـ backend أو من Remote Config.

### 17.3 أسماء التطبيقات
- تطبيق العميل: `Deal One` (production) و `Deal One Dev` (dev).
- تطبيق التاجر: `Deal One Business` (production) و `Deal One Business Dev` (dev).

---

## 18. الأمان

### 18.1 تخزين البيانات
- Tokens في Keychain (iOS) وKeystore (Android) عبر Secure Storage.
- لا توجد بيانات حساسة في الـ SharedPreferences أو اللوجز.

### 18.2 الاتصال
- HTTPS بس.
- Certificate pinning لـ API الإنتاج (مع خطة لتحديث الـ pins قبل انتهاء الشهادات).

### 18.3 حماية الكود
- Obfuscation عند بناء الـ release (`--obfuscate --split-debug-info`).
- تقليل الـ logs في الإنتاج.

### 18.4 حماية من الأجهزة المعدلة
- Root/jailbreak detection للعمليات الحساسة (مثل إدارة مستندات التوثيق والعمليات الإدارية)، مع تنبيه للدعم، من غير ما نمنع الاستخدام العادي.

### 18.5 الخصوصية
- طلب الصلاحيات بشرح واضح.
- Analytics بدون بيانات شخصية (رقم، إيميل، إحداثيات دقيقة).

---

## 19. Analytics والأعطال

### 19.1 الأعطال
- Crashlytics للـ crashes والـ non-fatal errors.
- كل exception بيتسجل مع السياق (الشاشة، الـ user ID المشفر، الإصدار).

### 19.2 Analytics
الأحداث الأساسية:
- `listing_viewed`، `listing_created`، `listing_submitted`
- `search_performed` (مع عدد الفلاتر، بدون القيم)
- `chat_started`، `message_sent`
- `contact_revealed` (واتساب أو اتصال)
- `onboarding_completed`

**مهم:** مش بنسجل محتوى الرسايل أو الأرقام أو الإحداثيات الدقيقة في الـ analytics.

---

## 20. الـ CI/CD والنشر

### 20.1 الخط
```
Commit → Lint + Format check → Unit & Widget tests → Build (dev)
  → Merge to main → Build (staging) → Integration tests → Deploy internal testing
  → Tag release → Build (prod) → Deploy to Play Console / App Store Connect
```

### 20.2 الأدوات
- **GitHub Actions** أو **Codemagic** للـ CI (Codemagic أسهل مع Flutter وiOS).
- **Fastlane** لتوقيع الـ builds ورفعها.
- **Firebase App Distribution** للـ beta testing الداخلي.

### 20.3 الإصدارات
- Semantic versioning (`1.2.3+45`).
- Force update: لو فيه إصدار قديم فيه مشكلة أمنية، الـ backend يرجع `minimum_version` وتطبيق بيوجه المستخدم للتحديث.
- Remote Config بيتحكم في الـ feature flags بدون تحديث.

### 20.4 مراجعة المتاجر
- Google Play: مراجعة سريعة نسبياً، لكن محتاج شرح لصلاحيات الموقع والإشعارات.
- App Store: مراجعة أطول، وشروط صارمة للـ user-generated content (يحتاج زر إبلاغ وحظر، وهو موجود في الـ SRS).

---

## 21. قابلية الصيانة والجودة

### 21.1 قواعد الكود
- `very_good_analysis` أو `flutter_lints` مع قواعد صارمة.
- `dart format` في الـ CI.
- Code review لكل PR.
- ممنوع `dynamic` إلا لو مبرر.
- Null safety كامل.

### 21.2 التوثيق
- كل package عنده README بيشرح مسؤوليته.
- الـ public APIs في الـ packages موثقة بـ dartdoc.

### 21.3 الـ Error boundaries
- `FlutterError.onError` و`PlatformDispatcher.instance.onError` لالتقاط كل الأخطاء.
- شاشة خطأ عامة بدل شاشة حمراء في الإنتاج.

---

## 22. التوطين (Localization)

- ملفات ARB لكل لغة (`app_ar.arb`، `app_en.arb` لاحقاً).
- كل النصوص في الـ ARB، ممنوع hardcoded strings في الـ UI.
- الأرقام والتواريخ والعملة بتتنسق حسب اللغة (`intl`).
- التاريخ والوقت بتوقيت القاهرة للعرض، والـ backend بيبعت UTC.

---

## 23. ملخص الحزم (Packages) المقترحة

| الفئة | الحزمة | الغرض |
|---|---|---|
| State | `flutter_riverpod`, `riverpod_annotation` | إدارة الحالة |
| Routing | `go_router` | التنقل |
| Models | `freezed_annotation`, `json_annotation` | النماذج |
| Network | `dio`, `retrofit` | الشبكة |
| Storage | `drift`, `flutter_secure_storage`, `shared_preferences` | التخزين |
| Real-time | `socket_io_client` أو `web_socket_channel` | الشات |
| Firebase | `firebase_core`, `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics`, `firebase_remote_config` | الخدمات |
| Notifications | `flutter_local_notifications` | إشعارات محلية |
| Maps & Location | `google_maps_flutter`, `geolocator` | الخرائط والموقع |
| Images | `cached_network_image`, `image_picker`, `flutter_image_compress` | الصور |
| WebView | `webview_flutter` | Turnstile |
| i18n | `flutter_localizations`, `intl` | الترجمة |
| Testing | `mocktail`, `patrol`, `alchemist` | الاختبار |
| Lints | `very_good_analysis` | جودة الكود |
| Monorepo | `melos` | إدارة الـ packages |

**ملاحظة:** الإصدارات بتتحدد وقت التنفيذ على أحدث stable، وبتتراجع بانتظام.

---

## 24. خطة التنفيذ المقترحة

| المرحلة | المحتوى |
|---|---|
| **1. الأساس** | Monorepo، packages/core، design system، flavors، go_router، الـ auth |
| **2. العميل (MVP)** | الرئيسية، البحث، تفاصيل الإعلان، المفضلة، التواصل |
| **3. التاجر (MVP)** | تسجيل الحساب التجاري، إضافة الإعلان، الصور، المحادثات |
| **4. الشات الفوري** | WebSocket، الـ outbox، الإشعارات |
| **5. الخرائط والـ GPS** | الفلترة بالقرب، الخريطة |
| **6. الأداء والاختبار** | Golden tests، integration، اختبار أجهزة متوسطة |
| **7. الإطلاق** | Beta، مراجعة المتاجر، Crashlytics |

---

## 25. قرارات محتاجة ردك

1. **مكتبة Riverpod:** موافق عليها كاختيار أساسي؟ (التوصية: نعم.)
2. **الـ Monorepo:** نبدأ بـ Melos من الأول، ولا نبدأ بمشروعين منفصلين ونحول بعدين؟ (التوصية: Melos من الأول، لأن الكود المشترك كبير.)
3. **الشات:** Socket.IO ولا WebSocket عادي؟ (التوصية: Socket.IO لو الـ backend بيدعمه، لأنه بيحل reconnect والـ rooms تلقائياً.)
4. **Turnstile في Flutter:** موافق على الـ WebView كحل مؤقت، ولا نبحث عن حل أفضل؟
5. **Firebase:** موافق على الاعتماد على Firebase للإشعارات وCrashlytics وRemote Config؟
6. **التطبيقين في Store منفصلين:** ولا تطبيق واحد بتبديل وضع؟ (مرتبط بالسؤال في ورك فلو التطبيقات.)
7. **خط عربي:** Cairo ولا Tajawal ولا خط تاني؟

---

## سجل التعديلات

| الإصدار | التاريخ | الوصف |
|---|---|---|
| 1.0 | 1 نوفمبر 2026 | المسودة الأولى لمعمارية تطبيقات Flutter |
