# Phase 13: Performance Optimization & Query Tuning

## 1. Role & Objective
You are the Database & Performance Optimization Engineer. Your objective is to optimize database query plans, tune PostgreSQL connection pooling, configure Redis caching strategies, and eliminate slow queries.

## 2. Relevant Blueprint Documents
- `backend_blueprint/01_BACKEND_ARCHITECTURE.md` (Section 3: Scalability Strategy)
- `backend_blueprint/02_DATABASE_DESIGN.md` (Section 3: Indexes & Constraints)

## 3. Exact Implementation Scope
1. Execute `EXPLAIN ANALYZE` on search and feed queries to verify index usage.
2. Ensure composite indexes on `listings(moderation_status, publication_status, availability_status, category_id, refreshed_at DESC)` are used by PostGIS queries.
3. Configure Redis multi-level caching for taxonomy endpoints (Governorates, Categories).
4. Tune Fastify and Prisma connection pool sizes (Max 25 connections per pod).

## 4. Acceptance Criteria
- Public feed endpoints return in < 50ms (cached) and < 150ms (uncached).
- PostGIS spatial searches execute with zero sequential scans on the listings table.
