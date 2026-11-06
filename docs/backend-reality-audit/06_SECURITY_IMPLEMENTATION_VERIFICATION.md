# Report 06: Deal One Security Implementation & Threat Reality Audit

**Audit Execution Date:** November 6, 2026  
**Auditor:** Principal Backend Architect & Independent Technical Auditor  
**Cross-Review Alignment:** Agent 2 Security Auditor Register (`docs/security-review/01` through `07`).

---

## 1. Executive Summary of Security Posture

A rigorous security inspection was conducted across the authentication lifecycle, authorization guards, data privacy (PII), cryptographic operations, rate limiting, and webhook integrations.

While foundational authentication mechanisms (refresh token family rotation, password hashing, correlation tracing) are engineered with high fidelity, the backend suffers from **two Critical vulnerabilities and two High-severity architectural violations** that prevent production certification.

```
+--------------------------------------------------------------------------+
|                       SECURITY FINDINGS SUMMARY                          |
+--------------------------+-----------------------+-----------------------+
| Critical Severity: 2     | High Severity: 3      | Medium Severity: 4    |
| Low Severity: 4          | Total Findings: 13    | Production Gate: BLOCKED |
+--------------------------+-----------------------+-----------------------+
```

---

## 2. Deep-Dive Audit of Critical and High Findings

### 2.1 [CRIT-01] Bypassed Moderation Lifecycle Enables Instant Publication of Malicious Content
- **Vulnerability ID:** SEC-CRIT-01 (Agent 2: CRIT-01)
- **CWE:** CWE-863: Incorrect Authorization / Broken Business Logic
- **Location:** `backend/src/modules/listings/listings.service.ts`, Lines 127–129
- **Vulnerable Code:**
  ```typescript
  moderationStatus: 'approved',
  publicationStatus: 'published',
  availabilityStatus: 'available',
  ```
- **Code Reality:**  
  When an authenticated user calls `POST /listings`, the service directly sets the listing's moderation status to `approved` and publication status to `published`.
- **Security Impact:**  
  Any malicious actor or spam bot can instantly flood the public marketplace with prohibited goods, scams, weapons, or hate speech without human moderation review.
- **Verification Status:** **CONFIRMED VULNERABILITY (FAIL)**.

---

### 2.2 [CRIT-02] Direct PII Data Leakage via Public Listing and Search Payloads
- **Vulnerability ID:** SEC-CRIT-02 (Agent 2: CRIT-02)
- **CWE:** CWE-359: Exposure of Private Personal Information
- **Locations:**  
  - `backend/src/modules/listings/listings.service.ts`, Lines 162 & 284
  - `backend/src/modules/search/search.service.ts`, Line 108
- **Vulnerable Code:**
  ```typescript
  sellerPhone: item.account.owner.phone,
  ```
- **Code Reality:**  
  Both the public listing feed (`GET /listings`) and the public search endpoint (`GET /search`) map and serialize the raw phone number of the seller into the public JSON response.
- **Security Impact:**  
  1. Complete exposure of merchant and individual phone numbers to automated web scrapers.
  2. Complete nullification of ADR-008 and ADR-009: Why would a buyer ever call `POST /listings/:id/reveal-contact` or respect daily reveal quotas when the phone number is already included in the unauthenticated feed?
- **Verification Status:** **CONFIRMED VULNERABILITY (FAIL)**.

---

### 2.3 [HIGH-01] Out-of-Scope Payment Gateway & Webhook Attack Surface
- **Vulnerability ID:** SEC-HIGH-01 (Agent 2: CRIT-03 / HIGH-01)
- **CWE:** CWE-353: Missing Support for Integrity Check / Scope Creep
- **Location:** `backend/src/modules/payments/payments.controller.ts` & `payments.service.ts`
- **Code Reality:**  
  A complete payments module (`/payments/checkout`, `/payments/webhook`, `/payments/packages`) is active in the codebase and connected to Paymob.
- **Security Impact:**  
  ADR-008 explicitly declared V1 to be a 100% free classifieds marketplace with **zero payment processing**. Introducing uncertified financial checkout and webhook handling creates PCI-DSS compliance exposure, transaction race condition risks, and financial liability before core marketplace security is stabilized.
- **Verification Status:** **CONFIRMED VIOLATION (OUT_OF_SCOPE)**.

---

### 2.4 [HIGH-02] Unenforced Daily Contact Quotas and Idle Quota Engine
- **Vulnerability ID:** SEC-HIGH-02
- **CWE:** CWE-770: Allocation of Resources Without Limits or Throttling
- **Location:** `schema.prisma::DailyQuota`, `backend/src/modules/listings/listings.service.ts`
- **Code Reality:**  
  The `daily_quotas` table in PostgreSQL contains **0 rows**. While `listings.service.ts::revealContact` logs a contact event, it does not check or deduct from an authenticated user's daily quota balance.
- **Security Impact:**  
  Rogue users or bots can harvest contacts without bound, violating platform fair-use policies.
- **Verification Status:** **CONFIRMED VULNERABILITY (PARTIAL / FAIL)**.

---

### 2.5 [HIGH-03] Missing Upload Confirmation & Incomplete EXIF Metadata Scrubbing
- **Vulnerability ID:** SEC-HIGH-03 (Agent 2: HIGH-03)
- **CWE:** CWE-200: Exposure of Sensitive Information via EXIF Geolocation
- **Location:** `backend/src/modules/media/media.service.ts`, `backend/src/workers/worker.service.ts`
- **Code Reality:**  
  `POST /media/presigned-url` issues a pre-signed S3 upload URL. While `worker.service.ts` contains image processing stubs (`sharp` strip EXIF), the endpoint `POST /media/confirm-upload` documented in OpenAPI does NOT exist in controllers. Images uploaded directly to object storage are never validated or dispatched to the background worker before being saved in `listing_media`.
- **Security Impact:**  
  Photos taken on mobile phones may retain GPS coordinate tags in EXIF headers, exposing the exact home address of private sellers.
- **Verification Status:** **CONFIRMED VULNERABILITY (PARTIAL)**.

---

## 3. Verified Security Strengths

The audit confirmed several well-implemented security controls:

1. **Refresh Token Family Rotation with Reuse Detection:**
   - Implemented in `session.service.ts`.
   - Verified via unit test `session.service.spec.ts`: When an expired or revoked refresh token is replayed, the entire session family is instantly revoked, and a security alert is emitted.
2. **Tenant Isolation Guard (`AccountTenantGuard`):**
   - Implemented in `account-tenant.guard.ts`.
   - Verified via unit test `account-tenant.guard.spec.ts`: Enforces that the `x-account-id` header matches an account where the authenticated user is an active member with appropriate role permissions.
3. **Password Security:**
   - Hashed using `bcrypt` with work factor 10.
4. **Input Validation:**
   - Global NestJS `ValidationPipe` with `whitelist: true` strips unexpected payload properties, mitigating Mass Assignment vulnerabilities.
5. **Rate Limiting on Sensitive Actions:**
   - `recordContactClick` is protected by Redis atomic sliding-window rate limiting.

---

## 4. Comprehensive Security Findings Register

| Finding ID | Severity | Title | Affected File | Status | Remediation Priority |
|:---|:---:|:---|:---|:---:|:---:|
| **SEC-01** | **CRITICAL** | Instant Auto-Approval Listing Moderation Bypass | `listings.service.ts` | Open | **P0** |
| **SEC-02** | **CRITICAL** | Raw Seller Phone Exposed in Public Feeds | `listings.service.ts`, `search.service.ts` | Open | **P0** |
| **SEC-03** | **HIGH** | Out-of-Scope Payment Module & Webhooks Active | `modules/payments/*` | Open | **P1** |
| **SEC-04** | **HIGH** | Daily Quota Enforcement Engine Non-Operational | `listings.service.ts`, DB | Open | **P1** |
| **SEC-05** | **HIGH** | Missing EXIF Scrubbing Confirmation Hook | `media.service.ts`, `media.controller.ts` | Open | **P1** |
| **SEC-06** | **MEDIUM** | Missing Team RBAC Endpoints | `accounts.controller.ts` | Open | **P2** |
| **SEC-07** | **MEDIUM** | Mock SMS Adapter Active in Dev Fallback | `sms-adapters.ts` | Mitigated in Prod | **P2** |
| **SEC-08** | **MEDIUM** | Inconsistent Parameter Naming (`:id` vs `{accountId}`) | Multiple Controllers | Open | **P2** |
| **SEC-09** | **MEDIUM** | Absence of Anti-Scraping Bot Protection on Public Search | `search.controller.ts` | Open | **P2** |
| **SEC-10** | **LOW** | Missing HTTP Security Headers (Helmet not in main.ts) | `main.ts` | Open | **P3** |
| **SEC-11** | **LOW** | TypeScript 5.9.3 ESLint Warning during Build | `package.json` | Tolerated | **P3** |
| **SEC-12** | **LOW** | Missing Rate Limiter on Categories Read Endpoint | `categories.controller.ts` | Low Risk | **P3** |
| **SEC-13** | **LOW** | Unencrypted Outbox Events Table | `schema.prisma` | Low Risk | **P3** |

---

## 5. Security Gate Decision

> [!CAUTION]
> **GATE VERDICT: BLOCKED FOR PRODUCTION**  
> Because **SEC-01 (Moderation Bypass)** and **SEC-02 (PII Phone Leakage)** directly violate core platform privacy and legal compliance policies, this backend CANNOT be deployed to public production until both P0 blockers are fully remediated.

