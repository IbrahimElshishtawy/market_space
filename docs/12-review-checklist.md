# Project Owner Review & Approval Checklist — Market Space
**Document Version:** 1.0.0  
**Phase:** Phase 1 Design & System Review Pack  
**Instructions:** Please inspect each item below. Check the corresponding box once approved, or provide remarks on required modifications. All items in the **Core Approval Gate** must be confirmed before triggering Phase 2 (Backend Implementation).

---

## 1. Core Architecture & Strategic Decisions Approval Gate

- [ ] **1. Product Scope & MVP Boundaries (`docs/00-executive-summary.md` & `docs/02-mvp-scope-and-roadmap.md`)**
  - *Decision:* Classifieds peer-to-peer trading is the primary product; short-form video is an optional discovery feature.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **2. Technology Stack & Modular Monolith (`docs/03-system-architecture.md` & `ADR-001`, `ADR-002`)**
  - *Decision:* NestJS (TypeScript / Node.js 20) with Fastify adapter, PostgreSQL 16, Redis 7 (BullMQ), and Next.js Admin portal on a single VPS.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **3. Authentication & Verification Model (`docs/01-srs.md` & `ADR-003`, `DEC-001`)**
  - *Decision:* Egyptian Phone Number (`+20`) with 6-digit SMS OTP (SMS Misr / Infobip) + optional password for recurring login. Rate-limited to 3 requests per 15 minutes.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **4. Taxonomy & Dynamic Field Storage (`docs/04-data-model.md` & `ADR-004`)**
  - *Decision:* 14 root categories, subcategories, and a hybrid PostgreSQL `JSONB` attribute engine for subcategory-specific fields (e.g., Year, Mileage, Bedrooms) with GIN indexing.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **5. Listing Lifecycle & Moderation State Machine (`docs/01-srs.md` & `DEC-002`)**
  - *Decision:* Enforced state machine (`DRAFT`, `PENDING_REVIEW`, `PUBLISHED`, `REJECTED`, `PAUSED`, `EXPIRED`, `SOLD`, `ARCHIVED`). Hybrid post-moderation with pre-moderation for new accounts and high-risk categories.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **6. Media & Video Architecture (`docs/03-system-architecture.md` & `ADR-006`, `DEC-003`)**
  - *Decision:* Up to 10 images uploaded directly to Cloudflare R2 via presigned URLs. Max 1 optional video per listing strictly capped at 30 seconds via Cloudflare Stream to shield VPS CPU.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **7. Buyer-Seller Communication Model (`docs/01-srs.md`)**
  - *Decision:* Three-tier contact flow: (1) Phone reveal click counter, (2) WhatsApp deep link with pre-filled context, (3) In-app text messaging (REST polling/SSE).
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **8. Monetization & Payment Processing (`docs/05-api-specification.md` & `ADR-009`, `DEC-004`)**
  - *Decision:* Paymob integration for Egyptian Cards, Meeza, and Mobile Wallets. Server-side authoritative pricing; promotions activated strictly via cryptographically verified HMAC SHA512 webhooks.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **9. Role-Based Access Control & Admin Portal (`docs/01-srs.md`)**
  - *Decision:* Next.js back-office with RBAC (`USER`, `MODERATOR`, `SUPER_ADMIN`). Immutable audit log for all administrative state overrides and moderation actions.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **10. Privacy, Security & Data Protection (`docs/06-security-and-privacy.md`)**
  - *Decision:* Full IDOR protection on all endpoints, Argon2id password hashing, zero PII logging, and alignment with Egypt Data Protection Law No. 151 of 2020.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **11. Infrastructure, VPS Hosting & Backup Runbooks (`docs/07-deployment-and-operations.md` & `ADR-008`)**
  - *Decision:* Initial 4-vCPU / 8GB RAM Ubuntu VPS with Docker Compose, Nginx TLS, automated daily offsite database dumps to Cloudflare R2, and documented incident runbooks.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **12. API Contract & OpenAPI Specification (`docs/05-api-specification.md` & `docs/openapi.yaml`)**
  - *Decision:* RFC 7807 inspired error envelopes, cursor-based pagination, and complete OpenAPI 3.1 contract.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

- [ ] **13. Backend Implementation Order & Quality Gates (`docs/10-backend-implementation-plan.md` & `docs/08-testing-strategy.md`)**
  - *Decision:* Sequential 10-milestone execution starting with Milestone 0 (foundation, DB, health checks, config) before progressing to domain features.
  - *Approval Status:* `[ ] Approved  [ ] Needs Revision`
  - *Remarks:* __________________________________________________

---

## 2. Final Approval Sign-Off

When you are ready to commence backend implementation, respond with:  
> **"Phase 1 approved --- begin backend implementation"**
