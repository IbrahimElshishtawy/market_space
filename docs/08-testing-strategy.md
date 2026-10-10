# Testing and Quality Assurance Strategy — Market Space

---

## 1. Testing Pyramid & Verification Framework

The quality assurance strategy for **Market Space** enforces multi-layered validation across all operational tiers:

```
          ▲
         / \
        / E2E \       10% (Critical User Flows: Signup -> Post Ad -> Pay -> Moderate)
       /───────\
      /   API   \     30% (Contract, Auth, State Machine, Webhook Idempotency)
     /───────────\
    / Integration \   30% (Database Repository, Redis Queues, R2 S3 Adapters)
   /───────────────\
  /    Unit Tests   \ 30% (DTO Validation, State Transitions, Business Rules)
 └─────────────────┘
```

---

## 2. Test Suites & Coverage Scope

### 2.1 Unit Tests (`backend/test/unit`)
- **Validation Pipes:** Testing boundary cases for phone numbers (`+2010...`, invalid prefixes, length checks).
- **Listing State Machine:** Verifying valid and invalid state transitions (e.g., verifying that a listing cannot transition directly from `DRAFT` to `EXPIRED`).
- **Paymob Signature Verification:** Verifying HMAC calculation against known test fixtures and detecting altered payloads.

### 2.2 Integration Tests (`backend/test/integration`)
- **Database & Repository Tests:** Utilizing a test PostgreSQL container with migrations applied.
- **Trigram Search Evaluation:** Verifying that Arabic query variations (e.g., `النترا` vs `إلنترا`) return the expected test listings using `pg_trgm`.
- **Worker & Queue Processing:** Verifying that BullMQ jobs correctly update database entities upon completion.

### 2.3 Critical API Contract & Authorization Tests (`backend/test/e2e`)
1. **Cross-User Data Isolation (IDOR Check):**
   - User A registers and creates Listing A.
   - User B attempts `PUT /api/v1/listings/{listingA.id}`.
   - *Expected:* HTTP `403 Forbidden`.
2. **Payment Webhook Idempotency Test:**
   - Deliver valid Paymob webhook payload for Transaction `TX_998877`.
   - Verify listing marked `is_featured = true`.
   - Deliver identical payload a second time.
   - *Expected:* HTTP `200 OK` acknowledged with zero duplicated promotion records or date extension anomalies.
3. **Category Dynamic Schema Validation:**
   - Attempt to publish a car listing without required dynamic field `year`.
   - *Expected:* HTTP `400 Bad Request` with structured error detailing missing attribute `year`.

---

## 3. Realistic Load Testing Scenarios

> **Load Assumptions:** Initial target: 50,000 registered users, generating an estimated peak of 200 concurrent active browsing users and 20 listings/minute publication rate.

### 3.1 Test Scenarios (Artillery / k6)
| Scenario | Virtual Users (VUs) | Target Endpoints | Acceptance Threshold |
| :--- | :---: | :--- | :--- |
| **Public Browsing Peak** | 150 VUs | `GET /listings`, `GET /categories`, `GET /listings/{id}` | p95 < 120ms, 0% error rate |
| **Keyword Search Stress** | 50 VUs | `GET /search?q=تويوتا كورولا` | p95 < 180ms, CPU < 60% |
| **Listing Creation Spike** | 20 VUs | `POST /listings`, `POST /media/images/upload-url` | p95 < 300ms, 0% drop |

---

## 4. Release Gates & CI/CD Quality Checklist

Every Pull Request must pass the following automated gates before merging to `main`:
1. **Static Analysis & Linting:** ESLint and Prettier report zero errors.
2. **Type Checking:** `tsc --noEmit` completes cleanly with no type coercions (`any` banned).
3. **Unit & Integration Suite:** 100% of tests pass with > 85% statement coverage across business modules.
4. **OpenAPI Schema Sync:** Auto-generated API definitions match `docs/openapi.yaml` without undetected drift.
5. **Security Scan:** Snyk/npm audit reports zero critical/high vulnerabilities; GitLeaks reports zero secret leaks.
