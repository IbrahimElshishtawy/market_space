# Deal One — Backend Engineering Project Status

## 1. Project Overview & Meta Information
- **Product Name:** Deal One (صفقة ون)
- **Architecture Version:** `1.0.0-AUDITED`
- **Current Project Phase:** **Phase 00 & Pre-Implementation Audit Completed — Ready with Conditions**
- **Audit Date:** 2 November 2026
- **Audit Verdict:** **READY WITH CONDITIONS** (Audited in `17_PRE_IMPLEMENTATION_AUDIT.md`)
- **Verified Schema Size:** **28 Relational Tables** (PostgreSQL 16 + PostGIS)
- **Verified API Inventory:** **55 REST Endpoints + 1 WebSocket Gateway**

---

## 2. Phase Implementation Progress Tracker

| Phase ID | Phase Name | Status | Sign-off / Verdict | Blockers / Prerequisites |
|---|---|:---:|:---:|---|
| **Phase 00** | Architecture Audit & Blueprint Generation | **COMPLETED** | **PASS** | Audited in `17_PRE_IMPLEMENTATION_AUDIT.md`. |
| **Phase 01** | Project Foundation & Fastify Clean Scaffolding | **READY** | - | Ready to execute via `01_PROJECT_FOUNDATION.md`. |
| **Phase 02** | Infrastructure, Docker & Database Setup | PENDING | - | Prerequisite: Phase 01. Must replace obsolete `schema.prisma`. |
| **Phase 03** | Database Schema Migration (28 Tables) | PENDING | - | Prerequisite: Phase 02. |
| **Phase 04** | Authentication, SMS OTP & Session Tokens | PENDING | - | Prerequisite: Phase 03. |
| **Phase 05** | Multi-Tenant Authorization & Team RBAC | PENDING | - | Prerequisite: Phase 04. |
| **Phase 06** | Geographic Locations, Branches & Service Areas | PENDING | - | Prerequisite: Phase 05. |
| **Phase 07** | Categories Taxonomy & Dynamic Fields | PENDING | - | Prerequisite: Phase 03. |
| **Phase 08** | Listings Core & 3-Axis Orthogonal Lifecycle | PENDING | - | Prerequisite: Phase 05, 06, 07. |
| **Phase 09** | PostGIS Spatial Search & Filtering | PENDING | - | Prerequisite: Phase 08. |
| **Phase 10** | Media Engine & Cloudflare R2 Presigned Uploads| PENDING | - | Prerequisite: Phase 08. |
| **Phase 11** | Real-Time Chat & WebSocket Gateway | PENDING | - | Prerequisite: Phase 05, 08. |
| **Phase 12** | Daily Quotas Engine (Cairo Midnight Reset) | PENDING | - | Prerequisite: Phase 04, 08. |
| **Phase 13** | Operational Notifications (FCM) | PENDING | - | Prerequisite: Phase 08, 11. |
| **Phase 14** | Admin Control Center & Moderation | PENDING | - | Prerequisite: Phase 05, 08. |
| **Phase 15** | Observability, Pino & Prometheus | PENDING | - | Prerequisite: All previous phases. |
| **Phase 16** | Automated Python & Locust Load Testing | PENDING | - | Prerequisite: All previous phases. |
| **Phase 17** | Production Staging Verification & Release Gate | PENDING | - | Prerequisite: Phase 16. |

---

## 3. Approved Architecture Decisions (ADR Register)
- **ADR-001:** Hybrid Multi-Category Strategy (Approved)
- **ADR-002:** Shared Core Architecture (Approved)
- **ADR-003:** Category-Driven Dynamic Attribute Modeling (Approved)
- **ADR-004:** Tiered Seller Verification by Account Type (Approved)
- **ADR-005:** Multiple Independent Seller Accounts per User (Approved)
- **ADR-006:** Two-Tier Geographic Privacy Architecture (Approved)
- **ADR-007:** Orthogonal 3-Axis Listing Lifecycle States (Approved)
- **ADR-008:** V1 Strict `contact_only` Scope (Approved)
- **ADR-009:** E-commerce Catalog Deferral to V3 (Approved)
- **ADR-010:** Booking & Appointments Deferral to V3 (Approved)
- **ADR-011:** Operational Notifications in V1 vs Saved Searches in V2 (Approved)
- **ADR-012:** Modular Monolith Architecture Pattern (Approved)
- **ADR-013:** Technology Stack: NestJS + Fastify + PostgreSQL + Redis (Approved)
- **ADR-014:** Automated Python Quality & Load Testing Harness (Approved)

---

## 4. Open Business Decisions & Clarifications (Documented in `19_OPEN_DECISIONS.md`)
1. **Decision 01:** Mobile App Packaging: Single unified app with Account Switcher (Recommended) vs. Two separate store apps.
2. **Decision 02:** Default Numerical Daily Quotas: Individuals (3 listings / 15 reveals / 20 chats); Companies (30 listings / 100 reveals / unlimited chats).
3. **Decision 03:** Listing Expiry: 30 days for FMCG / Fashion; 60–90 days for Real Estate & Automotive.
4. **Decision 04:** Price transparency for industrial materials: allow `price_on_inquiry: true`.

---

## 5. Mandatory Audit Conditions Before Phase 01 & 02
1. **Prisma Schema Replacement:** In Phase 02, completely overwrite the legacy `schema.prisma` with the verified 28-table schema from `02_DATABASE_DESIGN.md`.
2. **PostGIS Query Pattern:** Spatial distance queries must use `prisma.$queryRaw` with parameterized templates due to Prisma's native PostGIS limitations.
3. **Redis DB Isolation:** Separate Cache (`db: 0`) from BullMQ queues (`db: 1`) to prevent key eviction under memory pressure.
