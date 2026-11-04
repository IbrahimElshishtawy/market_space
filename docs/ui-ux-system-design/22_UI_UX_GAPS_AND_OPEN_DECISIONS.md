# 22 — UI/UX Gaps, Codebase Conflicts & Open Decisions

## 1. Executive Summary

This document serves as the **authoritative conflict register and gap analysis report** for the Deal One project. It isolates and resolves every discrepancy identified between the **existing Flutter codebase (`market_space/lib`)**, the **legacy design drafts**, and the **approved V1 product architecture (`Deal_One_SRS.md`, `Deal_One_Architecture_Decisions.md`, `backend_blueprint/`)**.

Maintaining transparency regarding these gaps prevents engineering regressions and ensures that the UI/UX Designer and AI UI Agent build only approved, cohesive features.

---

## 2. Identified Codebase Conflicts & Authoritative Resolutions

### Conflict 1: Mock E-Commerce Screens in Flutter vs. V1 Free-Listing Mandate
- **Discovered Codebase Evidence:** 
  - `BuildingMaterialsCartPage`, `BuildingMaterialsCheckoutPage`, `BuildingMaterialsOrdersPage`.
  - `HomeAppliancesCartPage`, `HomeAppliancesCheckoutPage`, `HomeAppliancesOrdersPage`.
  - `FashionCartPage`.
- **Approved Architectural Standard:** **ADR-008 (Transaction Modes)** and **ADR-009 (Commerce Module Boundary)** explicitly state:
  > *"Deal One V1 is strictly a free-listing marketplace in `contact_only` mode. Online payment gateways, shopping carts, checkout, order management, and detailed inventory tracking are strictly deferred to future phase V3."*
- **Authoritative Resolution:**
  - Classify all 7 cart, checkout, and order screens as **Tier 1 Prototype / Tier 3 Future Features**.
  - For the V1 launch UI, remove all Cart buttons from the app bars and product detail pages.
  - Replace "أضف إلى السلة" (Add to Cart) with "تواصل مع البائع" (Contact Seller via Chat/WhatsApp).

---

### Conflict 2: Tab 2 ("My Activity") Divergence
- **Discovered Codebase Evidence:** `MyActivityPage` ([lib/features/activity/presentation/pages/my_activity_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/activity/presentation/pages/my_activity_page.dart)) displays an aggregated timeline of mock consumer orders, RFQs, and maintenance bookings under the title *"طلباتي ومعاملاتي"*.
- **Approved Architectural Standard:** Under **ADR-007 (Independent Listing Lifecycle States)**, users and merchants need a central hub to manage their published listings across orthogonal status axes (`active`, `pending`, `rejected`, `hidden`, `sold`), view admin moderation feedback, and toggle visibility.
- **Authoritative Resolution:**
  - In V1, Tab 2 becomes **"إعلاناتي" (My Advertisements Management Hub - `SCR-ACT-002`)**, consuming `API-LST-008`.
  - The existing order/booking code is archived under a future `commerce_activity` feature branch for V3.

---

### Conflict 3: Booking Wizard & Real-Time Technician Tracking vs. V1 Scope
- **Discovered Codebase Evidence:**
  - `HomeServicesBookingWizardPage` (`/home-services/book`)
  - `TechnicianTrackingPage` (`/home-services/tracking`)
  - `HomeServiceBookingDetailPage` (`/home-services/booking-detail`)
- **Approved Architectural Standard:** **ADR-010 (Booking Module Boundary)** explicitly defers automated scheduling calendars, time-slot reservation engines, and live GPS technician dispatch to **Future Milestone V3**.
- **Authoritative Resolution:**
  - In V1, home services listings provide direct communication with verified technicians via **In-App Chat (`SCR-CHT-002`)**, **Direct Phone Call**, or **WhatsApp**.
  - The booking wizard and technician tracking screens remain in the repository as architectural scaffolding, but their navigation entry points are disconnected from V1 service cards.

---

### Conflict 4: Disconnect Between Repositories and `ApiClient` (Audit Finding CRIT-02)
- **Discovered Codebase Evidence:** `ApiClient` is configured in `bootstrap.dart` with Dio interceptors, but **zero repositories** in `lib/features/` consume it. All feature repositories currently return hardcoded mock lists with artificial `Future.delayed()`.
- **Approved Architectural Standard:** **Backend Blueprint Section 09 (Flutter Integration)** specifies concrete remote repositories mapping to the 52 REST endpoints.
- **Authoritative Resolution:**
  - UI Agent must design screens against the concrete DTO schemas defined in [20_SCREEN_TO_API_TRACEABILITY.md](20_SCREEN_TO_API_TRACEABILITY.md).
  - Repositories must be migrated from in-memory mocks to `ApiClient` remote calls in Phase 2.

---

### Conflict 5: Missing Authentication & Onboarding Routes in Flutter Router
- **Discovered Codebase Evidence:** `app_router.dart` routes cold boots directly into `GlobalNavigationScaffold` (`RouteNames.root`). There are zero routes for `/login`, `/register`, or `/otp`. `SessionRouteGuard` exists as an empty placeholder returning `null`.
- **Approved Architectural Standard:** Phone OTP authentication (`API-AUTH-001`, `API-AUTH-002`) is required before performing protected actions (Favoriting, In-App Chat, Contact Reveal, Posting Ads).
- **Authoritative Resolution:**
  - Implement `SCR-AUT-001` and `SCR-AUT-002` as bottom sheets and declarative routes.
  - Wire `SessionRouteGuard` to intercept protected routes and present the login sheet.

---

### Conflict 6: Redundant Sector-Specific Favorites & Notifications Screens
- **Discovered Codebase Evidence:**
  - `RealEstateFavoritesPage` and `HomeServicesFavoritesView` duplicate `GlobalFavoritesPage`.
  - `RealEstateNotificationsPage`, `BuildingMaterialsNotificationsPage`, `HomeAppliancesNotificationsPage` duplicate `GlobalNotificationsPage`.
- **Approved Architectural Standard:** **ADR-002 (Shared Core Architecture)** strictly prohibits duplicating shared systems (Favorites, Notifications) across verticals.
- **Authoritative Resolution:**
  - Eliminate the sector-specific duplicate pages.
  - Consolidate all bookmarks into `GlobalFavoritesPage` (`SCR-ACT-001`) with sector filtering tabs.
  - Consolidate all alerts into `GlobalNotificationsCenter` (`SCR-NOT-001`).

---

## 3. Open Business Decisions Requiring Stakeholder Sign-Off

The following design decisions are recorded as open items requiring business decision. Grounded architectural recommendations are provided:

### Decision 1: Guest External Contact Reveals (Phone / WhatsApp)
- **Problem:** Can unauthenticated guest visitors reveal seller phone numbers and launch WhatsApp, or must they log in via OTP first?
- **Architectural Trade-Off:** Allowing guests to reveal numbers increases lead conversion, but exposes seller numbers to automated scraping and prevents daily quota enforcement.
- **Recommendation:** **Require Authentication (`SCR-AUT-001`) before revealing external phone/WhatsApp contacts**. This protects sellers from phone harvesting and allows `API-SRC-003` to enforce the 15-contact daily limit per user.

---

### Decision 2: Onboarding Flow for First-Time App Installs
- **Problem:** `StorageKeys.onboardingCompleted` exists in storage keys, but no onboarding carousel screens exist in Flutter. Should a 3-screen onboarding carousel be built for V1?
- **Architectural Trade-Off:** Multi-screen onboarding carousels increase drop-off during first open.
- **Recommendation:** **Direct Entry to Home Discovery**. Eliminate multi-screen onboarding for V1. Allow first-time users to land immediately on the high-energy Home Feed (`SCR-HOM-001`), using contextual inline tooltip pills on first interaction with key features.

---

### Decision 3: Mandatory Document Verification for Individual Sellers
- **Problem:** **ADR-004** mandates verification for commercial accounts (`company`, `factory`, `office`, `store`). Should an individual private seller (`individual`) be required to upload a National ID before posting a single personal ad?
- **Architectural Trade-Off:** Requiring National ID for individuals drastically reduces initial listing supply, but eliminates duplicate spam accounts.
- **Recommendation:** Allow individual sellers to post up to **2 active listings** in personal categories (used clothes, used car, personal property) without National ID verification, subject to strict automated keyword and manual moderation. Mandatory National ID verification triggers upon creating a 3rd listing or creating a commercial account.

---

## 4. Architectural Risk Register & Mitigation Strategy

| Risk ID | Identified Risk Description | Impact | Architectural Mitigation Strategy |
|---|---|:---:|---|
| **RSK-01** | Release build crash due to missing `INTERNET` permission in Android manifest | **CRITICAL** | Add `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`. |
| **RSK-02** | Uncontrolled cellular data consumption from un-cached high-res property photo galleries | **HIGH** | Replace raw `Image.network` in `AppNetworkImage` with `cached_network_image` backed by disk storage. |
| **RSK-03** | Automated test suite failures (6 broken tests) blocking CI/CD pipelines | **HIGH** | Update test fixture expectations in `app_bottom_navigation_test.dart` and `real_estate_page_test.dart`. |
| **RSK-04** | Accidental leakage of confidential exact GPS coordinates of residential properties | **HIGH** | Enforce ADR-006 two-tier coordinates: client API DTOs only expose `display_location` centroid. |

