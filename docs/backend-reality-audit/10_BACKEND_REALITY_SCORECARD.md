# Report 10: Deal One Backend Reality Scorecard

**Audit Execution Date:** November 6, 2026  
**Auditor:** Principal Backend Architect & Independent Technical Auditor  
**Evaluation Standard:** Zero-tolerance reality audit. No single inflated composite score; 8 distinct dimensional evaluations.

---

## 1. Executive Summary & Dimension Summary Table

The backend architecture possesses an exceptionally solid infrastructure foundation (PostGIS, Docker, dual Redis, refresh token rotation, structured logging). However, severe deficiencies in API completeness, workflow integrity, and data privacy suppress operational readiness.

| # | Audit Dimension | Score | Letter Grade | Status | Key Deduction Factor |
|:---:|:---|:---:|:---:|:---:|:---|
| **1** | **Documentation Accuracy** | **53%** | **F** | Severely Inflated | False claims of 100% endpoint completion and active moderation. |
| **2** | **API Contract Compliance** | **41%** | **F** | Non-Compliant | 36 of 55 OpenAPI operations missing or mismatched; 35 undocumented routes. |
| **3** | **Database Architecture Fidelity** | **75%** | **C** | Good Foundation | Missing `section` column in categories; 16 empty application tables. |
| **4** | **Core Business Logic Implementation** | **53%** | **F** | Incomplete | Listing edit/delete missing; seller onboarding missing; quotas unenforced. |
| **5** | **Security & Authorization Enforcement** | **40%** | **F** | Blocked | Critical PII leakage of seller phone in public feeds; moderation bypass. |
| **6** | **Moderation & Workflow Integrity** | **15%** | **F** | Critical Failure | Hardcoded auto-approval bypasses human moderation; 0 moderation logs. |
| **7** | **Test Coverage & Verification** | **60%** | **D** | Superficial | 137 unit tests pass but rely on heavy mocks; 0 HTTP E2E integration tests. |
| **8** | **Production Engineering Readiness** | **52%** | **F** | Blocked | P0 blockers unaddressed; outbox worker unwired; payments active. |

---

## 2. Explicit Calculation Methodology & Evidence Breakdown

### 2.1 Dimension 1: Documentation Accuracy Score — 53% (Grade: F)
- **Methodology:** 60 major technical assertions across blueprints, phase verification reports, and checklists were evaluated against source code and database reality.
  - Fully Verified True Assertions: 26 (43.3%)
  - Partially True Assertions: 12 (20.0%)
  - Demonstrably False / Highly Inflated Assertions: 22 (36.7%)
- **Calculation:** `(26 + (0.5 * 12)) / 60 = 32 / 60 = 53.3%`
- **Primary Deductions:**
  - `BACKEND_PROJECT_STATUS.md` claiming 55 REST endpoints are 100% operational (-25%).
  - Claims that two-tier moderation and daily quota engines are active when code proves otherwise (-15%).
  - Conflicting specifications across `docs/` and `backend_blueprint/` (-7%).

---

### 2.2 Dimension 2: API Contract Compliance Score — 41% (Grade: F)
- **Methodology:** Evaluation of canonical OpenAPI operations (55 operations) vs. actual compiled NestJS routes (54 routes).
  - Exact Path, Method, and DTO Matches: 19 operations (19.0 pts)
  - Method Match with Route or Parameter Drift (`:id` vs `{accountId}`): 7 operations (3.5 pts)
  - Documented Operations Completely Absent in Controllers: 29 operations (0.0 pts)
- **Calculation:** `(19 + 3.5) / 55 = 22.5 / 55 = 40.9%`
- **Primary Deductions:**
  - 36 total operations missing or mismatched (-45%).
  - 35 undocumented routes in controllers bypassing OpenAPI contracts (-14%).

---

### 2.3 Dimension 3: Database Architecture Fidelity Score — 75% (Grade: C)
- **Methodology:** Prisma schema structure, migration integrity, PostGIS spatial indexing, and table populations.
  - Baseline Integrity: 29/29 tables defined, 6/6 migrations applied cleanly, PostGIS GIST indexes active, dynamic JSONB GIN index verified (100.0 pts).
- **Deductions:**
  - Missing `section` column in `categories` table and 10 root categories instead of 6 sections (-10%).
  - 16 of 29 application tables contain exactly 0 rows (-10%).
  - Redundant root categories in seed data (*"Cars"* vs *"Vehicles"*, *"Properties for Sale"* vs *"Real Estate"*) (-5%).
- **Calculation:** `100 - 25 = 75.0%`

---

### 2.4 Dimension 4: Core Business Logic Implementation Score — 53% (Grade: F)
- **Methodology:** Evaluation of 6 primary business domains:
  1. Categories & Dynamic Attributes: 85%
  2. Search, PostGIS Radius & Facets: 80%
  3. Listings CRUD & Lifecycle: 50% (Create and feed work; edit, delete, status toggle missing)
  4. Seller Accounts & Branches: 40% (Read exists; onboarding, branch creation, team RBAC missing)
  5. In-App Buyer-Seller Chat: 40% (Service exists; 0 DB messages, WebSocket gateway rudimentary)
  6. Daily Quota Enforcement Engine: 20% (Controller route exists; balance logic idle)
- **Calculation:** `(85 + 80 + 50 + 40 + 40 + 20) / 6 = 52.5%`

---

### 2.5 Dimension 5: Security & Authorization Enforcement Score — 40% (Grade: F)
- **Methodology:** Verification against OWASP Top 10, CWE standards, and Agent 2 Security Audit Register.
  - Baseline Technical Controls: 85% (Refresh token reuse detection, bcrypt salt 10, `AccountTenantGuard`, Redis sliding window rate limiting).
- **Penalties Applied:**
  - **SEC-CRIT-01:** Instant publication bypasses human moderation (-25%).
  - **SEC-CRIT-02:** Raw seller phone numbers leaked in public listings and search feeds (-20%).
- **Calculation:** `85 - 45 = 40.0%`

---

### 2.6 Dimension 6: Moderation & Workflow Integrity Score — 15% (Grade: F)
- **Methodology:** Verification of human moderation queue, audit logging, and state transition governance.
  - Automated report tickets controller: Functional for user complaints (15.0 pts).
  - Listing moderation queue: Missing (0.0 pts).
  - Human approval gate: Bypassed by hardcoded `approved` status in `listings.service.ts` (0.0 pts).
  - Moderation decision logging: `moderation_log` table contains 0 rows (0.0 pts).
- **Calculation:** `15.0%`

---

### 2.7 Dimension 7: Test Coverage & Verification Score — 60% (Grade: D)
- **Methodology:** Test execution metrics and test depth analysis.
  - Pass Rate: 137 of 137 unit tests pass (100.0 pts).
- **Quality Deductions:**
  - 90%+ tests use mock Prisma services, failing to verify real PostgreSQL/PostGIS queries (-20%).
  - Zero end-to-end HTTP integration tests against NestJS controllers (-15%).
  - State machine test validates a decoupled class not invoked by production services (-5%).
- **Calculation:** `100 - 40 = 60.0%`

---

### 2.8 Dimension 8: Production Engineering Readiness Score — 52% (Grade: F)
- **Methodology:** Multi-service orchestration, container health, logging, backup scripts, and deployment posture.
  - Infrastructure Foundation: Dockerfile, Docker Compose, PostgreSQL 16, dual Redis, automated backup/restore scripts, Winston logging, health controller (87.0 pts).
- **Deductions:**
  - P0 security vulnerabilities unaddressed (-20%).
  - Out-of-scope Paymob payments and Cloudflare video feed active in production build (-10%).
  - Missing transactional outbox event publisher wiring (-5%).
- **Calculation:** `87 - 35 = 52.0%`

