# 05 — Home & Discovery Screens Specification

## Screen: Multi-Sector Discovery Home Feed (`SCR-HOM-001`)

### 1. Screen Identity
- **Screen ID:** `SCR-HOM-001`
- **Module:** Module C: Home & Discovery
- **Screen Name (AR):** الرئيسية واستكشاف الأقسام
- **Screen Name (EN):** Multi-Sector Discovery Home Feed
- **Current Implementation Status:** **IMPLEMENTED** ([lib/features/home/presentation/pages/home_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/home/presentation/pages/home_page.dart))
- **V1 Product Status:** **APPROVED V1**
- **Primary User Role:** All (Guest & Authenticated User)
- **Entry Routes:** Application Cold Boot $\to$ `RouteNames.root` (`/`), Bottom Navigation Tab 0
- **Exit Routes:** 
  - Sector Verticals (`/real-estate`, `/building-materials`, `/home-services`, `/home-appliances`, `/cars`, `/fashion`)
  - Cross-Sector Search (`/explore` - Tab 1)
  - Global Notifications (`/notifications`)
  - Listing Details (`SCR-RES-002`, `SCR-CAR-002`, etc.)

---

### 2. Screen Purpose
`SCR-HOM-001` serves as the primary gateway and discovery canvas of the Deal One application. It solves the fragmentation problem by aggregating Egypt's six major commercial verticals into a single cohesive, high-density browsing experience. The primary user action is to discover trending commercial listings, switch across economic sectors, view daily promotional announcements, or launch targeted searches.

---

### 3. Layout Structure & Visual Hierarchy

```
+-------------------------------------------------------------+
| SAFE AREA TOP                                               |
+-------------------------------------------------------------+
| APP BAR / HEADER (SCR-HOM-001-A)                            |
| [User Avatar / Greeting]  [Location: طنطا v] [Notifications] |
+-------------------------------------------------------------+
| SEARCH BAR DOCK (SCR-HOM-001-B)                             |
| [Search Icon] "ابحث في آلاف العروض والخدمات..."  [Filter]   |
+-------------------------------------------------------------+
| SECTOR SELECTION PILLS (SCR-HOM-002)                        |
| [الكل] [عقارات] [مواد بناء] [خدمات] [أجهزة] [سيارات] [أزياء]   |
+-------------------------------------------------------------+
| MAIN SCROLLABLE BODY (CustomScrollView + RefreshIndicator)   |
|                                                             |
| 1. HERO PROMOTIONAL CAROUSEL (SCR-HOM-003)                  |
|    +---------------------------------------------------+    |
|    | [Badge: عقارات موثوقة]                             |    |
|    | احجز بيت أحلامك - آلاف العقارات بدون وسيط          |    |
|    | [CTA: تصفح العقارات]                              |    |
|    +---------------------------------------------------+    |
|    (Indicator Dots: • • ○ • •)                              |
|                                                             |
| 2. MAIN CATEGORIES GRID (SCR-HOM-004)                       |
|    [عقارات]  [مواد بناء]  [خدمات منزلية]  [أجهزة وديكور]     |
|                                                             |
| 3. NEARBY POSTGIS LISTINGS (SCR-HOM-005)                    |
|    Header: "إعلانات قريبة منك"  [عرض الكل >]                |
|    [Card 1: شقة بالتجمع]  [Card 2: تويوتا كورولا] ...       |
|                                                             |
| 4. MOST REQUESTED / FEATURED (SCR-HOM-006)                  |
|    Header: "الأكثر طلباً اليوم"                             |
|    [Card: صيانة تكييف]  [Card: توريد حديد عز] ...           |
|                                                             |
| 5. SECTION FOOTER / PADDING                                 |
|    Height: 80dp (Clearance for floating navigation bar)     |
+-------------------------------------------------------------+
| PERSISTENT BOTTOM NAVIGATION BAR (Index 0 Active)           |
+-------------------------------------------------------------+
```

---

### 4. UI Components

#### Component 1: `HomeHeader`
- **Purpose:** Identifies active user, active geographic governorate/city, and provides shortcut to notifications.
- **Content:** User avatar (or guest placeholder), greeting string ("مرحباً، مصطفى" or "مرحباً بك في Deal One"), location drop-chip ("الغربية - طنطا"), and unread notification bell badge.
- **Dimensions:** Height 64.0 dp, horizontal padding `AppSpacing.md` (12.0 dp).
- **Interactions:**
  - Tapping Location opens `SCR-SRC-004` (Administrative Location Selector).
  - Tapping Notification Bell navigates to `SCR-NOT-001` (`/notifications`).
  - Tapping Avatar opens Tab 4 (`/profile`).

#### Component 2: `HomeSearchBar`
- **Purpose:** Fast entry point to cross-sector search.
- **Content:** Magnifying glass icon, animated hint text ("ابحث عن شقة، سيارة، مواد بناء..."), voice/scan shortcut or quick filter icon.
- **Dimensions:** Height 48.0 dp, background `AppColors.surfaceSecondary`, border radius `AppRadii.md` (12.0 dp).
- **Interactions:** Tapping the search bar transitions immediately to `SCR-SRC-001` (`/explore`) with keyboard auto-focused.

#### Component 3: `HeroCarousel` (`SCR-HOM-003`)
- **Purpose:** Editorial banners highlighting major commercial events, market updates, or seasonal campaigns.
- **Content:** Background asset image, category pill badge, headline, subtitle, and primary call-to-action button.
- **Dimensions:** Aspect ratio 16:9, viewport fraction 0.92, auto-scroll interval 5 seconds.
- **Interactions:** Tapping the banner executes its target deep link (e.g. `/building-materials/steel-rebar`).

#### Component 4: `MainCategoriesSection` (`SCR-HOM-004`)
- **Purpose:** Direct access to the 6 core commercial sectors.
- **Content:** Circular or rounded square container (64x64 dp), high-contrast icon, category label.
- **Interactions:** Tapping an icon routes directly to the designated sector home (e.g. `/real-estate`).

---

### 5. Data Requirements & Backend API Grounding
- **Primary API Dependency:** `API-SRC-002: Home Screen Unified Feed` (`GET /api/v1/search/feed/home`).
- **Required Query Parameters:** `area_id` (UUID), `lat` (float, optional), `lng` (float, optional).
- **Response Fields:**
  - `banners`: Array of `{ id, title, subtitle, badge, cta_label, image_url, deep_link }`.
  - `sectors`: Array of `{ id, slug, name_ar, name_en, icon_url }`.
  - `nearby_listings`: Keyset paginated array of standard listing summary DTOs.
  - `featured_listings`: Array of curated listing summary DTOs.
- **Loading Behavior:** Shimmer skeletons matching the exact proportions of the Hero Carousel and Category Grid.
- **Fallback Behavior:** If geolocation is denied or network fails, display cached categories with `AppEmptyState` or `AppErrorView`.

---

### 6. User Interactions & Gesture Handling
- **Pull-to-Refresh:** Pulling down on the `CustomScrollView` triggers `RefreshIndicator`, re-fetching `/search/feed/home` and refreshing badge counters.
- **Scroll Directional Detection:** 
  - Scrolling down (reverse) smoothly hides the persistent bottom navigation bar to maximize content reading canvas.
  - Scrolling up (forward) immediately restores navigation bar visibility.
- **Horizontal Swiping:** Swiping the Hero Banner carousel moves to the next promotional card with haptic feedback.

---

### 7. Screen States Matrix

| State Name | Visual Presentation & Behavior |
|---|---|
| **Initial / Loading** | Fullscreen shimmer skeleton: Header block, 16:9 carousel placeholder, 2x3 category circular placeholders, 2 horizontal card skeletons. |
| **Success (Populated)** | Complete dynamic feed with personalized greeting, active banners, and localized nearby items. |
| **Empty Discovery (`SCR-HOM-007`)** | Displayed if no listings exist in user's selected area: Illustration, text ("لا توجد إعلانات حالياً في هذه المنطقة"), button ("توسيع نطاق البحث إلى المحافظة"). |
| **Error (Network Loss)** | `AppErrorView` with offline icon, Egyptian Arabic error ("تعذر الاتصال بالخادم، يرجى التحقق من الإنترنت"), and "إعادة المحاولة" retry button. |
| **Partial Data** | Banners and categories render from local cache while nearby listings show inline retry button. |

---

### 8. Responsive & Adaptive Behavior
- **Compact Phones (< 360dp width):** Hero carousel height scales to 160dp; categories displayed in a 2-row horizontal scroll rather than a rigid 4-column wrap.
- **Standard Phones (375dp - 412dp):** Default baseline layout with 16dp outer screen gutters.
- **Large Phones & Foldables (> 428dp width):** Two-column split layout for featured and nearby feeds.
- **RTL / LTR Behavior:** Directionality mirrors automatically: Greeting on the right, notification bell on the left in Arabic mode.

---

### 9. Accessibility Specifications (WCAG 2.2 AA)
- **Contrast:** Greeting text (`#111111`) on background (`#FFFFFF`) achieves a contrast ratio of 15.8:1.
- **Touch Target Sizes:** Notification icon button is bounded by 48x48 dp minimum invisible padding.
- **Screen Reader (Semantics):** Carousel cards announce as `"إعلان ترويجي، ١ من ٥: [العنوان]"`.
- **Text Scaling:** Supports dynamic type up to 200% without overflowing or truncating header labels.

---

### 10. Design & Visual Notes
- Avoid harsh saturated primary fills; use pure black `#111111` for CTA buttons to preserve the monochrome luxury aesthetic.
- Category icons utilize rounded square containers with 12dp border radius and 10% opacity monochrome tint.
