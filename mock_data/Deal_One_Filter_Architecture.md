# معمارية الفلاتر والبحث: Deal One
## الإصدار المحدث المتوافق مع القرارات المعمارية المعتمدة (ADR-001 إلى ADR-012)

**الإصدار:** 2.0  
**التاريخ:** 1 نوفمبر 2026  
**الحالة:** معتمد رسمياً (Approved)  
**المراجع المرتبطة:** `Deal_One_Architecture_Decisions.md`، `Deal_One_Master_Architecture.md`، `Deal_One_System_Design.md`

---

**الإصدار:** 1.0
**التاريخ:** 1 نوفمبر 2026
**الحالة:** مسودة للمراجعة
**المراجع المرتبطة:** Deal_One_System_Design.md، Deal_One_SRS.md (قسم 3.7)، Deal_One_Apps_Workflows.md

---

## 1. الهدف

المطلوب نظام بحث وفلترة بيتحمل:
- عشرات الفلاتر المختلفة، وبعضها بيتغير حسب القسم (غرف لو عقار، ماركة وموديل لو عربية، مقاس لو ملابس).
- بحث بالكلمات بالعربي، مع تحمل الأخطاء الإملائية واللهجة المصرية.
- بحث جغرافي بنصف قطر، وترتيب بالمسافة.
- نتايج سريعة (أقل من 500ms في المتوسط حسب الـ SRS)، حتى مع ملايين الإعلانات.
- فلترة الإعلانات الغير مسموح بيها (غير معتمدة، منتهية، مباعة، مخفية، من حسابات موقوفة) تتم **دايماً** على مستوى الـ index، مش على مستوى التطبيق.
- تنبيهات للبحث المحفوظ.

---

## 2. الاختيار المعماري: مراحل

القرار الأهم: **هل نستخدم PostgreSQL بس، ولا محرك بحث متخصص (OpenSearch أو Meilisearch)؟**

الإجابة الأفضل: **نبدأ بـ PostgreSQL، ونضيف محرك بحث متخصص لما الحجم أو تعقيد الفلاتر يوصل لنقطة معينة.** السبب إن المحرك المتخصص بيضيف تعقيد تشغيلي (sync، مراقبة، تكلفة)، والـ MVP مش محتاجه بالضرورة.

### 2.1 المرحلة الأولى (MVP): PostgreSQL + PostGIS + pg_trgm

**مناسب لحد حوالي 500 ألف إعلان منشور، وعدد فلاتر متوسط.**

| المكون | الاستخدام |
|---|---|
| **PostgreSQL** | المصدر الرئيسي للبيانات والبحث |
| **PostGIS** | البحث الجغرافي بنصف قطر والترتيب بالمسافة |
| **pg_trgm** | البحث المرن (تحمل الأخطاء الإملائية الخفيفة) |
| **tsvector مع config عربي مخصص** | البحث بالكلمات (full-text) |
| **JSONB + GIN** | الحقول الخاصة بكل قسم |
| **Redis** | cache لنتايج الاستعلامات الشائعة، وعدد الإعلانات في الفلاتر |

**حدود المرحلة الأولى:**
- الـ facets (عدد النتايج لكل فلتر) بتبقى بطيئة لو الاستعلام واسع.
- التحمل الإملائي محدود.
- البحث في الحقول الخاصة بالقسم بيحتاج index مخصص لكل قسم.

### 2.2 المرحلة الثانية: OpenSearch أو Elasticsearch

**مناسب لما:** الإعلانات تتعدى 500 ألف، أو الـ facets بقت بطيئة، أو التحمل الإملائي والعربي المتقدم ضروري.

| المكون | الاستخدام |
|---|---|
| **OpenSearch** (أو Elasticsearch) | محرك البحث والفلترة والـ facets |
| **Outbox pattern + worker** | نقل التغييرات من PostgreSQL للمحرك |
| **PostgreSQL** | يفضل المصدر الرئيسي للبيانات |
| **Redis** | cache للنتايج والـ facets الشائعة |

### 2.3 بديل أبسط: Meilisearch أو Typesense

**مناسب لو:** الفريق صغير ومش عايز تعقيد OpenSearch. المحركين دول أبسط في التشغيل، ويدعموا الـ typo tolerance و facets و geo بشكل جيد، لكن عددهم في السوق المصري والعربي أقل في الخبرة المتاحة، وده لازم يتوزن.

### 2.4 مقارنة سريعة

| المعيار | PostgreSQL فقط | OpenSearch | Meilisearch / Typesense |
|---|---|---|---|
| تعقيد التشغيل | منخفض | عالي | منخفض إلى متوسط |
| السرعة مع ملايين السجلات | متوسطة | عالية جداً | عالية |
| الـ facets المعقدة | محدودة | ممتازة | جيدة |
| التحمل الإملائي | محدود | ممتاز | ممتاز |
| البحث الجغرافي | ممتاز (PostGIS) | جيد | جيد |
| الاتساق مع المصدر | تلقائي | يحتاج sync | يحتاج sync |
| التكلفة | منخفضة | متوسطة إلى عالية | منخفضة إلى متوسطة |

**التوصية:** PostgreSQL في البداية، مع تصميم الـ schema بحيث يتنقل لـ OpenSearch بسهولة (الـ index document مستقل عن الـ DB).

---

## 3. نموذج البيانات للبحث

### 3.1 مشكلة الـ EAV
الـ `listing_values` بجدول EAV (Entity-Attribute-Value) في الـ SRS مرن، لكنه **بطيء للفلترة** لو فيه فلاتر كتير على حقول مختلفة، لأن كل فلتر يتحول لـ JOIN.

### 3.2 الحل المقترح: JSONB في PostgreSQL

**أضف عمود `attributes` (JSONB) في جدول `listings`:**

```json
{
  "rooms": 3,
  "area_sqm": 140,
  "floor": 4,
  "furnished": true,
  "brand": "Toyota",
  "model": "Corolla",
  "year": 2019,
  "mileage_km": 85000,
  "size": "L",
  "color": "أزرق"
}
```

**Index مقترح:**
```sql
CREATE INDEX idx_listings_attrs ON listings USING GIN (attributes jsonb_path_ops);
```

**الاستعلام:**
```sql
SELECT l.* FROM listings l
JOIN accounts a ON l.account_id = a.id
WHERE l.category_id = $1
  AND l.moderation_status = 'approved'
  AND l.publication_status = 'published'
  AND l.availability_status = 'available'
  AND a.verification_status = 'approved'
  AND a.is_active = true
  AND l.attributes @> '{"rooms": 3, "furnished": true}'
  AND (l.attributes->>'area_sqm')::int BETWEEN $2 AND $3;
```

**ملاحظة:** الـ GIN بيدعم `@>` (containment) بكفاءة، لكن الـ range (`BETWEEN`) على الأرقام بيحتاج expression index لكل حقل رقمي مهم:
```sql
CREATE INDEX idx_listings_area ON listings (((attributes->>'area_sqm')::int));
```

**الاحتفاظ بـ `listing_values` كجدول منفصل** للتقارير والتحقق، لكن الفلترة تتم من `attributes`.

### 3.3 تحديد الحقول القابلة للفلترة
من `category_fields` في الـ SRS، أضف عمود:
- `is_filterable` (boolean): الحقل يظهر كفلتر.
- `is_sortable` (boolean): الحقل يصلح للترتيب.
- `filter_type`: `range`, `exact`, `multi_select`, `boolean`.
- `filter_order`: ترتيب ظهور الفلتر في الواجهة.

ده بيخلي الواجهة **dynamic**: كل قسم يعرض فلاتره حسب إعداداته من الأدمن، من غير تعديل كود التطبيق.

---

## 4. تصميم الـ Index (في OpenSearch لو اتعمل)

### 4.1 شكل الـ document

```json
{
  "id": "uuid",
  "moderation_status": "approved",
  "publication_status": "published",
  "availability_status": "available",
  "account": { "id": "uuid", "type": "company", "verified": true },
  "category_path": ["عقارات", "شقق", "للإيجار"],
  "category_id": "uuid",
  "listing_kind": "rent",
  "title": "شقة 3 غرف للإيجار في مدينة نصر",
  "description": "...",
  "price": 8000,
  "currency": "EGP",
  "price_negotiable": false,
  "area": { "id": "uuid", "name": "مدينة نصر", "city": "القاهرة" },
  "location": { "lat": 30.0611, "lon": 31.3328 },
  "location_precision": "approximate",
  "contact_channel": "in_app",
  "attributes": {
    "rooms": 3,
    "area_sqm": 140,
    "furnished": true
  },
  "media_count": 6,
  "primary_image_url": "https://...",
  "created_at": "2026-11-01T10:00:00Z",
  "approved_at": "2026-11-01T11:00:00Z",
  "expires_at": "2026-12-01T11:00:00Z",
  "view_count_7d": 340,
  "ranking_boost": 0
}
```

### 4.2 الـ Mapping
- `title` و`description`: نص عربي بـ analyzer مخصص (انظر القسم 5).
- `category_path`: keyword، عشان الفلترة بالشجرة (تفيد الفلترة بالأب والأبناء).
- `price`: `scaled_float` أو `double`.
- `location`: `geo_point`.
- `attributes`: **dynamic templates**، مع تحديد النوع لكل حقل معروف (`rooms` → integer، `brand` → keyword).
- `moderation_status`, `publication_status`, `availability_status`, `contact_channel`, `listing_kind`: `keyword`.
- `expires_at`, `approved_at`, `created_at`: `date`.

### 4.3 الفلتر الثابت (لا يتجاوزه أي استعلام)
كل استعلام بحث بيتضاف له فلتر ثابت:
```
status = approved
AND expires_at > now()
AND account.verified = true
AND account.status = active
```
ده بيتحط في الـ backend، مش بيعتمد على الـ client يبعته.

---

## 5. البحث بالعربي

### 5.1 التطبيع (Normalization)
قبل الفهرسة والبحث، نوحّد الحروف:
| الأصل | بعد التطبيع |
|---|---|
| أ، إ، آ | ا |
| ى | ي |
| ة | ه (للبحث فقط، مش للعرض) |
| التشكيل (ً، ٌ، ...) | يُحذف |
| الأرقام العربية (٠-٩) | أرقام لاتينية |

### 5.2 Stopwords
قائمة كلمات بتتشال من البحث: "في"، "من"، "على"، "و"، "ال" (لو منفصلة)، وغيرها.

### 5.3 اللهجة المصرية والمرادفات
**ملف مرادفات (Synonyms):**
- شقه ↔ شقة ↔ شقه
- عربيه ↔ عربية ↔ سيارة ↔ عربة
- تلاجه ↔ تلاجة ↔ ثلاجة
- اوضه ↔ اوضة ↔ غرفة
- ايجار ↔ إيجار ↔ تأجير

**المرادفات بتتحدث من الأدمن** (أو من تحليل البحث اللي بيفشل)، من غير ما نعدل الكود.

### 5.4 التحمل الإملائي
- في PostgreSQL: `pg_trgm` بـ similarity threshold (مثلاً 0.3).
- في OpenSearch: fuzzy matching بـ `fuzziness: AUTO`.
- **ملاحظة:** الـ fuzzy بيزود الوقت، فيتطبق بس لو البحث الأساسي رجع نتايج قليلة (fallback).

### 5.5 Analyzer مقترح (OpenSearch)
```json
{
  "analysis": {
    "filter": {
      "arabic_synonyms": { "type": "synonym", "synonyms_path": "analysis/synonyms_ar.txt" },
      "arabic_stop": { "type": "stop", "stopwords_path": "analysis/stopwords_ar.txt" }
    },
    "analyzer": {
      "arabic_search": {
        "tokenizer": "standard",
        "filter": ["lowercase", "arabic_normalization", "arabic_stop", "arabic_synonyms"]
      }
    }
  }
}
```

---

## 6. البحث الجغرافي

### 6.1 الخصوصية أولاً
**الموقع الدقيق للإعلان ما يتعرضش للعامة**، خصوصاً في العقارات والخدمات المنزلية.

- الإعلان اللي عنده فرع معروف: الموقع المعروض = موقع الفرع بتقريب (مثلاً 300 متر).
- الإعلان بدون فرع: الموقع = المنطقة + إزاحة عشوائية بحدود 500 متر، وتتخزن الإحداثيات الحقيقية للاستخدام الداخلي بس.
- في `location_precision` بيتحدد: `exact` (فرع رسمي) أو `approximate` (تقريبي).

ده بيحمي الخصوصية (ومتوافق مع NFR-PRV-005 في الـ SRS)، ولسه بيخلي المسافة دقيقة بما يكفي للبحث.

### 6.2 الاستعلام
- **PostgreSQL:** `ST_DWithin(location, point, radius_meters)` مع GiST index، والترتيب بـ `ST_Distance`.
- **OpenSearch:** `geo_distance` filter، والترتيب بـ `_geo_distance`.

### 6.3 الـ GPS من التطبيق
- الموقع بيتبعت للـ API مرة واحدة في الجلسة، أو مع كل بحث لو المستخدم اختار "قريب مني".
- الإحداثيات مش بتتخزن في سجل البحث بدقة كاملة (تقريب لـ 3 أرقام عشرية، حوالي 100 متر).

---

## 7. الترتيب (Sorting) والتقسيم (Pagination)

### 7.1 خيارات الترتيب
| الخيار | المنطق |
|---|---|
| **الأحدث** | `approved_at DESC` |
| **الأقرب** | `distance ASC` (لو فيه GPS) |
| **السعر تصاعدي** | `price ASC` |
| **السعر تنازلي** | `price DESC` |
| **الأكثر صلة** (افتراضي) | نقاط التطابق + الـ ranking boost |

### 7.2 الـ Ranking
**الترتيب الافتراضي** = مزيج من:
- درجة التطابق النصي (relevance).
- `ranking_boost` (للإعلانات المميزة، المرحلة الثانية).
- جودة الحساب (متحقق، عنده صور كتير، رد سريع).
- حداثة الإعلان (وزن أقل بمرور الوقت).

**تنبيه:** الـ ranking boost للإعلانات المدفوعة لازم يكون **واضح للمستخدم** (تمييز "إعلان مميز")، عشان الثقة.

### 7.3 Pagination: keyset بدل offset
**ما نستخدمش `OFFSET`** لأنه بيبطأ كل ما الصفحة تكبر.

**نستخدم cursor-based:**
- في PostgreSQL: `WHERE (approved_at, id) < ($cursor_time, $cursor_id) ORDER BY approved_at DESC, id DESC LIMIT 20`.
- في OpenSearch: `search_after` مع sort values.

**الـ cursor بيتعمل encode** (base64) وبيتبعت للتطبيق كـ opaque string.

---

## 8. الـ Facets (عدد النتايج لكل فلتر)

### 8.1 الفكرة
المستخدم يشوف "شقق 3 غرف (45)، شقق 2 غرفة (30)"، عشان يعرف الخيارات المتاحة قبل ما يختار.

### 8.2 القاعدة الذهبية
**الـ facets بتتحسب بعد تطبيق كل الفلاتر ما عدا الفلتر اللي بيتعرض.**
مثال: لو المستخدم اختار "3 غرف"، الـ facet الخاص بالغرف بيعرض الأعداد لكل قيم الغرف، مش بس 3.

### 8.3 التكلفة
- كل facet بيزود وقت الاستعلام.
- **نحدد عدد الـ facets** اللي بتتحسب في الاستعلام الواحد (مثلاً 5 facets كحد أقصى).
- **نحدد عدد القيم لكل facet** (top 20، والباقي يتجمع في "أخرى").

### 8.4 الـ Cache للـ facets
الـ facets للاستعلامات الشائعة (قسم بدون فلاتر، منطقة شائعة) بتتعمل cache في Redis لمدة 5 دقايق.

---

## 9. الـ Caching

### 9.1 طبقات الـ cache
| الطبقة | المحتوى | المدة | الـ invalidation |
|---|---|---|---|
| **Redis: نتايج البحث** | الصفحة الأولى للاستعلامات الشائعة | 60 ثانية | تلقائي بالـ TTL |
| **Redis: الـ facets** | أعداد الفلاتر | 5 دقايق | تلقائي بالـ TTL |
| **Redis: تفاصيل الإعلان** | بيانات الإعلان الكاملة | 10 دقايق | عند تعديل الإعلان |
| **CDN: الصور** | الصور المصغرة | طويلة | بتغيير الـ URL |

### 9.2 مفتاح الـ cache
المفتاح لازم يكون **normalized**: نرتب الفلاتر أبجدياً، ونحول القيم لشكل موحد، عشان `rooms=3&area=nasr` و`area=nasr&rooms=3` يعطوا نفس المفتاح.

```
search:v1:{category_id}:{hash(normalized_filters + sort + cursor)}
```

### 9.3 Invalidation بدون حرق الـ cache
بدل ما نمسح كل نتايج القسم لما إعلان جديد يتنشر، نستخدم **version counter** لكل قسم:
```
category_version:{category_id} → 17
```
الـ cache key بيحتوي على الـ version، فلما الإعلان يتنشر، نزود الـ version، والـ cache القديم يبقى ما يتقراش وبيتشال بالـ TTL.

---

## 10. البحث المحفوظ والتنبيهات (مخطط للمرحلة الثانية V2 — ADR-011)

### 10.1 الفكرة
المستخدم يحفظ بحث (مثلاً "شقة 3 غرف في مدينة نصر بأقل من 10 ألف"). لما يظهر إعلان جديد يطابق، يوصله إشعار.

### 10.2 التنفيذ
**في PostgreSQL (MVP):**
- Job كل 10 دقايق بيجيب الإعلانات الجديدة (`approved_at > آخر فحص`).
- يشغل كل البحوث المحفوظة على الإعلانات الجديدة فقط.
- الإعلانات المطابقة تتسجل في `notifications` وتتبعت FCM.

**في OpenSearch (المرحلة الثانية):**
- استخدام **Percolator**: نخزن الاستعلامات المحفوظة كـ documents، ولما إعلان جديد يتنشر، نعرف مين الاستعلامات اللي بتطابقه فوراً.

### 10.3 حدود
- كل مستخدم له حد أقصى للبحوث المحفوظة (مثلاً 10)، والحد يتحدد من الأدمن.
- التنبيهات بتتحسب ضمن حدود الإشعارات، ومش بتتعدى الحد اليومي.

---

## 11. مسار الطلب الكامل

```
التطبيق
  │  GET /listings?q=شقه&category=...&rooms=3&lat=..&lng=..&radius=5&sort=distance
  ▼
Cloudflare (rate limit)
  ▼
Backend API
  ├── 1. Validation: هل الفلاتر موجودة في category_fields؟ هل القيم صح؟
  ├── 2. Normalization: تطبيع النص، ترتيب الفلاتر، حساب الـ cache key
  ├── 3. Redis: هل فيه نتيجة مخزنة؟ ── نعم ──► رجّع النتيجة
  │                                  لا
  ├── 4. Query builder: يبني الاستعلام + الفلتر الثابت (approved, not expired, ...)
  ├── 5. Search engine (PostgreSQL أو OpenSearch)
  ├── 6. Hydration: جلب بيانات العرض (صورة، سعر، حساب) من الـ cache أو DB
  ├── 7. Redis: تخزين النتيجة
  ▼
الرد: { data: [...], facets: {...}, next_cursor: "..." }
```

---

## 12. أمثلة على الاستعلامات

### 12.1 بحث بسيط بالقسم والمنطقة
```
GET /listings?category=apartments-rent&area=nasr-city&sort=newest
```

### 12.2 بحث بفلاتر الحقول الخاصة
```
GET /listings?category=cars&brand=toyota&year_min=2018&year_max=2022&mileage_max=100000&sort=price_asc
```

### 12.3 بحث بالكلمة والمسافة
```
GET /listings?q=تلاجة&lat=30.06&lng=31.33&radius_km=5&sort=distance
```

### 12.4 بحث بالـ facets
```
GET /listings?category=apartments-sale&include_facets=rooms,area,price_range
```

**الرد:**
```json
{
  "data": [ ... ],
  "facets": {
    "rooms": [ {"value": 2, "count": 45}, {"value": 3, "count": 30} ],
    "area": [ {"value": "nasr-city", "count": 60} ]
  },
  "next_cursor": "eyJ0IjoiMjAyNi0xMS0wMVQxMDowMDowMFoiLCJpZCI6Ii4uLiJ9"
}
```

---

## 13. الأداء والتحمل

### 13.1 أهداف
| المقياس | الهدف |
|---|---|
| p50 زمن الاستجابة | أقل من 150ms |
| p95 زمن الاستجابة | أقل من 500ms |
| p99 زمن الاستجابة | أقل من 1 ثانية |
| نسبة الاستعلامات الفاشلة | أقل من 0.1% |
| زمن ظهور إعلان جديد في البحث | أقل من 10 ثواني من الموافقة |

### 13.2 اختبارات الحمل
- اختبار بـ 2 مليون إعلان مولّد (synthetic) قبل الإطلاق.
- سيناريوهات: بحث بسيط، بحث بفلاتر متعددة، بحث جغرافي، بحث بالـ facets، بحث مع fuzzy.
- قياس زمن الاستجابة، واستهلاك الـ CPU والـ memory.

### 13.3 تحسينات مبكرة
- الـ index المناسب على `(category_id, moderation_status, publication_status, availability_status, expires_at)`.
- Partitioning للإعلانات المنتهية (فصل الجداول التاريخية).
- Connection pooling (PgBouncer).

---

## 14. المراقبة

### 14.1 المقاييس
- زمن الاستجابة (p50، p95، p99) لكل نوع استعلام.
- نسبة الـ cache hit.
- عدد الاستعلامات بدون نتايج (zero-result queries).
- أكتر الكلمات والفلاتر استخداماً.
- أكتر الكلمات اللي البحث فيها فشل (مؤشر لمرادفات ناقصة).

### 14.2 التنبيهات
- زمن الاستجابة p95 تعدى 1 ثانية لمدة 5 دقايق.
- نسبة zero-result تعدت 30%.
- انقطاع أو تأخر في الـ sync (لو OpenSearch).

### 14.3 تحسين مستمر
- مراجعة أسبوعية لـ zero-result queries، وإضافة مرادفات أو فلاتر ناقصة.
- تحليل الفلاتر اللي مش بيستخدمها حد، وإزالتها من الواجهة.

---

## 15. خطة التنفيذ

| المرحلة | المحتوى | المدة التقريبية |
|---|---|---|
| **1** | PostgreSQL + PostGIS + JSONB + GIN، بحث بالقسم والمنطقة والسعر، keyset pagination | أسبوعين إلى 3 |
| **2** | بحث جغرافي بـ GPS، تطبيع عربي، مرادفات أساسية، cache في Redis | أسبوع إلى أسبوعين |
| **3** | Facets، fuzzy matching، ترتيب بالـ ranking | أسبوعين |
| **4** | البحث المحفوظ والتنبيهات | أسبوع |
| **5** (لما الحجم يستدعي) | نقل لـ OpenSearch، outbox pattern، percolator للتنبيهات | 3 إلى 4 أسابيع |

---

## 16. قرارات محتاجة ردك

1. **المرحلة الأولى:** هل نبدأ بـ PostgreSQL فقط ونقيّم بعد الإطلاق، ولا نبدأ بـ OpenSearch من الأول؟ (التوصية: PostgreSQL.)
2. **الموقع المعروض:** هل نعرض موقع تقريبي لكل الإعلانات، ولا الفروع الرسمية بس تظهر دقيقة؟ (التوصية: تقريبي للإعلانات بدون فرع، ودقيق للفروع المعتمدة.)
3. **الإعلانات المميزة:** هل تظهر في نفس نتايج البحث بتمييز واضح، ولا في شريط منفصل؟ (التوصية: نفس النتايج بتمييز واضح.)
4. **عدد البحوث المحفوظة للمستخدم:** كام كحد أقصى؟ (التوصية: 10 في البداية.)
5. **مدة صلاحية الكاش للنتايج:** 60 ثانية مناسبة، ولا تحتاج أقل لتحديث أسرع؟

---

## سجل التعديلات

| الإصدار | التاريخ | الوصف |
|---|---|---|
| 1.0 | 1 نوفمبر 2026 | المسودة الأولى لمعمارية الفلاتر والبحث |
