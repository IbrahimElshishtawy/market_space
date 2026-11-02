# Deal One — Mandatory AI Execution Protocol & Verification Standards

## 1. Protocol Purpose & Strict Enforcement

This protocol governs the automated execution of all backend implementation prompts located in `backend_execution_prompts/`. Any AI agent or developer implementing a phase of Deal One **MUST** strictly adhere to this protocol without exception.

---

## 2. The Three-Stage Implementation Protocol

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       STAGE 1: PRE-IMPLEMENTATION AUDIT                     │
│  1. Read Master Architecture & Phase Spec                                   │
│  2. Inspect existing workspace code and database schema                     │
│  3. Verify prerequisite dependencies are completed and tested               │
│  4. Formulate explicit, non-overlapping step-by-step implementation plan    │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       STAGE 2: STRICT IMPLEMENTATION                        │
│  1. Implement ONLY the approved scope (No scope creep, no unasked features) │
│  2. Adhere to Modular Monolith boundaries & Clean Architecture              │
│  3. Validate all inputs via DTOs (Zod / class-validator)                    │
│  4. Enforce tenant isolation & RBAC guards on every protected route         │
│  5. Structure logging with Pino (Correlation IDs, masked secrets)           │
│  6. Write automated tests covering happy path and attack vectors            │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       STAGE 3: VERIFICATION & REPORTING                     │
│  1. Execute unit, integration, and security test suites                     │
│  2. Run TypeScript build (`npm run build`) and linter (`npm run lint`)      │
│  3. Verify zero schema drift in database                                    │
│  4. Generate Standardized Phase Report with definitive verdict               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Forbidden Shortcuts & Anti-Patterns (The "Never" List)

1. **NEVER** use mock tests or fake assertion passes to simulate test completion.
2. **NEVER** claim a test passed unless it was actually executed and output verified in the terminal.
3. **NEVER** use TypeScript `any` or disable strict null checks.
4. **NEVER** use raw SQL concatenation vulnerable to SQL injection; use parameterized queries or Prisma ORM.
5. **NEVER** execute a database query modifying tenant data without the mandatory `account_id` constraint.
6. **NEVER** hardcode secrets, API keys, or JWT tokens in source code or version control.
7. **NEVER** suppress errors with empty `catch {}` blocks.
8. **NEVER** silently change an existing API response format or database column name without an approved ADR.
9. **NEVER** proceed to the next implementation phase if the current phase results in a `FAIL` verdict.

---

## 4. Mandatory Post-Execution Reporting Template

Upon completing any phase prompt, the executing agent **MUST** output a report using the exact markdown template below:

```markdown
# Phase Implementation & Verification Report: Phase [XX] - [Phase Name]

## 1. Implementation Summary
- **Phase ID:** [e.g., Phase 04]
- **Target Module:** [e.g., AuthModule]
- **Completed Tasks:**
  - [Task 1 Description]
  - [Task 2 Description]
- **Created Files:**
  - `path/to/new_file_1.ts`
  - `path/to/new_file_2.ts`
- **Modified Files:**
  - `path/to/modified_file.ts`
- **Database Migrations Applied:**
  - `[migration_name]` (or None)
- **API Endpoints Implemented:**
  - `[HTTP_METHOD] /api/v1/endpoint`

## 2. Automated Testing & Verification Results
- **Test Command Executed:** `[e.g., pytest backend_tests/functional/test_auth.py]`
- **Total Tests Executed:** [Number]
- **Passed:** [Number]
- **Failed:** [Number]
- **Skipped:** [Number]
- **Test Coverage:** [Percentage]%
- **Terminal Execution Output Excerpt:**
  ```
  [Paste actual terminal test runner output]
  ```

## 3. Security & Quality Gate Audit
- **BOLA/IDOR Defenses Verified:** [Yes / Not Applicable]
- **Input Validation Verified:** [Yes / No]
- **TypeScript Strict Build:** [PASS / FAIL]
- **Linting & Formatting:** [PASS / FAIL]
- **Known Security Risks Discovered:** [None / Detail]

## 4. Outstanding Issues & Technical Debt
- **Known Limitations:** [Detail or None]
- **Dependencies for Next Phase:** [List]

## 5. Final Phase Verdict
**VERDICT:** [PASS | PASS WITH WARNINGS | FAIL]
- *Reasoning:* [Justify verdict based on acceptance criteria]
```
