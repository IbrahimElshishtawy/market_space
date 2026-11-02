# Deal One — Open Business & Operational Decisions Register

This document records architectural, product, and operational decisions that require formal sign-off from the project owner or executive business leadership before or during implementation.

---

## Decision 01: Mobile Application App Store Packaging Strategy

### Context
The mobile codebase is structured as a Clean Architecture Flutter Monorepo. We must decide whether to publish one single unified application or two separate mobile apps to the Google Play Store and Apple App Store.

### Options Evaluated:
- **Option A (Separate Applications):**
  - Publish `Deal One` for consumers and `Deal One Business (أعمال)` for merchants.
  - *Pros:* Independent branding for enterprise B2B sellers.
  - *Cons:* Doubles marketing spend (must market two separate apps), doubles App Store review management, splits user ratings, and creates friction for individual users who want to both buy and sell.
- **Option B (Single Unified Application with Account Switcher — RECOMMENDED):**
  - Publish a single `Deal One` app. Every user can browse and purchase. A side drawer / profile menu provides an "Account Switcher (محول الحسابات)" allowing the user to seamlessly toggle to merchant mode for any business accounts they own or manage.
  - *Pros:* Zero split in user acquisition cost, single App Store presence, maximum organic conversion of buyers into sellers.
  - *Cons:* Slightly larger single mobile app bundle size.

### Technical Recommendation:
**Adopt Option B (Unified Application with Account Switcher)**. This matches ADR-005 and is supported natively by `/api/v1/accounts/my-accounts`.

### Sign-off Status:
- [ ] Approved by Product Owner: ___________________ Date: _________

---

## Decision 02: Initial Numerical Daily Quota Thresholds

### Context
To prevent automated web scraping of seller phone numbers and spam advertising, Deal One enforces daily quotas managed by Redis counters that reset at midnight Cairo time. Default values must be approved for V1 launch.

### Options Evaluated:
| Quota Dimension | Individual Seller (`individual`) | Commercial Account (`company`, `factory`, `store`) |
|---|:---:|:---:|
| **Daily Listing Submissions** | 3 listings / day | 30 listings / day |
| **Daily Phone Reveals (External Call/WhatsApp)** | 15 reveals / day | 100 reveals / day |
| **Daily Chat Conversations Initiated** | 20 chats / day | Unlimited (or 200 / day) |

### Technical Architecture Note:
These thresholds are stored in the database table `platform_settings` and cached in Redis. They can be modified by the Super Admin in real-time from the Admin Control Center without deploying code.

### Sign-off Status:
- [ ] Approved by Product Owner: ___________________ Date: _________

---

## Decision 03: Listing Expiration & Automatic Archiving Period

### Context
Listings must not remain active indefinitely to prevent stale advertisements, outdated prices, or sold properties cluttering search results.

### Options Evaluated:
- **Option A (Uniform 30-Day Expiry):**
  - Every listing across all categories expires 30 days after publication unless renewed by the seller.
- **Option B (Category-Specific Expiration — RECOMMENDED):**
  - Fast-moving consumer goods (Fashion, Home Appliances): **30 Days**.
  - High-value considered purchases (Real Estate, Automotive, Industrial Materials): **60 to 90 Days**.
  - System sends an automated push notification 3 days prior to expiration: *"إعلانك سينتهي خلال 3 أيام — اضغط هنا للتجديد بنقرة واحدة"*.

### Technical Recommendation:
**Adopt Option B**. Real estate transactions have longer consideration cycles; forcing a broker to re-list a luxury villa every 30 days causes high churn and frustration.

### Sign-off Status:
- [ ] Approved by Product Owner: ___________________ Date: _________

---

## Decision 04: Public Price Transparency Policy for Industrial B2B Categories

### Context
In Building Materials (steel, cement) and Services, prices fluctuate daily or depend on bespoke project quotations. Some merchants prefer listing without a fixed price or marking "Call for Price / السعر عند التواصل".

### Options Evaluated:
- **Option A (Mandatory Fixed Price):**
  - Requires `price > 0` on every listing across all categories.
- **Option B (Category-Driven Price Mode — RECOMMENDED):**
  - Allow `price = 0` with an explicit flag `price_on_inquiry: true` for Building Materials and Services, while enforcing strict prices for Fashion, Cars, and Appliances.

### Technical Recommendation:
**Adopt Option B**. This aligns with ADR-003 (Category-Driven Business Rules) and reflects the actual realities of the Egyptian construction material market.

### Sign-off Status:
- [ ] Approved by Product Owner: ___________________ Date: _________
