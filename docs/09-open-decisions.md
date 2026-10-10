# Open Decisions Log & Project Assumptions — Market Space

---

## 1. Overview
This document catalogs all strategic product, financial, and technical decisions requiring project owner approval. To maintain forward momentum without blocking Phase 1 planning, each item features a **Recommended Default Assumption** that aligns with industry standards in the Egyptian market.

---

## 2. Decision Classification

```
┌────────────────────────────────────────────────────────┐
│ [A] BLOCKING DECISIONS                                 │
│ Must be approved before starting Phase 2 backend code. │
└────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│ [B] IMPORTANT BUT NON-BLOCKING                         │
│ Can proceed with recommended default during Milestone 1│
└────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│ [C] CAN BE DEFERRED                                    │
│ Targeted for Phase 2 or post-launch evaluation.         │
└────────────────────────────────────────────────────────┘
```

---

## 3. Decision Register

### Category A: Blocking Decisions (Must Approve Before Backend Code)

#### DEC-001: Egyptian SMS OTP Provider Selection
- **Question:** Which SMS gateway will be used for production OTP verification in Egypt?
- **Recommended Default:** **SMS Misr** (or Infobip as backup) utilizing local direct operator routing in Egypt.
- **Alternatives:** Twilio (significantly higher international routing cost in Egypt), Firebase Phone Auth (convenient SDK but higher pricing at scale and occasional operator delivery hiccups).
- **Consequences:** Backend adapter must implement the selected provider's authentication and payload schema.
- **Owner Approval Required:** **YES (Blocking)**.

#### DEC-002: Moderation Workflow Paradigm
- **Question:** Should new listings be published immediately with automated heuristic filters and post-moderation, or held in a mandatory pre-moderation queue (`PENDING_REVIEW`)?
- **Recommended Default:** **Hybrid Post-Moderation:** Trusted/established users publish immediately with automated keyword blacklist scanning. Newly registered accounts (< 3 days old) or listings in high-risk categories (Jobs, Services) are held in `PENDING_REVIEW` until human moderator approval.
- **Alternatives:** 100% Pre-moderation (slows user gratification and posting velocity), 100% Post-moderation (elevated risk of illegal items appearing publicly).
- **Owner Approval Required:** **YES (Blocking)**.

---

### Category B: Important but Non-Blocking Decisions

#### DEC-003: Video Feature Cost Containment on Cloudflare Stream
- **Question:** How should video upload eligibility and storage quotas be governed to prevent runaway provider costs?
- **Recommended Default:** Limit video attachment to at most 1 video per listing, strictly capped at 30 seconds. Video uploads are initially restricted to verified accounts or promotional packages ("Featured Listing with Video").
- **Alternatives:** Open video uploads to all users unconditionally (high initial cost exposure); completely disable video in MVP.
- **Consequences:** Lowers initial operational costs while still launching the unique vertical video feed feature.
- **Owner Approval Required:** Yes (Non-blocking for Milestone 1).

#### DEC-004: In-App Purchases (IAP) vs. External Paymob Web Checkout for Promotions
- **Question:** How will listing promotions ("Featured Ad") be sold on iOS and Android without violating Apple App Store Review Guideline 3.1.1 / Google Play Billing policies?
- **Recommended Default:** Real-world classifieds advertising services qualify as physical/advertising services outside the scope of digital consumables under specific regional rules; however, the safest MVP path is offering Paymob web-based checkout or in-app browser redirect.
- **Alternatives:** Implement native Apple In-App Purchases and Google Play Billing (requires paying 15–30% platform commission and dual payment infrastructure).
- **Owner Approval Required:** Yes (Non-blocking for core backend CRUD).

---

### Category C: Deferrable Decisions (Post-MVP / Phase 2)

#### DEC-005: Transition from PostgreSQL Search to Dedicated Search Engine
- **Question:** At what catalog volume should Market Space migrate from PostgreSQL `pg_trgm` to Meilisearch or Elasticsearch?
- **Recommended Default:** Retain PostgreSQL `pg_trgm` up to 200,000 active listings. Evaluate migration when median search latency exceeds 250ms under peak load.
- **Alternatives:** Prematurely provision Elasticsearch on day one (wastes RAM and ops maintenance).
- **Owner Approval Required:** No (Deferred to Phase 2).

#### DEC-006: In-App Escrow and Courier Delivery Integration
- **Question:** Should the platform offer in-app product purchasing with door-to-door courier shipping (like Bosta or Aramex)?
- **Recommended Default:** Pure classifieds peer-to-peer communication model for MVP. Defer shipping and escrow to future e-commerce expansion phases.
- **Owner Approval Required:** No (Deferred).
