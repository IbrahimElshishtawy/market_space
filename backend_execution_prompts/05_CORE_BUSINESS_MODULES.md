# Phase 05: Core Business Modules (Geo, Branches & Categories)

## 1. Role & Objective
You are the Senior Backend Engineer. Your objective is to build the core taxonomy and geography services: Egypt governorates/cities/areas, commercial branches with PostGIS GPS coordinates, and the two-level category tree with dynamic attribute schemas.

## 2. Relevant Blueprint Documents
- `backend_blueprint/02_DATABASE_DESIGN.md` (Tables: `governorates`, `cities`, `areas`, `branches`, `categories`, `category_fields`)
- `backend_blueprint/03_API_SPECIFICATION.md` (APIs: API-GEO-001 through 005, API-CAT-001, API-CAT-002)

## 3. Exact Implementation Scope
1. Implement `LocationsService` and `LocationsController`:
   - `GET /api/v1/locations/taxonomy` (Cached in Redis for 24h)
   - `GET /api/v1/locations/cities/{id}/areas`
   - `POST /api/v1/accounts/{accountId}/branches` (Stores `GEOMETRY(Point, 4326)` for branch location)
   - `GET /api/v1/accounts/{accountId}/branches`
2. Implement `CategoriesService` and `CategoriesController`:
   - `GET /api/v1/categories` (Root categories and nested subcategories across 6 sectors)
   - `GET /api/v1/categories/{id}/fields` (Returns dynamic attribute rules, types, min/max, select options)
3. Implement dynamic field schema validator evaluating arbitrary JSON attributes against `category_fields`.

## 4. Files to Create / Modify
- `backend/src/modules/locations/locations.controller.ts`
- `backend/src/modules/locations/locations.service.ts`
- `backend/src/modules/categories/categories.controller.ts`
- `backend/src/modules/categories/categories.service.ts`
- `backend/src/modules/categories/validators/dynamic-attribute.validator.ts`

## 5. Acceptance Criteria
- Full test pass in `backend_tests/functional/test_categories.py`.
- Subcategory dynamic fields properly validate numeric ranges and required flags.
- Branch creation validates GPS coordinates inside Egypt boundaries.
