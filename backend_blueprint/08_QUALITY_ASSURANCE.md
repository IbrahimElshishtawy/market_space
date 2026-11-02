# Deal One — Quality Assurance System & Release Engineering

## 1. Quality Philosophy & Acceptance Gates

In Deal One, software quality is an automated engineering boundary enforced at every stage of the development lifecycle. No code can be merged, deployed, or accepted into a release branch without satisfying automated verification gates.

### The Iron Rule of Quality Gates:
A phase or implementation task **CANNOT** be marked `COMPLETE` if:
1. Any required automated test fails.
2. Any unresolved **P0** (Critical) or **P1** (High) security or data-loss vulnerability exists.
3. Database migrations produce schema drift, broken constraints, or lack rollback scripts.
4. API contracts fail to match the approved `openapi.yaml` specification.
5. Existing business workflows or regression suites break.
6. Untyped shortcuts, skipped error handling, or plain-text mock stubs are introduced.

---

## 2. Issue Severity Classification

| Severity Level | Definition | Release Impact | Resolution SLA |
|---|---|:---:|:---:|
| **P0 — Critical** | System crash, authentication bypass, data loss, SQL injection, BOLA/IDOR vulnerability, or severe revenue/reputational harm. | **BLOCKS ALL RELEASES** (Hard Gate) | Immediate (Work stops until resolved) |
| **P1 — High** | Core workflow broken (e.g., cannot publish listing, SMS OTP failing, image uploads failing, PostGIS search timeout). | **BLOCKS RELEASE** | < 24 Hours |
| **P2 — Medium** | Non-critical workflow defect with a documented workaround (e.g., admin filter display bug, localized Arabic formatting issue). | May release with Lead Architect sign-off | Next Sprint |
| **P3 — Low** | Minor cosmetic defect, typos in logs/error strings, or non-functional documentation inconsistency. | Does not block release | Backlog |

---

## 3. The 10 Automated Quality Gates

Every implementation phase must pass all ten automated verification gates:

```
[Developer Code / AI Prompt Run]
             │
             ▼
   [Gate 1: Static Type Check (TypeScript strict, no implicit any)]
             │
             ▼
   [Gate 2: Linting & Code Formatting (ESLint + Prettier)]
             │
             ▼
   [Gate 3: Security Dependency Audit (npm audit, Snyk)]
             │
             ▼
   [Gate 4: Unit Testing (> 85% Domain Logic Coverage)]
             │
             ▼
   [Gate 5: Database Migration & Idempotency Check]
             │
             ▼
   [Gate 6: API Contract Validation (Prisma vs. OpenAPI 3.1)]
             │
             ▼
   [Gate 7: Integration & Multi-Tenant Authorization Tests]
             │
             ▼
   [Gate 8: Security Fuzzing (BOLA, IDOR, SQLi, Rate Limiting)]
             │
             ▼
   [Gate 9: Performance Regression Check (p95 < 200ms)]
             │
             ▼
   [Gate 10: Documentation & ADR Synchronization]
             │
             ▼
  [RELEASE CANDIDATE APPROVED]
```

### Gate 1: Static Type Safety
- **Tool:** TypeScript 5.4+ with `strict: true`.
- **Criteria:** Zero compiler errors. Use of `any` is strictly prohibited in business logic; all DTOs and database models must have explicit types.

### Gate 2: Code Quality & Linting
- **Tool:** ESLint with Airbnb/NestJS recommended rules + Prettier.
- **Criteria:** Zero lint warnings or formatting discrepancies.

### Gate 3: Dependency Vulnerability Scanning
- **Tool:** `npm audit --audit-level=high` and Trivy container scanning.
- **Criteria:** Zero High or Critical CVEs in production dependencies.

### Gate 4: Unit Testing & Isolation
- **Tool:** Jest / Vitest.
- **Criteria:** Unit tests must cover all pure business rules, validation logic, quota calculations, and status transitions with a minimum of **85% branch coverage**.

### Gate 5: Database Schema Integrity
- **Tool:** Prisma Migrate + PostgreSQL dry-run.
- **Criteria:** Every migration must apply cleanly against a fresh PostgreSQL instance, support rollbacks, and maintain referential integrity without orphaned foreign keys.

### Gate 6: API Contract Synchronization
- **Tool:** Spectral OpenAPI Linter & DTO type-checkers.
- **Criteria:** Every implemented Fastify route must exactly match the endpoints, parameter names, and status codes documented in `openapi.yaml`.

### Gate 7: Integration & Multi-Tenant RBAC Testing
- **Tool:** Pytest + HTTPX test harness against live test containers.
- **Criteria:** Verifies that transactions commit and roll back correctly. Strictly tests that User A cannot read or modify User B's resources.

### Gate 8: Automated Security Testing
- **Tool:** Dedicated Python security test suite (`backend_tests/security/`).
- **Criteria:** Proves resistance to BOLA, IDOR, mass assignment, rate limit exhaustion, and invalid JWT tokens.

### Gate 9: Performance Regression Gate
- **Tool:** Locust automated baseline run (100 CCU for 5 minutes).
- **Criteria:** p95 latency must remain under 200ms; zero 5xx responses permitted.

### Gate 10: Documentation Integrity
- **Criteria:** All new endpoints, database fields, or architectural decisions must be documented in their corresponding blueprint files before phase closure.
