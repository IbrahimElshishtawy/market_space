# Deal One — Complete API Specification & Inventory

## 1. API Standards & Global Conventions

### 1.1 Base URL & Versioning
- **Base URL:** `https://api.deal-one.eg/api/v1`
- **Protocol:** HTTPS (TLS 1.3 mandatory)
- **Content-Type:** `application/json; charset=utf-8` (Multipart/form-data for media upload requests)
- **Versioning Policy:** Path-based versioning (`/api/v1/`). Non-breaking additions (new response fields) are deployed in-place. Breaking changes increment the major version (`/api/v2/`).

### 1.2 Global Request Headers
| Header | Description | Mandatory? | Example |
|---|---|:---:|---|
| `Authorization` | Bearer JWT Access Token (issued by `/auth/otp/verify`) | Yes (for protected endpoints) | `Bearer eyJhbGciOi...` |
| `X-Account-ID` | Active Seller Account Context UUID | Yes (for seller operations) | `8f7b3c20-4a11-4f1b-9e2a-112233445566` |
| `X-Request-ID` | Client-generated UUID for distributed request tracing | Recommended | `a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11` |
| `Accept-Language` | Client locale preference | Optional (default: `ar`) | `ar` or `en` |
| `X-App-Version` | Mobile Client application version | Recommended | `1.0.0+14` |

### 1.3 Uniform API Response Format

#### Success Envelope (`ApiResponse<T>`):
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "next_cursor": "eyJpZCI6IjhmN2IzYzIwLi4uIiwicmVmcmVzaGVkX2F0IjoiMjAyNi0xMC0xMFQxNDozMDowMFoifQ==",
    "total_count": 142
  }
}
```

#### Error Envelope (`ApiErrorResponse`):
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Validation failed for one or more fields",
    "details": [
      {
        "field": "price",
        "issue": "Price must be greater than or equal to 0"
      }
    ],
    "trace_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
  }
}
```

### 1.4 Cursor-Based Pagination
All feed and list endpoints use opaque Base64 encoded keyset cursor pagination (`next_cursor`) containing `[refreshed_at, id]` to guarantee consistent $O(1)$ database execution without offset degradation or skipped rows when items are concurrently inserted.

---

## 2. Complete API Endpoint Inventory (52 Endpoints)

### Module 1: Authentication & Identity (6 Endpoints)

#### `API-AUTH-001`: Request SMS OTP
- **Endpoint:** `POST /api/v1/auth/otp/send`
- **Purpose:** Dispatches a 6-digit numeric OTP to an Egyptian mobile phone.
- **Auth:** Public.
- **Security:** Rate limited (3 requests per 15 min per IP/phone). Requires Cloudflare Turnstile token.
- **Request Body:**
  ```json
  {
    "phone": "+201012732095",
    "turnstile_token": "0.XXXXX.YYYYY"
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "message": "OTP verification code dispatched successfully",
      "expires_in_seconds": 300
    }
  }
  ```
- **Error Codes:** `429 RATE_LIMIT_EXCEEDED`, `400 INVALID_PHONE_NUMBER`, `403 TURNSTILE_FAILED`.
- **Related Flutter Screen:** `LoginBottomSheet` / `PhoneInputScreen`.

#### `API-AUTH-002`: Verify SMS OTP & Sign In
- **Endpoint:** `POST /api/v1/auth/otp/verify`
- **Purpose:** Validates 6-digit OTP code, provisions user if new, and mints access & refresh tokens.
- **Auth:** Public.
- **Request Body:**
  ```json
  {
    "phone": "+201012732095",
    "code": "583921",
    "device_info": {
      "platform": "android",
      "fcm_token": "fcm_token_sample...",
      "app_version": "1.0.0"
    }
  }
  ```
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "access_token": "eyJhbGciOi...",
      "refresh_token": "4f3c2b1a-8e9d...",
      "user": {
        "id": "usr-uuid-1",
        "phone": "+201012732095",
        "full_name": "إبراهيم الشيشتاوي",
        "avatar_url": null,
        "is_active": true
      },
      "accounts": [
        {
          "id": "acc-uuid-1",
          "display_name": "الشيشتاوي للمقاولات",
          "account_type": "company",
          "verification_status": "approved",
          "role": "owner"
        }
      ]
    }
  }
  ```
- **Error Codes:** `400 INVALID_OR_EXPIRED_OTP`, `403 USER_SUSPENDED`.

#### `API-AUTH-003`: Silent Refresh Token Rotation
- **Endpoint:** `POST /api/v1/auth/token/refresh`
- **Purpose:** Rotates refresh token and issues fresh 15-minute access token.
- **Auth:** Public.
- **Request Body:** `{"refresh_token": "4f3c2b1a-8e9d..."}`
- **Success Response (200 OK):** `{"success": true, "data": {"access_token": "...", "refresh_token": "..."}}`
- **Security:** Automatic reuse detection: if a revoked refresh token is presented, all user sessions are terminated immediately.

#### `API-AUTH-004`: Register / Sign In with Email & Password
- **Endpoint:** `POST /api/v1/auth/password/login`
- **Purpose:** Secondary email/password authentication.
- **Request Body:** `{"email": "user@example.com", "password": "StrongPassword123!", "turnstile_token": "..."}`
- **Security:** Rate limited (5 failed attempts per 15 min lock). Argon2id verification.

#### `API-AUTH-005`: Terminate Session (Logout)
- **Endpoint:** `POST /api/v1/auth/logout`
- **Auth:** Bearer Token.
- **Request Body:** `{"refresh_token": "..."}`
- **Purpose:** Revokes active refresh token and blacklists access token in Redis.

#### `API-AUTH-006`: Terminate All Active Devices
- **Endpoint:** `POST /api/v1/auth/sessions/revoke-all`
- **Auth:** Bearer Token.
- **Purpose:** Revokes all active refresh tokens for the authenticated user.

---

### Module 2: User Profile Management (4 Endpoints)

#### `API-USR-001`: Get My Personal Profile
- **Endpoint:** `GET /api/v1/users/me`
- **Auth:** Bearer Token.
- **Purpose:** Fetches authenticated user's personal details, notification settings, and associated seller accounts.

#### `API-USR-002`: Update My Personal Profile
- **Endpoint:** `PUT /api/v1/users/me`
- **Auth:** Bearer Token.
- **Request Body:** `{"full_name": "إبراهيم محمد", "avatar_url": "https://..."}`

#### `API-USR-003`: Register / Update FCM Device Token
- **Endpoint:** `POST /api/v1/users/me/device`
- **Auth:** Bearer Token.
- **Request Body:** `{"fcm_token": "...", "platform": "android", "app_version": "1.0.0"}`

#### `API-USR-004`: Request Personal Account Deletion
- **Endpoint:** `DELETE /api/v1/users/me`
- **Auth:** Bearer Token.
- **Purpose:** Initiates Egyptian Data Protection compliance soft deletion workflow.

---

### Module 3: Multi-Tenant Accounts & Team RBAC (7 Endpoints)

#### `API-ACC-001`: List My Seller Accounts
- **Endpoint:** `GET /api/v1/accounts/my-accounts`
- **Auth:** Bearer Token.
- **Purpose:** Powers the mobile Account Switcher drawer. Returns all accounts owned or joined by user with member roles.

#### `API-ACC-002`: Create New Seller Account
- **Endpoint:** `POST /api/v1/accounts`
- **Auth:** Bearer Token.
- **Request Body:**
  ```json
  {
    "account_type": "company",
    "display_name": "رويال للاستثمار العقاري",
    "bio": "وسيط عقاري معتمد بالتجمع الخامس والشيخ زايد",
    "logo_url": "https://...",
    "primary_phone": "+201000000000"
  }
  ```
- **Business Rule:** Creates account with `verification_status = 'pending'` and binds caller as `owner`.

#### `API-ACC-003`: Upload Account Verification Documents
- **Endpoint:** `POST /api/v1/accounts/{accountId}/verification-documents`
- **Auth:** Bearer Token (Role: `owner` of account).
- **Request Body:**
  ```json
  {
    "document_type": "commercial_register",
    "document_number": "194820",
    "file_url": "https://storage.deal-one.eg/docs/cr_9482.pdf"
  }
  ```
- **Business Rule:** Enforces mandatory verification documents based on `account_type`.

#### `API-ACC-004`: Get Account Details & Public Profile
- **Endpoint:** `GET /api/v1/accounts/{accountId}`
- **Auth:** Public.
- **Purpose:** Public profile showing active listings, branches, and verification badge.

#### `API-ACC-005`: List Account Team Members
- **Endpoint:** `GET /api/v1/accounts/{accountId}/members`
- **Auth:** Bearer Token (Role: `owner` or `manager`).

#### `API-ACC-006`: Invite Member to Account Team
- **Endpoint:** `POST /api/v1/accounts/{accountId}/members`
- **Auth:** Bearer Token (Role: `owner`).
- **Request Body:** `{"user_phone": "+201122334455", "role": "lister"}`

#### `API-ACC-007`: Remove Member from Account Team
- **Endpoint:** `DELETE /api/v1/accounts/{accountId}/members/{memberId}`
- **Auth:** Bearer Token (Role: `owner`).

---

### Module 4: Branches & Geographic Locations (5 Endpoints)

#### `API-GEO-001`: List Governorates & Cities
- **Endpoint:** `GET /api/v1/locations/taxonomy`
- **Auth:** Public.
- **Cache:** Edge cached (24 hours). Returns full hierarchy of 27 governorates and sub-cities.

#### `API-GEO-002`: List Granular Areas / Neighborhoods
- **Endpoint:** `GET /api/v1/locations/cities/{cityId}/areas`
- **Auth:** Public.
- **Purpose:** Dropdown options for district selection when GPS is disabled.

#### `API-GEO-003`: Add Commercial Branch
- **Endpoint:** `POST /api/v1/accounts/{accountId}/branches`
- **Auth:** Bearer Token (Role: `owner` or `manager`).
- **Request Body:**
  ```json
  {
    "name": "فرع مدينة نصر",
    "area_id": "area-uuid-1",
    "address": "شارع مكرم عبيد، مبنى رقم 14",
    "lat": 30.0561,
    "lng": 31.3301,
    "working_hours": {"sat_thu": "09:00 - 21:00", "fri": "closed"}
  }
  ```

#### `API-GEO-004`: List Account Branches
- **Endpoint:** `GET /api/v1/accounts/{accountId}/branches`
- **Auth:** Public.

#### `API-GEO-005`: Configure Service Coverage Areas
- **Endpoint:** `PUT /api/v1/accounts/{accountId}/service-areas`
- **Auth:** Bearer Token (Role: `owner` or `manager`).
- **Request Body:** `{"area_ids": ["area-uuid-1", "area-uuid-2"], "radius_km": 15}`

---

### Module 5: Categories & Dynamic Attributes Taxonomy (2 Endpoints)

#### `API-CAT-001`: Get Category Taxonomy Tree
- **Endpoint:** `GET /api/v1/categories`
- **Auth:** Public.
- **Purpose:** Powers home feed categories bar and multi-level listing creation selectors across the 6 sectors.

#### `API-CAT-002`: Get Subcategory Dynamic Field Definitions
- **Endpoint:** `GET /api/v1/categories/{categoryId}/fields`
- **Auth:** Public.
- **Purpose:** Returns the dynamic schema, validation rules, min/max constraints, and select options for category-specific attributes (e.g., bedrooms, vehicle transmission, cement specifications).

---

### Module 6: Listings Core & Lifecycle Management (8 Endpoints)

#### `API-LST-001`: Create New Listing (Draft)
- **Endpoint:** `POST /api/v1/listings`
- **Auth:** Bearer Token (Role: `owner`, `manager`, or `lister` in `X-Account-ID`).
- **Purpose:** Initializes a listing draft with orthogonal status `moderation_status = 'draft'`.
- **Request Body:**
  ```json
  {
    "category_id": "cat-cars-uuid",
    "area_id": "area-nasr-city-uuid",
    "branch_id": null,
    "title": "هيونداي إلنترا CN7 موديل 2022 فابريكا بالكامل",
    "description": "صيانات توكيل منتظمة...",
    "price": 850000,
    "listing_kind": "sale",
    "contact_channel": "in_app",
    "physical_lat": 30.056123,
    "physical_lng": 31.330145,
    "attributes": {
      "make": "Hyundai",
      "model": "Elantra CN7",
      "year": 2022,
      "transmission": "automatic",
      "mileage_km": 38000
    }
  }
  ```
- **Business Rule:** Automatically generates `display_location` by applying a 300–600m fuzzing algorithm or using district centroid.

#### `API-LST-002`: Submit Listing for Moderation Review
- **Endpoint:** `POST /api/v1/listings/{listingId}/submit`
- **Auth:** Bearer Token (`owner`, `manager`, `lister`).
- **Security:** Checks Turnstile token and verifies account daily listing quota in Redis.
- **Business Rule:** Validates required media (at least 1 image) and category attribute schema. Transitions `moderation_status` from `'draft'` or `'rejected'` to `'pending'`. Records event in `moderation_log`.

#### `API-LST-003`: Update Listing Details
- **Endpoint:** `PUT /api/v1/listings/{listingId}`
- **Auth:** Bearer Token (`owner`, `manager`, `lister`).
- **Business Rule:** If the listing is already `approved` and published, modifying substantial fields (price, title, media, category) automatically demotes `moderation_status` to `'pending'` and pulls the listing from public search pending re-review.

#### `API-LST-004`: Toggle Listing Visibility (Hide / Show)
- **Endpoint:** `PATCH /api/v1/listings/{listingId}/visibility`
- **Auth:** Bearer Token (`owner`, `manager`, `lister`).
- **Request Body:** `{"publication_status": "hidden"}` (or `"published"`).
- **Business Rule:** Toggles visibility without affecting moderation approval status.

#### `API-LST-005`: Update Operational Availability Status
- **Endpoint:** `PATCH /api/v1/listings/{listingId}/availability`
- **Auth:** Bearer Token (`owner`, `manager`, `lister`).
- **Request Body:** `{"availability_status": "sold"}` (Options: `available`, `reserved`, `sold`, `rented`, `out_of_stock`).

#### `API-LST-006`: Delete Listing (Soft Delete)
- **Endpoint:** `DELETE /api/v1/listings/{listingId}`
- **Auth:** Bearer Token (`owner`, `manager`).

#### `API-LST-007`: Get Public Listing Details
- **Endpoint:** `GET /api/v1/listings/{listingId}`
- **Auth:** Public.
- **Business Rule:** Returns listing only if `moderation_status = 'approved'`, `publication_status = 'published'`, and seller account is active and verified. Exposes only `display_location`. Increments view counter via Redis buffer.

#### `API-LST-008`: List Merchant's Listings (Management Feed)
- **Endpoint:** `GET /api/v1/accounts/{accountId}/listings`
- **Auth:** Bearer Token (Account member).
- **Parameters:** `moderation_status`, `publication_status`, `cursor`, `limit`.

---

### Module 7: Search, PostGIS Geo-Filtering & Explore (3 Endpoints)

#### `API-SRC-001`: Unified Multi-Category Search & Filter
- **Endpoint:** `GET /api/v1/search`
- **Auth:** Public.
- **Parameters:**
  - `q`: Search keywords (Arabic text normalized)
  - `category_slug`: e.g., `real-estate` or `cars`
  - `governorate_slug`: e.g., `cairo`
  - `area_id`: UUID
  - `min_price`, `max_price`: Numeric filters
  - `lat`, `lng`: User GPS coordinates (optional)
  - `radius_km`: PostGIS spatial radius (default: 25 km)
  - `sort_by`: `nearest`, `price_asc`, `price_desc`, `latest`
  - `attributes`: JSON encoded attribute filters (e.g., `{"year": {"gte": 2020}}`)
  - `cursor`: Keyset pagination token
  - `limit`: Integer (default: 20, max: 50)
- **Database Execution:** Executes parameterized PostGIS query:
  ```sql
  ST_DWithin(physical_location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography, :radius_m)
  ORDER BY physical_location <-> ST_SetSRID(ST_MakePoint(:lng, :lat), 4326) ASC
  ```

#### `API-SRC-002`: Home Screen Unified Feed
- **Endpoint:** `GET /api/v1/explore/feed`
- **Auth:** Public.
- **Purpose:** Aggregates featured listings, nearby listings (if GPS provided), and latest verified listings across all 6 sectors.

#### `API-SRC-003`: Reveal External Contact (WhatsApp / Phone)
- **Endpoint:** `POST /api/v1/listings/{listingId}/reveal-contact`
- **Auth:** Bearer Token.
- **Purpose:** Enforces daily contact reveal quota in Redis.
- **Business Rule:** If quota remains, increments daily counter and returns the seller's verified phone number and prefilled WhatsApp link. If quota exhausted, returns `429 DAILY_QUOTA_EXCEEDED`.

---

### Module 8: Media Upload & Processing (2 Endpoints)

#### `API-MED-001`: Request Presigned Cloudflare R2 Upload URL
- **Endpoint:** `POST /api/v1/media/presigned-url`
- **Auth:** Bearer Token.
- **Request Body:**
  ```json
  {
    "file_type": "image/jpeg",
    "file_size_bytes": 2400192,
    "purpose": "listing_image"
  }
  ```
- **Validation:** Enforces maximum file size (10MB for images, 100MB for video) and allowed MIME types (`image/jpeg`, `image/png`, `image/webp`, `video/mp4`).
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "upload_url": "https://r2-upload.deal-one.eg/raw/uuid.jpg?X-Amz-Signature=...",
      "storage_key": "raw/listings/uuid.jpg",
      "public_url": "https://media.deal-one.eg/raw/listings/uuid.jpg",
      "expires_in_seconds": 900
    }
  }
  ```

#### `API-MED-002`: Confirm Media Upload & Enqueue Processing
- **Endpoint:** `POST /api/v1/listings/{listingId}/media`
- **Auth:** Bearer Token (`owner`, `manager`, `lister`).
- **Request Body:** `{"storage_key": "raw/listings/uuid.jpg", "sort_order": 1, "is_primary": true}`
- **Business Rule:** Triggers background BullMQ job to strip EXIF data, compress image, and generate WebP thumbnails.

---

### Module 9: In-App Chat & WebSocket (4 Endpoints + WS Events)

#### `API-CHT-001`: Start or Fetch Conversation
- **Endpoint:** `POST /api/v1/chat/conversations`
- **Auth:** Bearer Token.
- **Request Body:** `{"listing_id": "listing-uuid-1"}`
- **Business Rule:** Enforces daily chat initiation quota. Returns existing conversation if already opened between this buyer and seller.

#### `API-CHT-002`: List My Active Conversations
- **Endpoint:** `GET /api/v1/chat/conversations`
- **Auth:** Bearer Token.

#### `API-CHT-003`: Get Conversation Messages History
- **Endpoint:** `GET /api/v1/chat/conversations/{conversationId}/messages`
- **Auth:** Bearer Token (Must be buyer or account member).
- **Parameters:** `cursor`, `limit`.

#### `API-CHT-004`: Send Message (HTTP Fallback)
- **Endpoint:** `POST /api/v1/chat/conversations/{conversationId}/messages`
- **Auth:** Bearer Token.
- **Request Body:** `{"body": "السلام عليكم، هل المعاينة متاحة غداً؟"}`

#### Real-Time WebSocket Gateway (`/chat`):
- **Events (Client -> Server):** `message:send`, `message:ack_delivered`, `message:ack_read`, `typing:start`.
- **Events (Server -> Client):** `message:new`, `message:status_update`, `user:typing`.

---

### Module 10: Favorites & User Abuse Reports (4 Endpoints)

#### `API-FAV-001`: List My Favorite Listings
- **Endpoint:** `GET /api/v1/favorites`
- **Auth:** Bearer Token.
- **Business Rule:** Returns saved listings with their live availability status banner (`available`, `sold`, etc.) instead of silently deleting them.

#### `API-FAV-002`: Add Listing to Favorites
- **Endpoint:** `POST /api/v1/favorites/{listingId}`
- **Auth:** Bearer Token.

#### `API-FAV-003`: Remove Listing from Favorites
- **Endpoint:** `DELETE /api/v1/favorites/{listingId}`
- **Auth:** Bearer Token.

#### `API-REP-001`: Submit Abuse / Fraud Report
- **Endpoint:** `POST /api/v1/reports`
- **Auth:** Bearer Token.
- **Request Body:**
  ```json
  {
    "listing_id": "listing-uuid-1",
    "reason": "scam",
    "details": "المعلن يطلب تحويل عربون عبر فودافون كاش قبل المعاينة"
  }
  ```

---

### Module 11: Daily Quotas & Notifications (3 Endpoints)

#### `API-QTA-001`: Get Current Daily Quota Balance
- **Endpoint:** `GET /api/v1/quotas/my-usage`
- **Auth:** Bearer Token (`X-Account-ID`).
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "timezone": "Africa/Cairo",
      "resets_at": "2026-11-03T00:00:00+02:00",
      "quotas": {
        "listings": {"used": 1, "limit": 5, "remaining": 4},
        "conversations": {"used": 8, "limit": 20, "remaining": 12},
        "contact_reveals": {"used": 3, "limit": 15, "remaining": 12}
      }
    }
  }
  ```

#### `API-NOT-001`: List My In-App Notifications
- **Endpoint:** `GET /api/v1/notifications`
- **Auth:** Bearer Token.

#### `API-NOT-002`: Mark Notifications as Read
- **Endpoint:** `PATCH /api/v1/notifications/mark-read`
- **Auth:** Bearer Token.
- **Request Body:** `{"notification_ids": ["uuid-1", "uuid-2"]}`

---

### Module 12: Admin Control Center & Moderation (7 Endpoints)

#### `API-ADM-001`: Get Pending Moderation Queue
- **Endpoint:** `GET /api/v1/admin/moderation/pending-listings`
- **Auth:** Staff Token (Permission: `moderation:read`).
- **Parameters:** `category_id`, `cursor`, `limit`.

#### `API-ADM-002`: Approve or Reject Listing
- **Endpoint:** `POST /api/v1/admin/moderation/listings/{listingId}/decision`
- **Auth:** Staff Token (Permission: `moderation:write`).
- **Request Body:**
  ```json
  {
    "decision": "reject",
    "reason_code": "PROHIBITED_WEAPON_OR_REPLICA",
    "notes": "السلعة المعروضة غير مصرح بتداولها طبقاً للائحة"
  }
  ```
- **Business Rule:** Updates `listings.moderation_status`. Inserts immutable record in `moderation_log`. Dispatches instant push notification with reason to seller.

#### `API-ADM-003`: Review Account Verification Requests
- **Endpoint:** `GET /api/v1/admin/verifications/pending`
- **Auth:** Staff Token (Permission: `verifications:read`).

#### `API-ADM-004`: Approve or Reject Seller Account Verification
- **Endpoint:** `POST /api/v1/admin/verifications/{accountId}/decision`
- **Auth:** Staff Token (Permission: `verifications:write`).
- **Request Body:** `{"decision": "approve", "notes": "تم التحقق من السجل التجاري في قاعدة بيانات الغرفة التجارية"}`
- **Business Rule:** Updates `accounts.verification_status = 'approved'`. Releases merchant's approved listings to public search.

#### `API-ADM-005`: Suspend or Restore Account
- **Endpoint:** `PATCH /api/v1/admin/accounts/{accountId}/status`
- **Auth:** Staff Token (Permission: `accounts:manage`).
- **Request Body:** `{"is_active": false, "reason": "fraudulent_activity"}`
- **Business Rule:** Instantly hides all active listings belonging to the account from public search and terminates active sessions.

#### `API-ADM-006`: Update Dynamic Platform Settings & Quotas
- **Endpoint:** `PUT /api/v1/admin/settings/{key}`
- **Auth:** Staff Token (Permission: `settings:manage`).
- **Request Body:** `{"value": {"individual_daily_listings": 3, "company_daily_listings": 30}}`
- **Audit:** Records modification in `audit_log`.

#### `API-ADM-007`: Query System Audit Logs
- **Endpoint:** `GET /api/v1/admin/audit-logs`
- **Auth:** Staff Token (Permission: `audit:read`).
- **Parameters:** `actor_id`, `target_entity`, `from_date`, `to_date`.
