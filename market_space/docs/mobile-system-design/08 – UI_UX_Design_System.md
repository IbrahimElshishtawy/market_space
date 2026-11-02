# 08 – UI/UX & Design System Architecture

## 1. Design System Foundations

The visual language of Deal One is defined under `lib/core/theme/`. It employs a **Monochromatic Modern Luxury** aesthetic utilizing deep charcoal slates, crisp whites, and subtle neutral zinc borders, creating an uncluttered presentation suited for high-value commerce (real estate, automotive, building materials).

```
Theme Token Hierarchy (lib/core/theme/)
├── AppColors (Color Palette & Semantic Tokens)
├── AppSpacing (8-Point Grid Spacing Tokens)
├── AppRadii (Border Radius Curves)
├── AppTextStyles (Type Scale & Font Weights)
└── AppThemeData (Light & Dark Material 3 ThemeData)
```

---

## 2. Design Tokens Breakdown

### 2.1 Color Palette (`AppColors`)
- **Source File**: [lib/core/theme/app_colors.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_colors.dart)

| Token Name | Hex Value | Semantic Role in Deal One |
|---|---|---|
| `primary` | `0xFF0F172A` (Slate 900) | Primary branding, action buttons, active tab indicators |
| `primaryDark` | `0xFFF8FAFC` (Slate 50) | Primary foreground in Dark Mode |
| `backgroundLight` | `0xFFFFFFFF` | Scaffold canvas in Light Mode |
| `backgroundDark` | `0xFF090D16` | Scaffold canvas in Dark Mode |
| `surfaceLight` | `0xFFF8FAFC` (Slate 50) | Card backgrounds, search fields, chips |
| `surfaceDark` | `0xFF111827` (Slate 800) | Card backgrounds in Dark Mode |
| `borderLight` | `0xFFE2E8F0` (Slate 200) | Dividers, card outline borders, input borders |
| `borderDark` | `0xFF1F2937` (Slate 700) | Dividers and borders in Dark Mode |
| `textPrimaryLight` | `0xFF0F172A` | Primary typography (headings, titles, prices) |
| `textSecondaryLight`| `0xFF64748B` (Slate 500) | Secondary typography (captions, specs, dates) |
| `success` | `0xFF10B981` (Emerald 500) | Completed orders, available units, price discounts |
| `warning` | `0xFFF59E0B` (Amber 500) | Pending bookings, quotation reviews |
| `error` | `0xFFEF4444` (Red 500) | Form validation errors, network failures |

### 2.2 Spacing System (`AppSpacing`)
- **Source File**: [lib/core/theme/app_spacing.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_spacing.dart)
- Follows an 8-point base grid:
  - `xxs`: `2.0 dp`
  - `xs`: `4.0 dp`
  - `sm`: `8.0 dp`
  - `md`: `12.0 dp`
  - `lg`: `16.0 dp` (Standard screen padding)
  - `xl`: `20.0 dp`
  - `xxl`: `24.0 dp`
  - `xxxl`: `32.0 dp`

### 2.3 Corner Radii (`AppRadii`)
- **Source File**: [lib/core/theme/app_radii.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_radii.dart)
  - `none`: `0.0`
  - `xs`: `4.0 dp` (Tags, small indicators)
  - `sm`: `8.0 dp` (Form inputs, action buttons)
  - `md`: `12.0 dp` (Standard product and listing cards)
  - `lg`: `16.0 dp` (Modals, bottom sheets)
  - `xl`: `24.0 dp` (Hero banners, floating containers)
  - `full`: `999.0 dp` (Pill badges, category chips, avatar circles)

### 2.4 Typography & Text Styles (`AppTextStyles`)
- **Source File**: [lib/core/theme/app_text_styles.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_text_styles.dart)
- Configured with localized font weights and line heights optimized for both Arabic and Latin scripts:
  - `displayLarge`: `28.0 sp` / Bold (w700)
  - `headlineMedium`: `20.0 sp` / SemiBold (w600) (Screen titles, sector headers)
  - `titleMedium`: `16.0 sp` / Medium (w500) (Card titles, price figures)
  - `bodyMedium`: `14.0 sp` / Regular (w400) (Listing descriptions, body copy)
  - `bodySmall`: `12.0 sp` / Regular (w400) (Specifications, tags, timestamps)
  - `labelSmall`: `10.0 sp` / Medium (w500) (Badges, pill counters)

---

## 3. Light & Dark Theme Configuration

The application implements full Material 3 dynamic styling through [lib/core/theme/app_theme_data.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_theme_data.dart):

```dart
class AppThemeData {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    // ... complete button and input styling
  );
  
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    // ... matching dark tokens
  );
}
```

Theme switching is controlled reactively by `ThemeNotifier` ([lib/core/theme/theme_notifier.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/theme_notifier.dart)), which persists the selection to `SharedPreferences` via `PreferencesService`.

---

## 4. Reusable Shared UI Components

| Component Widget | File Path | Functional Description |
|---|---|---|
| `SafeNetworkImage` | [safe_network_image.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/safe_network_image.dart) | Defensive image loader that validates URL protocol, provides a placeholder shimmer, and handles image decode failures with a fallback icon. |
| `AppErrorView` | [app_error_view.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/app_error_view.dart) | Standardized full-screen or embedded error view displaying localized failure text and a primary "إعادة المحاولة" (Retry) action button. |
| `AppLoadingIndicator` | [app_loading_indicator.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/app_loading_indicator.dart) | Circular progress indicator centered and sized to match design system tokens. |
| `GlobalNavigationScaffold`| [global_navigation_scaffold.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/navigation/presentation/pages/global_navigation_scaffold.dart)| Primary responsive shell containing bottom tab bar and section-aware floating action triggers. |
| `HomeNavBar` | [home_nav_bar.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/navigation/presentation/widgets/home_nav_bar.dart) | Bottom navigation bar with animated indicator pills, unread badge counters, and SVG icons. |

---

## 5. Design Inconsistencies & Legacy Code Audit

1. **Legacy Screen Style Fracture**:
   - The orphaned file [lib/shared/widgets/market_home_screen.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/market_home_screen.dart) uses hardcoded legacy colors (`Color(0xFF0D9488)` teal and `Color(0xFFF97316)` orange) and UAE Dirhams (`AED`), which clashes with the official monochrome black/slate palette used throughout the rest of the application.
2. **Missing Image Placeholder Shimmer**:
   - While `SafeNetworkImage` implements a basic container placeholder, it lacks an animated shimmer shader effect, causing jarring pop-ins when lists of properties or products load over the network.
3. **Hardcoded Inline Dimensions in Feature Widgets**:
   - Multiple feature widgets (e.g. `RealEstateCard`, `CarCard`) occasionally hardcode fixed heights (`height: 220`) rather than relying on flexible aspect-ratio constraints, which can lead to layout overflows on smaller screen widths (e.g. iPhone SE / 360dp Android devices).
