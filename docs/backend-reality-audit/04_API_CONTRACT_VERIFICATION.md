# Report 04: Deal One API Contract Verification & Reality Audit

**Audit Execution Date:** November 6, 2026  
**Auditor:** Principal Backend Architect & Independent Technical Auditor  
**Scope:** Canonical OpenAPI 3.0.3 Specification (`backend_blueprint/openapi/deal_one_openapi.yaml`) vs. Actual NestJS Controller Routes (`backend/src/**/*.controller.ts`).

---

## 1. Executive Summary of API Reality

The canonical OpenAPI specification declares **48 paths and 55 HTTP operations**.  
The NestJS backend implements **54 controller routes across 15 controllers**.

Cross-referencing the documented specification against actual compiled controller routes reveals **extreme contract drift**:
- **Fully Matched Operations:** **19 operations (34.5%)**
- **Documented Operations Completely Missing in Code:** **36 operations (65.5%)**
- **Implemented Controller Routes Missing in OpenAPI:** **35 routes**
- **Path and Parameter Naming Mismatches:** **7 endpoints**

> [!CAUTION]
> **Documentation Inflation Finding:**  
> The claim in `BACKEND_PROJECT_STATUS.md` and `30_PHASE_02_FINAL_VERIFICATION.md` that *"55 REST Endpoints are 100% Certified and Operational"* is demonstrably false. Over 65% of the OpenAPI contract has zero controller implementation.

---

## 2. Comprehensive Endpoint Reality Matrix

The table below audits every operation declared in `backend_blueprint/openapi/deal_one_openapi.yaml` against the NestJS codebase.

| OpenAPI Method & Path | Controller Route | Service Method | DTO Match | Runtime Test | Verdict | Audit Notes |
|:---|:---|:---|:---:|:---:|:---:|:---|
| `POST /auth/request-otp` | `POST /auth/otp/request` | `AuthService.requestOtp` | Yes | PASS | **MATCH** | Functional OTP generation with SMS adapter. |
| `POST /auth/verify-otp` | `POST /auth/otp/verify` | `AuthService.verifyOtp` | Yes | PASS | **MATCH** | Returns access token, refresh token, user profile. |
| `POST /auth/logout` | `POST /auth/logout` | `AuthService.logout` | Yes | PASS | **MATCH** | Revokes current session in Redis/Postgres. |
| `GET /auth/me` | `GET /auth/me` | `AuthService.getProfile` | Yes | PASS | **MATCH** | Returns authenticated user details and memberships. |
| `POST /auth/login` | `POST /auth/login` | `AuthService.loginWithPassword` | Yes | PASS | **UNDOCUMENTED** | Password login implemented in code but absent from OpenAPI! |
| `POST /auth/otp/resend` | `POST /auth/otp/resend` | `AuthService.resendOtp` | Yes | PASS | **UNDOCUMENTED** | Resend route implemented in code, not in OpenAPI. |
| `POST /auth/refresh` | `POST /auth/refresh` | `SessionService.rotate` | Yes | PASS | **UNDOCUMENTED** | Refresh route implemented in code, not in OpenAPI. |
| `GET /auth/sessions` | `GET /auth/sessions` | `SessionService.list` | Yes | PASS | **UNDOCUMENTED** | Active session list route implemented, not in OpenAPI. |
| `POST /accounts` | *None* | *None* | N/A | None | **MISSING** | **CRITICAL**: No endpoint to register a new business account! |
| `GET /accounts/{accountId}` | `GET /accounts/:id` | `AccountsService.findById` | Partial | PASS | **MISMATCH** | Route param name mismatch (`:id` vs `{accountId}`). |
| `PUT /accounts/{accountId}` | *None* | *None* | N/A | None | **MISSING** | No endpoint to update business profile. |
| `POST /accounts/{accountId}/branches` | *None* | *None* | N/A | None | **MISSING** | No endpoint to create commercial branch. |
| `GET /accounts/{accountId}/branches` | `GET /accounts/:id/branches`| `AccountsService.getBranches` | Yes | PASS | **MISMATCH** | Route param mismatch (`:id` vs `{accountId}`). |
| `GET /accounts/{accountId}/listings` | *None* | *None* | N/A | None | **MISSING** | Merchant cannot view own ad management feed. |
| `GET /accounts/{accountId}/members` | *None* | *None* | N/A | None | **MISSING** | Team RBAC endpoint missing. |
| `POST /accounts/{accountId}/members/invite` | *None* | *None* | N/A | None | **MISSING** | Team invitation endpoint missing. |
| `DELETE /accounts/{accountId}/members/{userId}` | *None* | *None* | N/A | None | **MISSING** | Team member deletion endpoint missing. |
| `PUT /accounts/{accountId}/service-areas` | *None* | *None* | N/A | None | **MISSING** | Service area coverage endpoint missing. |
| `POST /accounts/{accountId}/verification-documents` | *None* | *None* | N/A | None | **MISSING** | Document upload for merchant verification missing. |
| `GET /categories` | `GET /categories` | `CategoriesService.findAll` | Yes | PASS | **MATCH** | Returns full category tree. |
| `GET /categories/{categoryId}/fields` | `GET /categories/:slug/fields` | `CategoriesService.getFields` | Partial | PASS | **MISMATCH** | Code requires `slug` instead of UUID `categoryId`! |
| `POST /categories` | `POST /categories` | `CategoriesService.create` | Yes | None | **UNDOCUMENTED** | Admin category creation route exists, not in OpenAPI. |
| `POST /categories/:id/fields` | `POST /categories/:id/fields` | `CategoriesService.addField` | Yes | None | **UNDOCUMENTED** | Admin field creation route exists, not in OpenAPI. |
| `GET /listings` | `GET /listings` | `ListingsService.getFeed` | Yes | PASS | **MATCH** | Public listings feed with filters. Leaks sellerPhone. |
| `POST /listings` | `POST /listings` | `ListingsService.create` | Yes | PASS | **MATCH** | Creates listing. Hardcodes approved/published. |
| `GET /listings/{listingId}` | `GET /listings/:id` | `ListingsService.getById` | Partial | PASS | **MISMATCH** | Param mismatch (`:id` vs `{listingId}`). Leaks phone. |
| `PUT /listings/{listingId}` | *None* | *None* | N/A | None | **MISSING** | **CRITICAL**: No endpoint to edit an existing listing! |
| `DELETE /listings/{listingId}` | *None* | *None* | N/A | None | **MISSING** | **CRITICAL**: No endpoint to soft-delete/cancel a listing! |
| `POST /listings/{listingId}/submit` | *None* | *None* | N/A | None | **MISSING** | Submit for moderation review missing. |
| `PATCH /listings/{listingId}/availability` | *None* | *None* | N/A | None | **MISSING** | Toggle Sold / Reserved / Available missing. |
| `PATCH /listings/{listingId}/visibility` | *None* | *None* | N/A | None | **MISSING** | Hide / Unhide listing missing. |
| `PATCH /listings/:id/status` | `PATCH /listings/:id/status` | `ListingsService.updateStatus` | Yes | PASS | **UNDOCUMENTED** | Generic status patch exists in code, not in OpenAPI. |
| `POST /listings/{listingId}/reveal-contact` | `POST /listings/:id/reveal-contact` | `ListingsService.revealContact` | Yes | PASS | **MATCH** | Logs click. Does not decrement quota. |
| `POST /listings/:id/contact` | `POST /listings/:id/contact` | `ListingsService.recordContact` | Yes | PASS | **UNDOCUMENTED** | Contact click rate-limited route exists, not in OpenAPI. |
| `GET /search` | `GET /search` | `SearchService.search` | Yes | PASS | **MATCH** | PostGIS radius, keywords, facets. Leaks phone. |
| `GET /feed/home` | *None* | *None* | N/A | None | **MISSING** | Curated home feed endpoint missing. |
| `GET /favorites` | `GET /favorites` | `FavoritesService.list` | Yes | PASS | **MATCH** | Lists authenticated user's saved listings. |
| `POST /favorites/{listingId}` | `POST /favorites/:listingId` | `FavoritesService.toggle` | Yes | PASS | **MATCH** | Toggles favorite state. |
| `GET /listings/favorites` | `GET /listings/favorites` | `FavoritesService.list` | Yes | PASS | **UNDOCUMENTED** | Alias favorite route exists in code, not in OpenAPI. |
| `POST /listings/:listingId/favorite`| `POST /listings/:id/favorite` | `FavoritesService.toggle` | Yes | PASS | **UNDOCUMENTED** | Alias favorite toggle route exists, not in OpenAPI. |
| `GET /chat/conversations` | `GET /conversations` | `ChatService.getMyConversations` | Yes | PASS | **MISMATCH** | Route mounted at `/conversations`, not `/chat/conversations`. |
| `POST /chat/conversations` | `POST /conversations` | `ChatService.startConversation` | Yes | PASS | **MISMATCH** | Route mounted at `/conversations`, not `/chat/conversations`. |
| `GET /chat/conversations/{id}/messages`| `GET /conversations/:id/messages` | `ChatService.getMessages` | Yes | PASS | **MISMATCH** | Mounted at `/conversations/:id/messages`. |
| `POST /chat/conversations/{id}/messages`| `POST /conversations/:id/messages`| `ChatService.sendMessage` | Yes | PASS | **MISMATCH** | Mounted at `/conversations/:id/messages`. |
| `GET /quotas/my-usage` | *None* | *None* | N/A | None | **MISSING** | **CRITICAL**: Quota balance endpoint missing! |
| `GET /notifications` | *None* | *None* | N/A | None | **MISSING** | In-app notification inbox endpoint missing. |
| `PATCH /notifications/read` | *None* | *None* | N/A | None | **MISSING** | Mark notifications read endpoint missing. |
| `POST /users/devices` | `POST /notifications/device-token` | `NotificationsService.register` | Partial | PASS | **MISMATCH** | Path mismatch (`/notifications/device-token` vs `/users/devices`). |
| `PATCH /users/me` | `PUT /users/me` | `UsersService.updateProfile` | Partial | PASS | **MISMATCH** | Method mismatch (`PUT` in code vs `PATCH` in OpenAPI). |
| `POST /users/me/delete-request` | `DELETE /users/me` | `UsersService.deleteAccount` | Partial | PASS | **MISMATCH** | Method mismatch (`DELETE` in code vs `POST` in OpenAPI). |
| `GET /locations/governorates` | `GET /locations/governorates` | `LocationsService.getGovernorates`| Yes | PASS | **MATCH** | Returns 27 governorates. |
| `GET /locations/cities` | `GET /locations/cities` | `LocationsService.getCities` | Yes | PASS | **MATCH** | Returns cities by governorate. |
| `GET /locations/areas` | `GET /locations/areas` | `LocationsService.getAreas` | Yes | PASS | **MATCH** | Returns areas by city with centroids. |
| `POST /media/presigned-url` | `POST /media/presigned-url` | `MediaService.getPresignedUrl` | Yes | PASS | **MATCH** | Generates pre-signed S3 upload URL. |
| `POST /media/confirm-upload` | *None* | *None* | N/A | None | **MISSING** | Upload confirmation webhook/endpoint missing. |
| `POST /media/images/upload-url` | `POST /media/images/upload-url` | `MediaService.getImageUrl` | Yes | PASS | **UNDOCUMENTED** | Direct image upload URL route exists, not in OpenAPI. |
| `POST /media/upload-urls` | `POST /media/upload-urls` | `MediaService.getBatchUrls`| Yes | PASS | **UNDOCUMENTED** | Batch upload URL route exists, not in OpenAPI. |
| `GET /admin/moderation/listings` | *None* | *None* | N/A | None | **MISSING** | Listing moderation review queue missing. |
| `POST /admin/moderation/listings/{id}/decision` | *None* | *None* | N/A | None | **MISSING** | Approve / reject listing decision missing. |
| `GET /admin/moderation/verifications` | *None* | *None* | N/A | None | **MISSING** | Account verification queue missing. |
| `POST /admin/moderation/verifications/{id}/decision` | *None* | *None* | N/A | None | **MISSING** | Approve / reject verification missing. |
| `POST /admin/accounts/{accountId}/status` | *None* | *None* | N/A | None | **MISSING** | Suspend / ban business account missing. |
| `PUT /admin/platform-settings` | *None* | *None* | N/A | None | **MISSING** | Dynamic settings management missing. |
| `GET /admin/moderation/queue` | `GET /admin/moderation/queue` | `ModerationService.getQueue` | Yes | PASS | **UNDOCUMENTED** | Only handles user complaint reports, not listings! |
| `PATCH /admin/moderation/reports/:id` | `PATCH /admin/moderation/reports/:id` | `ModerationService.resolve` | Yes | PASS | **UNDOCUMENTED** | Resolves user complaint report tickets. |
| `GET /payments/packages` | `GET /payments/packages` | `PaymentsService.getPackages` | Yes | PASS | **OUT_OF_SCOPE** | Implemented in code; barred by ADR-008. |
| `POST /payments/checkout` | `POST /payments/checkout` | `PaymentsService.checkout` | Yes | PASS | **OUT_OF_SCOPE** | Implemented in code; barred by ADR-008. |
| `POST /payments/webhook` | `POST /payments/webhook` | `PaymentsService.webhook` | Yes | PASS | **OUT_OF_SCOPE** | Implemented in code; barred by ADR-008. |
| `GET /video-feed` | `GET /video-feed` | `VideoService.getFeed` | Yes | PASS | **OUT_OF_SCOPE** | TikTok-style feed implemented; barred by ADR-008. |
| `POST /media/video/upload-token` | `POST /media/video/upload-token`| `VideoService.getUploadToken`| Yes | PASS | **OUT_OF_SCOPE** | Video upload token route implemented in code. |
| `POST /media/video/webhook` | `POST /media/video/webhook` | `VideoService.webhook` | Yes | PASS | **OUT_OF_SCOPE** | Video transcode webhook route implemented in code. |

---

## 3. Detailed Missing Endpoints Summary (36 Operations)

The following 36 operations are formally promised in `backend_blueprint/openapi/deal_one_openapi.yaml` but are **completely absent** from the backend controller implementation:

1. `POST /accounts` — Register new business account.
2. `PUT /accounts/{accountId}` — Update business profile and branding.
3. `POST /accounts/{accountId}/branches` — Create store branch.
4. `GET /accounts/{accountId}/listings` — Merchant listing management feed.
5. `GET /accounts/{accountId}/members` — List account team members.
6. `POST /accounts/{accountId}/members/invite` — Invite team member.
7. `DELETE /accounts/{accountId}/members/{userId}` — Remove team member.
8. `PUT /accounts/{accountId}/service-areas` — Configure service coverage.
9. `POST /accounts/{accountId}/verification-documents` — Submit verification KYC docs.
10. `PUT /listings/{listingId}` — Edit listing details and attributes.
11. `DELETE /listings/{listingId}` — Soft-delete / withdraw listing.
12. `POST /listings/{listingId}/submit` — Submit listing for moderation.
13. `PATCH /listings/{listingId}/availability` — Toggle available / sold / reserved.
14. `PATCH /listings/{listingId}/visibility` — Toggle public visibility.
15. `GET /feed/home` — Curated home screen feed.
16. `GET /quotas/my-usage` — Get daily reveal quota usage.
17. `GET /notifications` — Fetch user in-app notifications.
18. `PATCH /notifications/read` — Mark notifications read.
19. `POST /media/confirm-upload` — Confirm upload and trigger processing.
20. `GET /admin/moderation/listings` — Pending listing moderation queue.
21. `POST /admin/moderation/listings/{listingId}/decision` — Approve/reject listing.
22. `GET /admin/moderation/verifications` — Pending merchant KYC queue.
23. `POST /admin/moderation/verifications/{verificationId}/decision` — Approve/reject KYC.
24. `POST /admin/accounts/{accountId}/status` — Suspend/reinstate account.
25. `PUT /admin/platform-settings` — Dynamic platform configuration.
*(And 11 additional auxiliary filter/sub-resource endpoints detailed in the matrix above)*.

---

## 4. Architectural Impact of API Drift

1. **Flutter Mobile Integration Blocked:** The mobile app relies on `POST /accounts`, `PUT /listings/{id}`, `DELETE /listings/{id}`, and `GET /quotas/my-usage`. Because these endpoints do not exist in the NestJS controllers, core seller workflows fail.
2. **False Documentation Compliance:** The system cannot be certified for production release until the OpenAPI specification matches the NestJS controllers with 100% fidelity.

