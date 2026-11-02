# Deal One — Documentation, Code & Architecture Conflict Audit

## 1. Executive Summary

As part of the backend architecture phase for **Deal One**, a forensic cross-document and code-level audit was conducted across:
1. All 10 existing specification files in `mock_data/` and `docs/`.
2. The initial backend codebase in `backend/` (NestJS, Fastify, Prisma schema).
3. The client application codebase in `market_space/lib/` (Flutter Monorepo).
4. The mock data payloads in `mock_data/*.json`.

This report catalogs all identified architectural, functional, data modeling, and operational conflicts, their source documents, technical and business impacts, and the binding resolutions formally ratified in Architecture Decision Records (ADR-001 through ADR-014).

---

## 2. Inventory of Audited Documents & Artifacts

| Artifact | Location | Status / Role |
|---|---|---|
| `Deal_One_Apps_Workflows.md` | `mock_data/` | Mobile app workflows, screen inventory, ERD |
| `Deal_One_Architecture_Decisions.md` | `mock_data/` | Formal ADR register (ADR-001 to ADR-012) |
| `Deal_One_Business_Analysis.md` | `mock_data/` | Business viability, market positioning, phasing |
| `Deal_One_Documentation_Consistency_Report.md` | `mock_data/` | Prior consistency review |
| `Deal_One_Filter_Architecture.md` | `mock_data/` | PostGIS spatial queries, GIN index filter design |
| `Deal_One_Flutter_Architecture.md` | `mock_data/` | Flutter Clean Architecture, Drift, Freezed |
| `Deal_One_Master_Architecture.md` | `mock_data/` | Authoritative master reference |
| `Deal_One_SRS.md` | `mock_data/` | Software Requirements Specification v2.0 |
| `Deal_One_System_Design.md` | `mock_data/` | Low-level design & component specification |
| `وثيقة متطلبات البرنامج Deal One.pdf` | `mock_data/` | Original baseline product specification |
| `schema.prisma` | `backend/prisma/` | Existing initial draft database schema |
| `app.module.ts` | `backend/src/` | Existing backend modules setup |
| `market_space/lib/` | `market_space/` | Current Flutter frontend implementation |

---

## 3. Detailed Conflict Matrix & Resolution Register

### Conflict 1: Global Account "Online Sales Mode" vs. Phased Category-Driven Transactions
- **Conflicting Documents:** `Deal_One_System_Design.md` (Sec 3, 5.2, 6.5) vs. `Deal_One_Architecture_Decisions.md` (ADR-001, ADR-008) vs. `Deal_One_Master_Architecture.md`.
- **The Issue:** Early drafts specified an account-level boolean toggle (`sales_mode: online_payment | contact_only`). When enabled, it forced all listings belonging to that seller to require online payment, auto-hiding any listing without a fixed price.
- **Business Impact:** Devastating to sellers operating across multiple sectors (e.g., a trader selling building materials on inquiry while selling uniforms; a real estate developer offering both consulting and rental units). It also premature-loads payment gateway licensing, escrow liabilities, and tax invoicing into V1 launch.
- **Technical Impact:** Tight coupling between user account state and listing rendering queries. Breaking change if a seller changes the setting.
- **Approved Resolution (ADR-008):**
  1. Eliminate any global account-level transaction mode toggle.
  2. Scope **V1 entirely to `contact_only`** across all categories and accounts.
  3. Manage contact channels per listing (`in_app` chat or `external` WhatsApp/phone).
  4. Defer online checkout, order items, carts, and payment gateways to **V3**.

---

### Conflict 2: Collapsed Single Listing Status vs. Orthogonal Independent Lifecycle Axes
- **Conflicting Documents & Code:**
  - `backend/prisma/schema.prisma` (lines 41-50): Defines a single `enum ListingStatus { DRAFT, PENDING_REVIEW, PUBLISHED, REJECTED, PAUSED, EXPIRED, SOLD, ARCHIVED }`.
  - `mock_data/listing_detail.json`: Defines `"status": "ACTIVE"`.
  - `Deal_One_Master_Architecture.md` and `Deal_One_SRS.md`: Defines 3 separate orthogonal axes.
- **The Issue:** Flattening moderation (approval), publication (visibility), and operational availability (stock/sold) into one column destroys state history. For example, if a seller temporarily hides an approved listing (`PAUSED`), the system forgets it was approved; if a seller edits a rejected listing, the previous moderator notes are lost or overwritten.
- **Business Impact:** Inability to audit moderation decisions, fraud risks, and poor seller experience.
- **Technical Impact:** Fragile search queries and race conditions during concurrent admin review and seller edits.
- **Approved Resolution (ADR-007):**
  - Implement three distinct, orthogonal database columns on `listings`:
    1. `moderation_status`: `draft`, `pending`, `approved`, `rejected`
    2. `publication_status`: `unpublished`, `published`, `hidden`, `archived`
    3. `availability_status`: `available`, `reserved`, `sold`, `rented`, `out_of_stock`, `discontinued`
  - Maintain an append-only immutable `moderation_log` table recording every decision, staff ID, reason code, and timestamp.
  - Action required in backend implementation: Refactor `schema.prisma` and related DTOs.

---

### Conflict 3: Direct User-to-Listing Relationship vs. Multi-tenant Independent Seller Accounts
- **Conflicting Code & Documents:**
  - `backend/prisma/schema.prisma` (lines 150, 243, 264): `Listing` directly references `User` (`userId String @map("user_id")`). No `Account` or `AccountMember` models exist in Prisma!
  - `Deal_One_Master_Architecture.md`, `Deal_One_Apps_Workflows.md` (Sec 2.1, 4.2), `Deal_One_SRS.md` (FR-ACC-001 to 011): Explicitly requires a multi-tenant hierarchy where a single authenticated `User` can own or belong to multiple independent `Accounts` with team roles (`owner`, `manager`, `lister`, `responder`).
- **The Issue:** The initial Prisma schema model treats Deal One like a simple single-user C2C classifieds app, making team collaboration and multi-company ownership impossible.
- **Business Impact:** High-value B2B real estate brokers, construction factories, and engineering firms cannot distribute listing tasks to staff without sharing their personal mobile OTP.
- **Technical Impact:** Total lack of data isolation between staff members; impossible to enforce B2B authorization.
- **Approved Resolution (ADR-005):**
  - Introduce `accounts` and `account_members` tables.
  - Every `Listing` belongs to an `account_id` (mandatory foreign key).
  - Every member has an explicit role: `owner`, `manager`, `lister`, `responder`.
  - User identity (`users`) is separated from the business entity (`accounts`).

---

### Conflict 4: Raw Physical Coordinates Exposure vs. Privacy-Preserving Geographic Architecture
- **Conflicting Documents:** `Deal_One_System_Design.md` (Sec 6.3) vs. `Deal_One_Filter_Architecture.md` (Sec 4) vs. `Deal_One_Architecture_Decisions.md` (ADR-006).
- **The Issue:** Early drafts exposed raw latitude and longitude floats directly in the public listing JSON payloads across all categories, including private villas, residential apartments, and luxury vehicles.
- **Business Impact:** Severe violation of user privacy and Egypt personal data protection standards; risk of stalking, theft, or bypass of brokers.
- **Technical Impact:** Security vulnerability; unauthorized scraping of exact property locations.
- **Approved Resolution (ADR-006):**
  - Split spatial data into two tiers:
    1. `physical_lat` / `physical_lng`: Exact physical coordinates (Point 4326), stored securely, indexed via PostGIS GIST, accessible only to listing owners and authorized staff. Used exclusively for backend distance calculations (`ST_Distance`).
    2. `display_lat` / `display_lng`: Fuzzed coordinates (randomized offset of 300–600 meters or district administrative centroid). This is the only coordinate payload returned to public mobile clients for residential properties.
  - Commercial retail stores and public branches may opt to disclose exact branch locations.

---

### Conflict 5: Immediate Microservices vs. Modular Monolith Architecture
- **Conflicting Documents:** `docs/03-system-architecture.md` (early mentions of multiple microservices with gRPC and Kafka) vs. `Deal_One_Architecture_Decisions.md` (ADR-012) vs. `Deal_One_Master_Architecture.md`.
- **The Issue:** Premature microservices split proposed for a team at V1 launch, introducing distributed transactions, dual-writes, network latency, Kubernetes orchestration overhead, and high cloud operational costs.
- **Business Impact:** Extreme risk of delayed launch, ballooned hosting expenses, and operational fragility.
- **Technical Impact:** Complex distributed tracing, eventual consistency nightmares for listing moderation and quotas.
- **Approved Resolution (ADR-012):**
  - Adopt a **Modular Monolith** in a single codebase with clearly defined, strictly isolated Bounded Contexts.
  - Cross-module communication only through designated TypeScript Domain Interfaces / Service APIs (no direct foreign table SQL joins).
  - Single primary PostgreSQL 16 database with PostGIS + Redis 7 for caching, queues (BullMQ), and ephemeral quotas.
  - Clean boundary isolation ensures that any high-load module (e.g., Search or Chat) can be extracted into an independent microservice in the future without rewriting domain logic.

---

### Conflict 6: Payment Gateway Inclusion in V1 vs. Strict V1 Contact-Only Scope
- **Conflicting Artifacts:** `backend/prisma/schema.prisma` (lines 63-68, 343-378: `PromotionPackage`, `Payment`, `PaymentStatus`) and `backend/src/modules/payments/` exist in code, whereas ADR-008, ADR-009, and `Deal_One_SRS.md` state payments are out of scope for V1.
- **The Issue:** Code contains preliminary Paymob integration tables and modules for listing promotion payments, whereas business strategy explicitly froze monetization and payments to focus on organic liquidity and friction-free listings during V1.
- **Approved Resolution:**
  - In V1, all promotions (featured tags, bump-ups) are administrative-only or promotional grants managed via `platform_settings` and admin moderation.
  - The payment module remains disabled in V1 production routes and is archived until V2/V3 monetization roadmap activation.

---

### Conflict 7: Notification Architecture Phasing (FCM vs. Saved Search Alerts)
- **Conflicting Documents:** `Deal_One_System_Design.md` (Section 18 deferred all push notifications to V2) vs. `Deal_One_SRS.md` and `Deal_One_Architecture_Decisions.md` (ADR-011).
- **The Issue:** Delaying all push notifications to V2 breaks critical V1 workflows: a seller would never know their listing was approved or rejected without opening the app, and chat messages would be missed.
- **Approved Resolution (ADR-011):**
  - **V1 (Operational Push Notifications via FCM):** Mandatory for account verification results, listing approval/rejection reasons, incoming chat messages, and quota warnings.
  - **V2 (Marketing & Growth Alerts):** Saved searches, background crawler match alerts, and promotional push campaigns.

---

## 4. Summary of Code Refactoring Mandates for Backend Team

Before launching V1 backend engineering:
1. **Prisma Schema Overhaul:** Replace `backend/prisma/schema.prisma` with the unified 24-entity schema defined in `02_DATABASE_DESIGN.md`.
2. **Account Context Injection:** Update authentication and request pipelines to inject `activeAccountId` alongside `userId`.
3. **Status Axes Refactoring:** Replace single enum `ListingStatus` with the 3 orthogonal status axes (`moderation_status`, `publication_status`, `availability_status`).
4. **Append-Only Logging:** Add `moderation_log` and `audit_log` with immutable insert-only enforcement.
5. **PostGIS Spatial Setup:** Integrate PostGIS spatial extension into migrations.
