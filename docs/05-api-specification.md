# REST API Specification — Market Space
**API Version:** v1  
**Base URL:** `https://api.marketspace.eg/api/v1`  
**OpenAPI Specification:** [`docs/openapi.yaml`](./openapi.yaml)  

---

## 1. Conventions & Standards

### 1.1 Transport & Headers
- **Transport:** HTTPS exclusively (TLS 1.3 preferred, TLS 1.2 minimum).
- **Format:** `application/json` for all request and response bodies.
- **Localization:** `Accept-Language: ar` (default) or `Accept-Language: en`. Error messages and taxonomy labels respect this header.
- **Tracing:** `X-Request-Id` UUID passed in headers. If omitted, the API gateway generates one and reflects it in the response header.
- **Idempotency:** State-altering operations (e.g., payments, listings creation) accept an optional `Idempotency-Key` header (UUID) to prevent duplicate actions.

### 1.2 Standard Response Envelopes

#### Success Envelope
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 142,
    "next_cursor": "eyJjcmVhdGVkX2F0IjoiMjAyNi0xMC0xMFQ..."
  }
}
```

#### Error Envelope (RFC 7807 Inspired)
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Invalid request parameters provided.",
    "details": [
      {
        "field": "phone",
        "issue": "Phone number must be a valid Egyptian mobile starting with +20"
      }
    ],
    "requestId": "4c43ad1a-829b-4e89-a2e6-a05d21051fa8",
    "timestamp": "2026-10-10T03:55:00Z"
  }
}
```

---

## 2. Authentication & Authorization

- **Scheme:** `Authorization: Bearer <access_token>` (JWT, valid for 15 minutes).
- **Refresh Flow:** Long-lived `refreshToken` (valid for 30 days) stored securely in mobile keystore or HTTP-only cookies for admin web.
- **Roles:**
  - `PUBLIC`: Unauthenticated visitor.
  - `USER`: Verified marketplace consumer or seller.
  - `MODERATOR`: Operations team member with access to moderation and report queues.
  - `SUPER_ADMIN`: Full access to configuration, taxonomy builder, finances, and system audit logs.

---

## 3. Core MVP Endpoint Catalog

### 3.1 Authentication Module (`/auth`)

| Method | Endpoint | Access | Purpose & Side Effects |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/otp/send` | Public | Dispatches 6-digit SMS OTP to Egyptian phone number. Rate-limited to 3/15m. |
| `POST` | `/auth/otp/verify` | Public | Verifies OTP code; returns Access Token and Refresh Token. Creates account if new. |
| `POST` | `/auth/login` | Public | Phone + Password authentication fallback. |
| `POST` | `/auth/refresh` | Public | Rotates Refresh Token and issues new 15-minute Access Token. |
| `POST` | `/auth/logout` | Authenticated | Revokes active session and invalidates the submitted Refresh Token. |

---

### 3.2 Category & Dynamic Fields Module (`/categories`)

| Method | Endpoint | Access | Purpose & Schema Details |
| :--- | :--- | :--- | :--- |
| `GET` | `/categories` | Public | Returns complete tree of root categories and subcategories with icons and localized names. |
| `GET` | `/categories/{slug}/fields` | Public | Returns active dynamic attribute schemas (e.g. car make, year, bedrooms) with validation rules. |
| `POST` | `/admin/categories` | Admin | Creates new root or subcategory. |
| `PUT` | `/admin/categories/{id}/fields` | Admin | Updates or appends dynamic attribute definitions for a subcategory. |

---

### 3.3 Listings Module (`/listings`)

| Method | Endpoint | Access | Description & Validation |
| :--- | :--- | :--- | :--- |
| `GET` | `/listings` | Public | Public feed with cursor pagination, filtered by category, governorate, city, price range, condition. |
| `GET` | `/listings/{id}` | Public | Full listing details: attributes, image URLs, video streaming link, seller summary. Increments view counter. |
| `POST` | `/listings` | User | Submits new listing. Validates dynamic attributes against category schema; verifies uploaded media keys. |
| `PUT` | `/listings/{id}` | Owner / Admin | Updates listing details, attributes, or reorders images. Resets to `PENDING_REVIEW` if title/desc altered. |
| `PATCH` | `/listings/{id}/status` | Owner / Admin | Transitions status: `PAUSED`, `SOLD`, or `ARCHIVED`. |
| `POST` | `/listings/{id}/contact` | Public / User | Records buyer contact intent (Call/WhatsApp) and returns seller phone number. Increments contact count. |

---

### 3.4 Media & Video Module (`/media`)

| Method | Endpoint | Access | Description & Flow |
| :--- | :--- | :--- | :--- |
| `POST` | `/media/images/upload-url` | User | Issues presigned Cloudflare R2 / S3 PUT URLs for 1 to 10 photos (max 8MB each, image/jpeg, image/png, image/webp). |
| `POST` | `/media/video/upload-token` | User | Requests direct video upload token from Cloudflare Stream for up to 30s video. |
| `POST` | `/media/video/webhook` | Webhook | Cloudflare Stream webhook callback notifying when video encoding is ready or failed. |

---

### 3.5 Search & Discovery Module (`/search`)

| Method | Endpoint | Access | Description & Parameters |
| :--- | :--- | :--- | :--- |
| `GET` | `/search` | Public | Fuzzy full-text search via `pg_trgm` query param `q`, supporting Arabic/English matching, faceted filters, and sorting. |
| `GET` | `/video-feed` | Public | Vertical reel feed returning published listings that possess an approved Cloudflare Stream video. |

---

### 3.6 Communication Module (`/conversations`)

| Method | Endpoint | Access | Description & Access Control |
| :--- | :--- | :--- | :--- |
| `GET` | `/conversations` | User | Returns user's active conversations sorted by `last_message_at DESC`. |
| `POST` | `/conversations` | User | Starts conversation bound to `(listing_id, buyer_id)`. |
| `GET` | `/conversations/{id}/messages`| Participant | Returns paginated message history. Automatically marks unread messages as read. |
| `POST` | `/conversations/{id}/messages`| Participant | Dispatches a text message and triggers FCM push notification to the recipient. |

---

### 3.7 Payments & Monetization Module (`/payments`)

| Method | Endpoint | Access | Description & Security |
| :--- | :--- | :--- | :--- |
| `GET` | `/payments/packages` | Public | Returns available promotion packages (`BUMP_UP`, `FEATURED_7_DAYS`, `FEATURED_14_DAYS`) with EGP prices. |
| `POST` | `/payments/checkout` | User | Initiates Paymob payment session for a listing promotion. Returns checkout iframe/app redirect URL. |
| `POST` | `/payments/webhook` | Webhook | Verifies Paymob HMAC SHA512 signature, processes transaction result idempotently, and activates promotions. |

---

### 3.8 Moderation & Back-Office (`/admin`)

| Method | Endpoint | Access | Description & Permissions |
| :--- | :--- | :--- | :--- |
| `GET` | `/admin/moderation/queue` | Moderator | Lists listings in `PENDING_REVIEW` or flagged by automated filters. |
| `PATCH` | `/admin/moderation/listings/{id}` | Moderator | Approves or rejects listing with standard reason codes (`PROHIBITED`, `SPAM`, `PRICE_MISMATCH`). |
| `GET` | `/admin/reports` | Moderator | Lists user abuse reports with status and target links. |
| `POST` | `/reports` | User | Submits abuse report for listing, user, or conversation. |
| `GET` | `/admin/audit-logs` | Super Admin| Immutable log of administrative decisions, schema edits, and status changes. |
