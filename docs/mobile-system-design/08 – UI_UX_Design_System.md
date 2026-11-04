# 08 – UI/UX & Design System Architecture

## 1. Design System Philosophy

The Deal One mobile application features a centralized, accessible **High-Contrast Monochrome Design System**. The visual identity relies on pure black, white, and balanced grayscale shades for core chrome and layout components, combined with standard semantic colors (Success, Warning, Error, Info) that conform to **WCAG 2.2 AA** minimum contrast ratios.

---

## 2. Color System (`AppColors`)

Implemented centrally in [lib/core/theme/app_colors.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_colors.dart):

### 2.1 Monochrome Tokens

| Token Name | Light Mode Value | Dark Mode Value | Semantic Role |
|---|---|---|---|
| `primary` | `#111111` | `#FFFFFF` | Primary actions, key headers, prominent badges |
| `onPrimary` | `#FFFFFF` | `#111111` | Text and icons placed on primary background |
| `background` | `#FFFFFF` | `#121212` | Main screen background |
| `surface` | `#FFFFFF` | `#1C1C1C` | Cards, app bars, sheets, floating modals |
| `surfaceSecondary` | `#F5F5F5` | `#262626` | Input fields, filter chip backgrounds, search bars |
| `surfaceTertiary` | `#EEEEEE` | `#303030` | Skeleton shimmer gradients, subtle dividers |
| `textPrimary` | `#111111` | `#FFFFFF` | High-emphasis body text and page titles |
| `textSecondary` | `#404040` | `#D0D0D0` | Medium-emphasis labels and secondary metadata |
| `textMuted` | `#666666` | `#A0A0A0` | Low-emphasis captions, timestamps, placeholders |
| `border` | `#E0E0E0` | `#383838` | Card outlines, input boundaries |
| `divider` | `#E5E5E5` | `#303030` | Horizontal and vertical structural rules |
| `iconPrimary` | `#222222` | `#FFFFFF` | Interactive icon buttons, tab bar icons |
| `disabled` | `#BDBDBD` | `#707070` | Inactive buttons, disabled switches |

### 2.2 Accessible Semantic Status Tokens (WCAG 2.2 AA Compliant)

| Semantic Role | Light Mode Color | Light Tint Background | Dark Mode Color | Dark Tint Background |
|---|---|---|---|---|
| **Success** | `#16A34A` | `#F0FDF4` | `#22C55E` | `#052E16` |
| **Warning** | `#D97706` | `#FFFBEB` | `#FBBF24` | `#451A03` |
| **Error** | `#DC2626` | `#FEF2F2` | `#EF4444` | `#450A0A` |
| **Information** | `#2563EB` | `#EFF6FF` | `#3B82F6` | `#172554` |

### 2.3 Dynamic Theme Resolvers
The class exposes contextual methods ensuring zero hardcoded light/dark conditionals in widgets:
```dart
AppColors.backgroundOf(context);
AppColors.surfaceOf(context);
AppColors.textPrimaryOf(context);
AppColors.isDark(context);
```

---

## 3. Typography Hierarchy (`AppTextStyles`)

Implemented in [lib/core/theme/app_text_styles.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_text_styles.dart), designed for optimal legibility in Arabic (RTL) and English (LTR):

| Style Identifier | Size / Weight | Line Height | Intended Usage |
|---|---|---|---|
| `display` | 32px / Bold (w700) | 1.25 | Hero marketing titles |
| `h1` | 26px / Bold (w700) | 1.30 | Primary page titles (e.g. "العقارات في مصر") |
| `h2` | 22px / SemiBold (w600)| 1.35 | Major section headings |
| `h3` | 18px / SemiBold (w600)| 1.40 | Card titles and modal dialog headers |
| `bodyLarge` | 16px / Regular (w400) | 1.50 | Product descriptions, terms text |
| `body` | 14px / Regular (w400) | 1.50 | Standard body copy |
| `label` | 14px / Medium (w500) | 1.35 | Form field labels, tab bar indicators |
| `caption` | 13px / Regular (w400) | 1.40 | Supporting metadata, timestamps |
| `button` | 15px / SemiBold (w600)| 1.20 | Primary and secondary button text |

---

## 4. Spacing & Corner Radii Scales

### 4.1 Spacing Scale (`AppSpacing`)
Implemented in [lib/core/theme/app_spacing.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_spacing.dart):
- `xxs`: `2.0 dp`
- `xs`: `4.0 dp`
- `sm`: `8.0 dp`
- `md`: `12.0 dp`
- `lg`: `16.0 dp` (standard screen gutter)
- `xl`: `20.0 dp`
- `xxl`: `24.0 dp`
- `xxxl`: `32.0 dp`
- `huge`: `48.0 dp`

### 4.2 Corner Radii Scale (`AppRadii`)
Implemented in [lib/core/theme/app_radii.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_radii.dart):
- `xs`: `4.0 dp` (badges, tags)
- `sm`: `8.0 dp` (chips, compact buttons)
- `md`: `12.0 dp` (standard cards, text inputs)
- `lg`: `16.0 dp` (modals, dialogs, image thumbnails)
- `xl`: `24.0 dp` (bottom sheets, hero banners)
- `full`: `999.0 dp` (circular avatars, pill buttons)

---

## 5. Theme Architecture (`AppThemeData` & `ThemeController`)

- **Material 3 Integration**: Configured with `useMaterial3: true` in [app_theme_data.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_theme_data.dart).
- **Theme State Management**: `ThemeController` ([lib/app/app_theme.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_theme.dart)) loads `ThemeMode` from `PreferencesService` on startup and enables seamless one-tap switching via `toggleTheme()`.
- **Card Styling**: Strict 0-elevation design with `1.0 dp` hairline border (`AppColors.border`).
- **Input Field Styling**: Filled background (`AppColors.surfaceSecondary`), no harsh default borders, rounded corners (`AppRadii.md`).

---

## 6. Shared Component Inventory

| Component Name | Source File | Functionality & Features |
|---|---|---|
| `AppLoadingIndicator` | [lib/shared/widgets/app_loading_indicator.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/app_loading_indicator.dart) | Monochrome circular indicator or full-screen loading overlay |
| `AppEmptyState` | [lib/shared/widgets/app_empty_state.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/app_empty_state.dart) | Visual placeholder with custom icon, title, description, and action button |
| `AppErrorView` | [lib/shared/widgets/app_error_view.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/app_error_view.dart) | User-friendly error card with retry button |
| `AppNetworkImage` | [lib/shared/widgets/app_network_image.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/app_network_image.dart) | Safe image loader with RAM-bounded decoding and shimmer placeholder |
| `RealEstateCard` | [lib/shared/widgets/market_widgets/real_estate_card.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/market_widgets/real_estate_card.dart) | Property card showing price badge, room chips, area, and broker info |
| `MaterialProductCard` | [lib/shared/widgets/market_widgets/material_product_card.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/market_widgets/material_product_card.dart) | Construction material card with ton/pallet price, call/chat triggers |
| `ServiceProviderCard` | [lib/shared/widgets/market_widgets/service_provider_card.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/market_widgets/service_provider_card.dart) | Technician profile card with rating stars, completed jobs count |
| `HomeNavBar` | [lib/features/home/widgets/home_nav_bar/home_nav_bar.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/home/widgets/home_nav_bar/home_nav_bar.dart) | Floating bottom navigation bar with active sector indicators |

---

## 7. Component Inconsistencies & Legacy Artifacts

1. **Legacy Screen `market_home_screen.dart`**:
   - Located at [lib/shared/widgets/market_home_screen.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/market_home_screen.dart).
   - Contains unrouted code using hardcoded UAE currencies (`AED`), hardcoded colors (`Color(0xFF0F766E)`, `Color(0xFFEA580C)`), conflicting with the Egyptian Pound (`ج.م` / `EGP`) and Monochrome system used by the rest of the app.
2. **Duplicated Search Bars**:
   - `HomeSearchBar` ([lib/features/home/widgets/home_search_bar/](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/home/widgets/home_search_bar/))
   - `MarketSearchBar` ([lib/shared/widgets/market_widgets/market_search_bar.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/market_widgets/market_search_bar.dart))
   - `RealEstateSearchBar` ([lib/features/real_estate/widgets/real_estate_search_bar/](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/real_estate/widgets/real_estate_search_bar/))
   - *Recommendation*: Unify these search bars into a single reusable core component.

