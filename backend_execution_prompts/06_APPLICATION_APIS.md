# Phase 06: Listings Core & 3-Axis Orthogonal Lifecycle

## 1. Role & Objective
You are the Principal Backend Architect. Your objective is to implement the central advertisement entity with orthogonal status management (`moderation_status`, `publication_status`, `availability_status`), two-tier coordinate handling, and daily quota integration.

## 2. Relevant Blueprint Documents
- `backend_blueprint/01_BACKEND_ARCHITECTURE.md` (Section 4.2 Orthogonal Statuses)
- `backend_blueprint/02_DATABASE_DESIGN.md` (Table: `listings`, `listing_media`, `moderation_log`)
- `backend_blueprint/03_API_SPECIFICATION.md` (APIs: API-LST-001 through API-LST-008)

## 3. Exact Implementation Scope
1. Implement `ListingsService` and `ListingsController`:
   - `POST /api/v1/listings`: Create draft (`moderation_status = 'draft'`). Automatically computes fuzzed `display_location` (offset 300–600m from confidential `physical_location`).
   - `POST /api/v1/listings/{id}/submit`: Submits for moderation. Enforces daily quota in Redis. Transitions to `moderation_status = 'pending'`.
   - `PUT /api/v1/listings/{id}`: Substantial edits demote approved listings to `pending`.
   - `PATCH /api/v1/listings/{id}/visibility`: Toggle `published` / `hidden`.
   - `PATCH /api/v1/listings/{id}/availability`: Update `available`, `reserved`, `sold`, etc.
   - `GET /api/v1/listings/{id}`: Public view (only returns `display_location`).
2. Integrate with QuotaService to deduct listing quota on submission.
3. Validate dynamic attributes against category schema before submission.

## 4. Files to Create / Modify
- `backend/src/modules/listings/listings.controller.ts`
- `backend/src/modules/listings/listings.service.ts`
- `backend/src/modules/listings/dto/create-listing.dto.ts`
- `backend/src/modules/listings/dto/update-listing.dto.ts`
- `backend/src/modules/listings/utils/geo-fuzzer.util.ts`

## 5. Acceptance Criteria
- All tests in `backend_tests/functional/test_listings.py` pass.
- Public listing GET response never leaks `physical_lat` or `physical_lng`.
- Updating an approved listing automatically transitions it back to `pending`.
