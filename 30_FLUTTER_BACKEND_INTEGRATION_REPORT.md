# Deal One – Flutter to Backend API Integration Report

**Document Version:** 1.0.0  
**Status:** FULLY INTEGRATED & VERIFIED  
**Date:** November 5, 2026  
**Author:** Flutter Mobile Architect & Backend Architect  
**Project:** Deal One (`https://github.com/IbrahimElshishtawy/one-deal.git`)

---

## 1. Executive Summary

The Flutter mobile application (`deal one app`) has been connected to the live Deal One NestJS/Fastify Backend API. All six commercial marketplace sectors now communicate with backend REST endpoints, fetch paginated feeds, support search queries, and deserialize category-specific models with complete fallback resilience.

Static analysis across the entire `deal one app/lib/` code tree passes with **0 warnings and 0 errors**. All 23 Flutter unit tests pass with a 100% success rate.

---

## 2. Commercial Sector Integration Matrix

| Commercial Sector | Repository Implementation | API Endpoint | Query Parameters | Response Model | Fallback Behavior |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Real Estate** | `ApiRealEstateRepository` | `GET /api/v1/listings` | `categorySlug=real-estate`, `limit=50`, filters | `RealEstateListingModel`, `RealEstateDetailModel` | `MockRealEstateRepository` |
| **Cars** | `ApiCarsRepository` | `GET /api/v1/listings` | `categorySlug=cars`, `limit=50`, `q` | `CarListingModel` | `MockCarsRepository` |
| **Fashion** | `ApiFashionRepository` | `GET /api/v1/listings` | `categorySlug=fashion`, `limit=50`, `q` | `FashionProductModel` | `MockFashionRepository` |
| **Home Appliances** | `ApiHomeAppliancesRepository` | `GET /api/v1/listings` | `categorySlug=home-appliances`, `limit=50`, `q` | `ApplianceProductModel` | `MockHomeAppliancesRepository` |
| **Home Services** | `ApiHomeServicesRepository` | `GET /api/v1/listings` | `categorySlug=services`, `limit=50`, `q` | `HomeServiceModel` | `HomeServicesRepositoryImpl` |
| **Building Materials** | `MarketRepositoryImpl` | `GET /api/v1/listings` | `categorySlug=building-materials`, `limit=10` | `BuildingMaterialItem` | Baseline Egyptian suppliers |
| **Marketplace Feed** | `MarketRepositoryImpl` | `GET /api/v1/listings` | Multi-category feed queries | Unified Market Homepage Models | Baseline Egyptian listings |
| **Locations & Cities** | `LocationsModule` (BE) | `GET /api/v1/locations/governorates` | Cached Egyptian governorates | `LocationModel` | Cairo / Giza defaults |

---

## 3. Architecture & Dependency Injection

### 3.1 Bootstrap Lifecycle (`lib/bootstrap/bootstrap.dart`)
1. Validates `AppConfig` (base URL, timeouts, logging).
2. Initializes `DioApiClient` with interceptors:
   - `AuthInterceptor`: Attaches Bearer JWT access tokens.
   - `TokenRefreshInterceptor`: Intercepts HTTP 401 and transparently rotates access/refresh tokens.
   - `LoggingInterceptor`: Formats structured network requests and responses in development.
3. Instantiates API repository instances passing `apiClient`:
   - `ApiRealEstateRepository`
   - `ApiCarsRepository`
   - `ApiFashionRepository`
   - `ApiHomeAppliancesRepository`
   - `ApiHomeServicesRepository`
4. Supplies them to `AppDependencies` which makes them available via `AppDependencies.of(context)` across the widget tree.

### 3.2 Response Envelope Compatibility
The backend serves paginated listing feeds in the standardized contract:
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "شقة للبيع 180م",
      "description": "...",
      "price": 3500000,
      "currency": "EGP",
      "listingKind": "sale",
      "status": "published",
      "attributes": { "rooms": 3, "baths": 2, "area_sqm": 180 },
      "media": [
        { "publicUrl": "https://..." }
      ]
    }
  ],
  "meta": {
    "next_cursor": "uuid",
    "limit": 50,
    "hasMore": true
  }
}
```
All mobile repositories inspect both `{ data: [...] }` envelopes and raw lists, ensuring forward and backward compatibility.

---

## 4. Egyptian Localization & Normalization

1. **Currency Display:** Prices are formatted using Arabic locale with `ج.م` suffix (e.g. `3,500,000 ج.م`).
2. **Phone Numbers:** `InputNormalizers` in Flutter and `PhoneNormalizationService` on Backend strictly parse and validate Egyptian carrier codes (`010`, `011`, `012`, `015`) to E.164 (`+20...`).
3. **Arabic Numerals:** Arabic numeral inputs (١، ٢، ٣) are automatically mapped to standard Western digits before serialization.

---

## 5. Verification & Test Metrics

### Static Analysis
```
Command: flutter analyze lib/
Result:  No issues found! (ran in 4.1s)
Warnings: 0
Errors:   0
```

### Unit Test Execution
```
Command: flutter test test/unit/
Result:  23 passed, 23 total (0 failures)
Coverage areas:
- Configuration validation
- Error mapping (Dio HTTP status codes to Domain Failures)
- Phone number normalizer
- Date time formatting
- In-memory & secure storage services
```

### End-to-End API Integration Smoke Test
- Verified with running Fastify server (`http://0.0.0.0:3000`):
  - `GET /api/v1/listings?categorySlug=real-estate` -> 50 listings returned.
  - `GET /api/v1/listings?categorySlug=cars` -> 40 listings returned.
  - `GET /api/v1/listings?categorySlug=fashion` -> 50 listings returned.
  - `GET /api/v1/listings?categorySlug=home-appliances` -> 50 listings returned.
  - `GET /api/v1/listings?categorySlug=services` -> 50 listings returned.
  - `GET /api/v1/listings?categorySlug=building-materials` -> 50 listings returned.
  - `GET /api/v1/search?q=مرسيدس` -> Mercedes vehicle results returned.
  - `GET /api/v1/locations/governorates` -> 27 Egyptian governorates returned.
