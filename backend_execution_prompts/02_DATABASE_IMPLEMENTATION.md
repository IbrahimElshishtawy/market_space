# Phase 02: Database Implementation & Migrations

## 1. Role & Objective
You are the Database Architect. Your objective is to translate the 24-table PostGIS schema from `02_DATABASE_DESIGN.md` into an audited, production-grade Prisma schema, generate database migrations, and build a deterministic seeder for Egyptian geographical data.

## 2. Relevant Blueprint Documents
- `backend_blueprint/02_DATABASE_DESIGN.md` (Full 24-table schema, constraints, GIST & GIN indexes)
- `backend_blueprint/16_AUDIT_REPORTS/01_DOCUMENTATION_CONFLICT_AUDIT.md` (Conflict 2 & 3 refactoring mandates)

## 3. Exact Implementation Scope
1. Replace `backend/prisma/schema.prisma` with the complete 24-entity schema:
   - Separate `users` from `accounts` and `account_members` (ADR-005).
   - Implement the 3 orthogonal status axes (`moderation_status`, `publication_status`, `availability_status`) on `listings` (ADR-007).
   - Add `moderation_log` and `audit_log` append-only tables.
   - Configure PostGIS geometry fields for `physical_location` and `display_location`.
2. Generate migration `init_deal_one_production_schema` using `npx prisma migrate dev`.
3. Create `backend/prisma/seeds/seed.ts` populating:
   - 27 Egyptian Governorates and major Cities.
   - 6 Core Categories (`real-estate`, `cars`, `building-materials`, `services`, `fashion`, `appliances-decor`).
   - Default `platform_settings` with Cairo midnight quota configurations.

## 4. Files to Create / Modify
- `backend/prisma/schema.prisma`
- `backend/prisma/seeds/seed.ts`
- `backend/prisma/migrations/*`

## 5. Acceptance Criteria
- Database migrations execute without errors.
- Foreign key constraints, unique indexes, and defaults match `02_DATABASE_DESIGN.md` 100%.
- Running `npm run prisma:seed` successfully populates all initial master data.
