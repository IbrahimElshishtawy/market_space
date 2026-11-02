# Phase 07: PostGIS Spatial Search & Dynamic Faceted Filtering

## 1. Role & Objective
You are the Database & Performance Engineer. Your objective is to build the high-speed multi-category search engine utilizing PostGIS spatial indexing (`ST_DWithin`, `ST_Distance`), GIN indexing over JSONB attributes, and keyset cursor pagination.

## 2. Relevant Blueprint Documents
- `backend_blueprint/01_BACKEND_ARCHITECTURE.md` (Section 3: Scalability Strategy)
- `backend_blueprint/02_DATABASE_DESIGN.md` (Section 3 Table 16: Indexing Strategy)
- `backend_blueprint/03_API_SPECIFICATION.md` (API-SRC-001, API-SRC-002, API-SRC-003)

## 3. Exact Implementation Scope
1. Implement `SearchService` and `SearchController`:
   - `GET /api/v1/search`: Handles text queries (normalized Arabic), category slug, area ID, price ranges, PostGIS GPS radius distance sorting, and dynamic attribute filtering (`attributes @> :criteria`).
   - `GET /api/v1/explore/feed`: Aggregates featured, nearby, and latest listings.
   - `POST /api/v1/listings/{id}/reveal-contact`: Checks & deducts daily contact reveal quota in Redis, then returns phone/WhatsApp link.
2. Implement keyset cursor pagination (`refreshed_at DESC, id DESC`) encoded as Base64.
3. Optimize queries to ensure only approved, published, available listings with active, verified accounts are returned.

## 4. Files to Create / Modify
- `backend/src/modules/search/search.controller.ts`
- `backend/src/modules/search/search.service.ts`
- `backend/src/modules/search/dto/search-query.dto.ts`
- `backend/src/modules/search/utils/cursor-pagination.util.ts`

## 5. Acceptance Criteria
- All tests in `backend_tests/functional/test_search.py` pass.
- Spatial radius searches execute in < 150ms on database with 10k test records.
- Denying GPS gracefully falls back to administrative district filtering without errors.
