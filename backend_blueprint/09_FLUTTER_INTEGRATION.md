# Deal One — Flutter Client Integration Architecture

## 1. Overview & Mobile Architecture Alignment

The Deal One mobile application is built with **Flutter 3.x** using **Clean Architecture** principles across a feature-driven folder structure (`market_space/lib/features/`).

This document specifies the exact contract, data sources, network interceptors, local persistence, and offline handling necessary to integrate the Flutter mobile client with the NestJS/Fastify backend.

---

## 2. Feature-to-API Mapping Matrix

| Flutter Feature Module | Mobile Screens & Widgets | Remote Data Source | Domain Model | Backend API Endpoints Consumed |
|---|---|---|---|---|
| **`core/network`** | Global HTTP Client | `ApiClient` (Dio) | `ApiResponse<T>` | All `/api/v1/*` routes |
| **`core/security`** | Token & Session Manager | `SecureStorageDataSource` | `AuthTokens` | `/auth/token/refresh`, `/auth/logout` |
| **`features/profile`** | `ProfileScreen`, `LoginBottomSheet` | `AuthRemoteDataSource` | `UserProfile`, `UserSession` | `/auth/otp/send`, `/auth/otp/verify`, `/users/me` |
| **`features/navigation`** | `AccountSwitcherDrawer` | `AccountRemoteDataSource` | `SellerAccount` | `/accounts/my-accounts`, `/accounts` |
| **`features/home`** | `HomeScreen`, Category Bar | `CategoriesRemoteDataSource` | `CategoryTree` | `/categories`, `/explore/feed` |
| **`features/real_estate`** | `RealEstateFeed`, Filters | `ListingsRemoteDataSource` | `ListingItem`, `ListingDetail` | `/search?category_slug=real-estate`, `/listings/{id}` |
| **`features/cars`** | `CarsFeed`, Filter Dialog | `ListingsRemoteDataSource` | `ListingItem` | `/search?category_slug=cars`, `/categories/{id}/fields` |
| **`features/building_materials`** | `CategoryProductsGrid` | `ListingsRemoteDataSource` | `ListingItem` | `/search?category_slug=building-materials` |
| **`features/home_services`** | Service Cards Grid | `ListingsRemoteDataSource` | `ListingItem` | `/search?category_slug=services` |
| **`features/explore`** | Video Reels & Shorts | `ExploreRemoteDataSource` | `VideoListing` | `/explore/feed` |
| **`features/favorites`** | `FavoritesScreen` | `FavoritesRemoteDataSource` | `FavoriteItem` | `/favorites`, `/favorites/{id}` |
| **`features/activity`** | Merchant Ads Management | `MerchantRemoteDataSource` | `MyListing` | `/accounts/{id}/listings`, `/listings/{id}/visibility` |
| **`features/notifications`** | `NotificationsScreen` | `NotifRemoteDataSource` | `AppNotification` | `/notifications`, `/notifications/mark-read` |

---

## 3. Network Client Configuration (Dio + Interceptors)

The Flutter mobile application utilizes `Dio` configured with strict timeouts and resilient interceptors.

### 3.1 Dio Base Configuration
```dart
final BaseOptions dioOptions = BaseOptions(
  baseUrl: 'https://api.deal-one.eg/api/v1',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  sendTimeout: const Duration(seconds: 15),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Accept-Language': 'ar',
  },
);
```

### 3.2 Authentication & Token Refresh Interceptor (`AuthInterceptor`)
Handles automatic injection of the `Bearer <access_token>` and the multi-tenant `X-Account-ID` header, with synchronized silent token refresh upon encountering HTTP `401 Unauthorized`.

```dart
class AuthInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  AuthInterceptor(this._secureStorage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: 'access_token');
    final activeAccountId = await _secureStorage.read(key: 'active_account_id');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (activeAccountId != null) {
      options.headers['X-Account-ID'] = activeAccountId;
    }
    options.headers['X-Request-ID'] = const Uuid().v4();
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/')) {
      // Trigger synchronized silent token refresh
      try {
        final refreshToken = await _secureStorage.read(key: 'refresh_token');
        if (refreshToken == null) {
          handler.next(err);
          return;
        }

        final refreshResponse = await _dio.post(
          '/auth/token/refresh',
          data: {'refresh_token': refreshToken},
          options: Options(headers: {}), // Avoid infinite loops
        );

        if (refreshResponse.statusCode == 200) {
          final newAccessToken = refreshResponse.data['data']['access_token'];
          final newRefreshToken = refreshResponse.data['data']['refresh_token'];

          await _secureStorage.write(key: 'access_token', value: newAccessToken);
          await _secureStorage.write(key: 'refresh_token', value: newRefreshToken);

          // Retry the original failed request
          final originalRequest = err.requestOptions;
          originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';

          final cloneResponse = await _dio.fetch(originalRequest);
          handler.resolve(cloneResponse);
          return;
        }
      } catch (refreshError) {
        // Refresh token compromised or expired - trigger logout
        await _secureStorage.deleteAll();
        // Notify navigation router to redirect to login
      }
    }
    handler.next(err);
  }
}
```

---

## 4. Uniform Error Mapping to Domain Failures

Every network error is mapped deterministically from the backend error envelope into strongly typed Dart domain failures:

```dart
abstract class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('يرجى التحقق من اتصالك بالإنترنت');
}

class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}
```

---

## 5. Mobile File Upload Workflow (Direct to Cloudflare R2)

To preserve mobile battery life and prevent uploading through API proxies:
1. Flutter client calls `POST /api/v1/media/presigned-url` with image MIME type and file size.
2. Backend responds with `upload_url` (presigned S3/R2 PUT URL) and `storage_key`.
3. Flutter client uses standard HTTP PUT via `Dio` to upload raw image bytes directly to Cloudflare R2.
4. Upon HTTP 200 from R2, Flutter client calls `POST /api/v1/listings/{id}/media` confirming the `storage_key`.
5. Background worker immediately processes thumbnails and scrubs EXIF GPS coordinates.

---

## 6. Offline Support & Local Caching (Drift / SQLite)

1. **Category Taxonomy & Locations:** Cached locally in Drift SQLite database with a 24-hour expiration check. The app loads instantly even on poor 3G connections.
2. **Draft Listings:** When a merchant creates an ad, the draft is saved locally in Drift first, ensuring no work is lost if the network drops.
3. **Chat Outbox Pattern:**
   - Messages are written locally to Drift with status `pending_send`.
   - When WebSocket connects, pending messages are dispatched and status updates to `sent`.
