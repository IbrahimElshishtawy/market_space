# 06 – Backend Communication & API Integration Design

## 1. Networking Infrastructure Overview

The networking subsystem is implemented under `lib/core/network/` centered around a `DioApiClient` wrapper class ([api_client.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/network/api_client.dart)) configured with standard timeouts, request tracing headers, and four (4) specialized Dio interceptors.

```
DioApiClient (lib/core/network/api_client.dart)
├── Base URL: AppConfig.apiBaseUrl (default: 'https://api.deal-one.com/v1')
├── Connect Timeout: 15,000 ms
├── Receive Timeout: 15,000 ms
├── Send Timeout: 15,000 ms
└── Interceptor Pipeline:
    ├── 1. RequestIdInterceptor (Injects 'x-request-id' UUIDv4)
    ├── 2. AuthInterceptor (Injects 'Authorization: Bearer <token>', handles 401 token refresh)
    ├── 3. RetryInterceptor (Retries 5xx server errors up to 3 times)
    └── 4. NetworkLoggingInterceptor (Logs requests, responses, and errors in debug mode)
```

---

## 2. Interceptor Pipeline Specifications

### 2.1 Request ID Interceptor (`RequestIdInterceptor`)
- **File**: [request_id_interceptor.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/network/interceptors/request_id_interceptor.dart)
- **Function**: Uses the `uuid` package to generate an RFC 4122 version 4 UUID for every outgoing HTTP request, setting the `x-request-id` header to enable distributed tracing and backend log correlation.

### 2.2 Authentication & Token Refresh Interceptor (`AuthInterceptor`)
- **File**: [auth_interceptor.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/network/interceptors/auth_interceptor.dart)
- **Function**:
  1. **Request Phase**: Queries `SecureTokenProvider.getAccessToken()` from encrypted storage and appends `Authorization: Bearer <token>` to request headers if present.
  2. **Error Phase (HTTP 401)**: If a `401 Unauthorized` response is intercepted, it pauses subsequent requests, issues a refresh request to `/auth/token/refresh` using the stored refresh token, updates `SecureTokenProvider`, and retries the original request with the fresh token.

### 2.3 Automatic Retry Interceptor (`RetryInterceptor`)
- **File**: [retry_interceptor.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/network/interceptors/retry_interceptor.dart)
- **Function**:
  - Automatically retries failed requests up to **3 attempts** for transient network disconnects (`DioExceptionType.connectionTimeout`, `sendTimeout`, `receiveTimeout`) and HTTP server errors (`500`, `502`, `503`, `504`).
  - Utilizes exponential backoff: $Delay = BaseDelay \times 2^{attempt}$.

### 2.4 Logging Interceptor (`NetworkLoggingInterceptor`)
- **File**: [network_logging_interceptor.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/network/interceptors/network_logging_interceptor.dart)
- **Function**: Prints formatted cURL commands, headers, JSON payloads, and response latency during debug builds while being silenced in release builds.

---

## 3. Disconnect Between Network Core and Feature Repositories

> [!CRITICAL]
> **Major Architectural Disconnect**:
> While the networking core (`DioApiClient`, interceptors, endpoints, token provider) is fully coded and registered in `AppDependencies`, **none of the feature repositories currently call `ApiClient`**.
>
> All feature repositories (`MockRealEstateRepository`, `BuildingMaterialsRepository`, `HomeServicesRepositoryImpl`, `MockCarsRepository`, `MockFashionRepository`) operate exclusively on hardcoded Dart lists and simulated `Future.delayed()` asynchronous timers.
>
> Consequently, the API endpoints documented below represent the **designed network contract**, not the live runtime data pathway.

---

## 4. Declared API Endpoint Inventory

The following endpoint registry is extracted directly from [lib/core/network/api_endpoints.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/network/api_endpoints.dart):

| Feature Domain | Method | Endpoint Path | Request Model / Body | Response Model / Payload | Implementation File | Status in Mobile |
|---|---|---|---|---|---|---|
| **Auth** | `POST` | `/auth/otp/send` | `{"phoneNumber": "+201..."}` | `{"status": "SENT", "expiresIn": 120}` | `api_endpoints.dart` | **DECLARED / UNWIRED** |
| **Auth** | `POST` | `/auth/otp/verify` | `{"phoneNumber": "...", "otp": "..."}` | `AuthResponse (tokens, user)` | `api_endpoints.dart` | **DECLARED / UNWIRED** |
| **Auth** | `POST` | `/auth/token/refresh` | `{"refreshToken": "..."}` | `{"accessToken": "...", "refreshToken": "..."}` | `api_endpoints.dart` | **DECLARED / UNWIRED** |
| **Real Estate** | `GET` | `/real-estate/listings` | Query params: `page`, `category`, `priceMin`, `city` | `PaginatedList<RealEstateListing>` | `api_endpoints.dart` | **MOCK USED** |
| **Real Estate** | `GET` | `/real-estate/listings/{id}` | Path param: `id` | `RealEstateListing` | `api_endpoints.dart` | **MOCK USED** |
| **Real Estate** | `GET` | `/real-estate/reels` | Query params: `page`, `limit` | `List<RealEstateReel>` | `api_endpoints.dart` | **MOCK USED** |
| **Materials** | `GET` | `/building-materials/daily-prices` | None | `List<DailyPriceQuote>` | `api_endpoints.dart` | **MOCK USED** |
| **Materials** | `GET` | `/building-materials/products` | Query params: `category`, `grade` | `List<MaterialProduct>` | `api_endpoints.dart` | **MOCK USED** |
| **Materials** | `POST` | `/building-materials/rfq` | `RfqRequestPayload` | `{"rfqId": "RFQ-...", "status": "RECEIVED"}` | `api_endpoints.dart` | **MOCK USED** |
| **Services** | `GET` | `/home-services/catalog` | Query params: `category` | `List<ServiceItem>` | `api_endpoints.dart` | **MOCK USED** |
| **Services** | `POST` | `/home-services/bookings` | `ServiceBookingPayload` | `ServiceBookingConfirmation` | `api_endpoints.dart` | **MOCK USED** |
| **Services** | `GET` | `/home-services/bookings/{id}/tracking` | Path param: `id` | `TechnicianTrackingStatus` | `api_endpoints.dart` | **MOCK USED** |
| **Appliances** | `GET` | `/home-appliances/products` | Query params: `category`, `brand` | `List<ApplianceProduct>` | `api_endpoints.dart` | **MOCK USED** |
| **Cars** | `GET` | `/cars/listings` | Query params: `brand`, `model`, `yearMin`, `priceMax` | `List<CarListing>` | `api_endpoints.dart` | **MOCK USED** |
| **Fashion** | `GET` | `/fashion/products` | Query params: `department`, `category` | `List<FashionProduct>` | `api_endpoints.dart` | **MOCK USED** |
| **Profile** | `GET` | `/user/profile` | Header: `Authorization` | `UserProfile` | `api_endpoints.dart` | **MOCK USED** |
| **Notifications** | `GET` | `/notifications` | Query params: `sector`, `unreadOnly` | `List<NotificationItem>` | `api_endpoints.dart` | **MOCK USED** |

---

## 5. Network Error Mapping & Failure Translation

The application defines a structured failure taxonomy in [lib/core/errors/failures.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/errors/failures.dart) and an error mapper in [lib/core/errors/error_handler.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/errors/error_handler.dart):

```mermaid
graph LR
    DioError[DioException] --> ErrorHandler[ErrorHandler.fromDioException()]
    
    ErrorHandler --> BadResponse{HTTP Status}
    BadResponse -->|401| AuthFail[AuthenticationFailure]
    BadResponse -->|403| PermFail[PermissionFailure]
    BadResponse -->|404| NotFoundFail[NotFoundFailure]
    BadResponse -->|422| ValidationFail[ValidationFailure]
    BadResponse -->|5xx| ServerFail[ServerFailure]
    
    ErrorHandler --> ConnectionTimeout[NetworkFailure: Connection Timeout]
    ErrorHandler --> NoInternet[NetworkFailure: No Internet Connection]
```

When converted to `Failure` instances, the error objects carry localized, user-friendly Arabic error strings suitable for display inside `AppErrorView` widgets.
