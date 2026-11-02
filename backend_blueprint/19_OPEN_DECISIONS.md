# Deal One — Formal Business & Operational Decisions Register

**Baseline Architecture Version:** `1.0.0-AUDITED`  
**Sign-off Status:** Formal Pre-Implementation Adoption Certified (2 November 2026)

This document records the official architectural and operational decisions adopted for the Deal One V1 launch. All business thresholds are stored in the database table `platform_settings` and cached in `redis_cache`, allowing Super Admins to dynamically update them from the Admin Control Center in real time without deploying code.

---

## Decision 01: Mobile Application App Store Packaging Strategy

### Approved Decision:
**Adopt Option B: Single Unified Application with Account Switcher (محول الحسابات)**.

### Rationale:
- A single unified mobile application bundle (`market_space/`) will be published to Google Play and the Apple App Store.
- Eliminates split user acquisition costs and fragmented App Store ratings.
- Every user begins as a consumer and can seamlessly switch into merchant mode for any business account they own or manage via the native account switcher drawer.
- Backed natively by `GET /api/v1/accounts/my-accounts` and multi-tenant header `X-Account-ID`.

### Sign-off Status:
- [x] **APPROVED & ADOPTED FOR V1** (Date: 2 November 2026)

---

## Decision 02: Initial Numerical Daily Quota Thresholds

### Approved Baseline Values:
Enforced via atomic Redis Lua counters with automatic expiration at midnight (`00:00:00 Africa/Cairo`):

| Quota Dimension | Individual Seller (`individual`) | Commercial Account (`company`, `factory`, `store`) |
|---|:---:|:---:|
| **Daily Listing Submissions** | **3 listings / day** | **30 listings / day** |
| **Daily Contact Reveals (Call / WhatsApp)** | **15 reveals / day** | **100 reveals / day** |
| **Daily Chat Conversations Initiated** | **20 chats / day** | **Unlimited** (Capped at 500 for anti-abuse) |

### Administrative Control:
These limits are initialized via database seeders into `platform_settings` under keys:
- `daily_quota_individual_listings`
- `daily_quota_individual_reveals`
- `daily_quota_individual_chats`
- `daily_quota_business_listings`
- `daily_quota_business_reveals`
They are cached in `redis_cache` and editable via `PUT /api/v1/admin/platform-settings`.

### Sign-off Status:
- [x] **APPROVED & ADOPTED FOR V1** (Date: 2 November 2026)

---

## Decision 03: Listing Expiration & Automatic Archiving Period

### Approved Decision:
**Adopt Category-Specific Expiration Strategy**.

### Approved Baseline Periods:
1. **Fast-Moving Consumer Goods (Fashion, Home Appliances):** **30 Days**.
2. **Considered & High-Value Assets (Real Estate, Automotive, Industrial Equipment):** **60 to 90 Days** (Baseline: 60 days default).
3. **Automated Warning:** The BullMQ notification worker sends an automated push notification via FCM 3 days before expiration offering 1-click renewal.
4. **Expiration Action:** When expired, `publication_status` transitions from `published` to `expired`. The listing disappears from public search results but remains visible in the merchant ad management feed with a "Renew / تجديد" action.

### Administrative Control:
Periods are stored in `categories.default_expiry_days` and `platform_settings`.

### Sign-off Status:
- [x] **APPROVED & ADOPTED FOR V1** (Date: 2 November 2026)

---

## Decision 04: Public Price Transparency Policy for Industrial B2B Categories

### Approved Decision:
**Adopt Category-Driven Price Mode with `price_on_inquiry`**.

### Approved Rules:
1. **Mandatory Numerical Price (`price > 0`):**
   - Mandatory for: Real Estate, Automotive, Fashion, and Home Appliances.
2. **Inquiry Price Allowed (`price_on_inquiry: true`):**
   - Permitted for: Building Materials (e.g. bulk rebar, cement, gravel where spot prices fluctuate daily) and Services (bespoke contracting and maintenance).
   - In search results and listing cards, when `price_on_inquiry == true`, the UI displays *"السعر عند التواصل / Price on Inquiry"* instead of `0 EGP`.

### Administrative Control:
Configured per subcategory via `category_fields` and `categories.allow_price_on_inquiry` boolean flag.

### Sign-off Status:
- [x] **APPROVED & ADOPTED FOR V1** (Date: 2 November 2026)

---

## Decision Register Summary

| Decision ID | Subject | Approved V1 Policy | Dynamic Admin Control? |
|---|---|---|:---:|
| **DEC-001** | Mobile Packaging | Single Unified App + Account Switcher | Static (Store Distribution) |
| **DEC-002** | Daily Quotas | Individual: 3/15/20; Business: 30/100/Unlimited | **Yes** (`PUT /admin/platform-settings`) |
| **DEC-003** | Listing Expiration | Category-specific: 30d FMCG / 60d Real Estate | **Yes** (`categories.default_expiry_days`) |
| **DEC-004** | Price Transparency | Category-driven (`price_on_inquiry` for B2B) | **Yes** (`categories.allow_price_on_inquiry`) |

*All approved decisions are locked as the baseline configuration for Phase 01 through Phase 17 implementation.*
