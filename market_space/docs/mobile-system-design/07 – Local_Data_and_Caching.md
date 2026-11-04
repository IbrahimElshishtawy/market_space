# 07 – Database, Local Storage & Caching Architecture

## 1. Storage Technologies Overview

The Deal One mobile application utilizes a tiered local persistence strategy. Note that this analysis covers **mobile device local storage**, strictly distinguishing client-side persistence from backend database architectures:

```
Mobile Storage Architecture
├── 1. Non-Sensitive Key-Value Store: SharedPreferences (v2.5.6)
│   └── PreferencesService (Theme, Language, Sector, Onboarding flags)
├── 2. Cryptographic Secure Vault: FlutterSecureStorage (v11.2.0)
│   └── SecureStorageService (Access Tokens, Refresh Tokens, User IDs)
├── 3. In-Memory Volatile Caching: State Controllers & Repositories
│   └── ValueNotifier instances & static Dart mock datasets
└── 4. In-Memory Image Cache: Flutter Engine ImageCache
    └── AppNetworkImage / SafeNetworkImage (cacheWidth / cacheHeight constrained)
```

---

## 2. Storage Systems Analysis

### 2.1 Plaintext Key-Value Storage (`shared_preferences`)

| Dimension | Specification |
|---|---|
| **Underlying Library** | `shared_preferences` v2.5.6 |
| **Wrapper Interface** | `PreferencesService` ([lib/core/storage/preferences_service.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/storage/preferences_service.dart)) |
| **Concrete Implementation**| `SharedPreferencesServiceImpl` (with `InMemoryPreferencesService` for tests) |
| **Platform Backends** | Android `SharedPreferences` XML / iOS `NSUserDefaults` plist |
| **Security Classification**| **UNENCRYPTED** – Non-sensitive application configuration only |

#### Stored Keys Registry (from [storage_keys.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/storage/storage_keys.dart))

| Storage Key | Stored Data Type | Purpose & Lifecycle | Consuming Component |
|---|---|---|---|
| `app_theme_mode` | `String` (`'light'`, `'dark'`, `'system'`) | Persists the user's selected UI theme across restarts | `ThemeController` ([app_theme.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_theme.dart)) |
| `app_language_code`| `String` (`'ar'`, `'en'`) | Persists active localization locale | `LocaleController` ([locale_controller.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/localization/locale_controller.dart)) |
| `app_selected_sector`| `String` (e.g. `'real_estate'`, `'cars'`) | Persists active marketplace vertical | `SectorController` ([sector_controller.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/state/sector_controller.dart)) |
| `app_onboarding_completed`| `bool` | Reserved flag for first-time tutorial | Defined in `StorageKeys` (unwired) |
| `app_cached_user` | `String` (JSON) | Serialized profile information | Defined in `StorageKeys` (unwired) |

---

### 2.2 Cryptographic Token Vault (`flutter_secure_storage`)

| Dimension | Specification |
|---|---|
| **Underlying Library** | `flutter_secure_storage` v11.2.0 |
| **Wrapper Interface** | `SecureStorageService` ([lib/core/storage/secure_storage_service.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/storage/secure_storage_service.dart)) |
| **Concrete Implementation**| `FlutterSecureStorageServiceImpl` (with `InMemorySecureStorageService` for tests) |
| **Platform Backends** | **Android**: AES encryption via Android Keystore (`EncryptedSharedPreferences`)<br/>**iOS**: Apple Keychain Services (`kSecAttrAccessibleAfterFirstUnlock`) |
| **Security Classification**| **ENCRYPTED & HARDWARE-BACKED** – High security |

#### Stored Secure Keys Registry

| Storage Key | Stored Data | Security Classification | Consuming Component |
|---|---|---|---|
| `secure_access_token` | JWT Access Token | Hardware-encrypted | `SecureTokenProvider` -> `AuthInterceptor` |
| `secure_refresh_token`| JWT Refresh Token | Hardware-encrypted | `SecureTokenProvider` -> `AuthInterceptor` |
| `secure_user_id` | Unique UUID | Hardware-encrypted | `SecureTokenProvider` |

---

### 2.3 Image Memory Caching & Absence of Disk Cache

The application implements `AppNetworkImage` ([lib/shared/widgets/app_network_image.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/app_network_image.dart)):

```dart
Image.network(
  optimizedUrl,
  cacheWidth: cacheW,
  cacheHeight: cacheH,
  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) { ... },
  errorBuilder: (context, error, stackTrace) { ... },
)
```

#### Image Caching Characteristics:
1. **Memory Caching**: Images are decoded and cached in RAM via Flutter's global `PaintingBinding.instance.imageCache`.
2. **RAM Optimization**: `cacheWidth` and `cacheHeight` constraints are dynamically calculated based on widget bounding boxes, preventing out-of-memory (OOM) errors during heavy scrolling of property or car galleries.
3. **Absence of Disk Caching**: Because third-party disk caching packages (e.g. `cached_network_image`) are not included in `pubspec.yaml`, **network images are purged when the app process is terminated**. Every cold launch re-fetches images from remote CDNs over HTTP.

---

### 2.4 In-Memory Volatile State Caching

Because feature repositories are mocked, all entities (property bookmarks, car favorites, shopping carts, RFQs, service bookings) reside in volatile RAM collections:
- `MockRealEstateRepository._cache`
- `MockCarsRepository._cars`
- `MockFashionRepository._products`
- `BuildingMaterialsCartController.value`
- `HomeAppliancesCartController.value`

**Data Lifecycle**: Any modifications made by the user (adding items to the cart, submitting an RFQ, toggling a bookmark) survive screen navigation via `AppDependencies`, but **are entirely reset to initial mock fixtures upon restarting the application**.

---

### 2.5 Verified Embedded Database Absences

The mobile client **does not implement an embedded relational or document database**:
- **SQLite / Drift / Floor**: Not present.
- **Hive / Isar**: Not present.
- **ObjectBox / Realm**: Not present.

Local offline persistence is currently restricted strictly to the key-value pairs stored in `PreferencesService` and `SecureStorageService`.
