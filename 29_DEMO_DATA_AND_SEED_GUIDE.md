# Deal One – Comprehensive Demo Dataset & Seeding Operational Guide

**Document Version:** 1.0.0  
**Target Environment:** Development, Testing, Staging  
**Author:** Senior Database Engineer & Backend Architect  
**Project:** Deal One (`https://github.com/IbrahimElshishtawy/one-deal.git`)

---

## 1. Overview & Architecture

The Deal One marketplace dataset represents a realistic, production-grade Egyptian commercial ecosystem. It covers all **6 top-level commercial sections** and **34 active leaf subcategories** with a balanced distribution of authentic Egyptian Arabic titles, realistic descriptions, market prices in EGP, local governorates, contact info, and category-specific JSONB attributes.

### Key Architecture Features
1. **Schema Isolation:** All demo listings, accounts, and demo users carry `isDemo: true` (backed by PostgreSQL btree indexes).
2. **Strict Non-Destructive Reset:** The `--reset-demo` operational flag purges **only** records tagged with `is_demo = true`. Genuine user accounts, real listings, and production transactions are never deleted.
3. **Idempotency:** Re-running the seed script does not duplicate listings or media assets.
4. **PostGIS Spatial Coordinates:** Every listing includes valid latitude and longitude coordinates placed across Egyptian governorates (Cairo, Giza, Alexandria, Mansoura, Assiut, Red Sea, etc.) enabling accurate radius and distance filtering.

---

## 2. Dataset Hierarchy & Commercial Coverage

The database contains **340 unique demo listings** (exactly 10 listings per active leaf category).

| Commercial Sector | Leaf Subcategories | Listings Count | Key Sample Persisted Attributes |
| :--- | :--- | :---: | :--- |
| **1. Real Estate (`real-estate`)** | `apartments-for-sale`, `apartments-for-rent`, `villas-for-sale`, `commercial-for-sale`, `chalets-rent-sale`, `lands-for-sale` | 60 | `rooms`, `baths`, `area_sqm`, `finishing`, `floor`, `furnished` |
| **2. Building Materials (`building-materials`)** | `steel-rebar`, `cement-gypsum`, `red-bricks-blocks`, `plumbing-supplies`, `electrical-cables`, `paints-coatings`, `tiles-ceramics` | 70 | `material_type`, `unit`, `min_order_qty`, `origin`, `grade`, `specs` |
| **3. Home Services (`services`)** | `plumbing-services`, `electrical-services`, `ac-maintenance`, `painting-finishing`, `carpentry-services`, `house-cleaning` | 60 | `service_type`, `pricing_model`, `experience_years`, `warranty_days` |
| **4. Appliances & Decor (`home-appliances`)** | `refrigerators-freezers`, `washing-machines`, `air-conditioners`, `tvs-screens`, `kitchen-appliances`, `home-furniture` | 60 | `brand`, `condition`, `warranty_years`, `color`, `model_year` |
| **5. Cars (`cars`)** | `sedan-cars`, `suv-cars`, `commercial-trucks`, `auto-spare-parts` | 40 | `brand`, `model`, `year`, `mileage_km`, `transmission`, `fuel_type` |
| **6. Clothes & Accessories (`fashion`)** | `mens-clothing`, `womens-clothing`, `shoes-footwear`, `watches-accessories`, `perfumes-beauty` | 50 | `gender`, `size`, `color`, `condition`, `material` |
| **Total** | **34 Leaf Categories** | **340 Listings** | **342 Verified Media Objects** |

---

## 3. Seed Execution Commands

All commands are executed from the `backend/` directory:

### 3.1 Standard Seed (Upsert & Populate)
```bash
cd backend
npm run seed
```
- Verifies database connections and applies category tree, Egyptian locations, demo accounts, and all 340 demo listings.
- Safe to run on existing local or staging databases.

### 3.2 Safe Demo Reset (Clean Re-seed)
```bash
cd backend
npm run seed -- --reset-demo
```
- Queries `WHERE is_demo = true` on `listings`, `accounts`, and `users`.
- Removes demo media and demo listings only.
- Leaves all non-demo users, organic listings, chat messages, and transactions untouched.
- Re-populates the standard 340-item Egyptian marketplace dataset.

### 3.3 Regeneration via Python Script
To regenerate the full TypeScript demo dataset generator file:
```bash
python3 scripts/build_full_340_dataset.py
```
This updates `backend/prisma/seeds/demo-listings-generator.ts`.

---

## 4. Demo Sellers & Branch Structure

The demo seed generates verified Egyptian corporate and individual seller personas:
- **Ezz Steel & Heavy Construction Supplies** (Company, Cairo & Alexandria branches)
- **El-Sewedy Electrical Solutions** (Company, Giza branch)
- **Sodic & Palm Hills Real Estate Brokerage** (Corporate Agency, New Cairo & Zayed branches)
- **El-Araby Electronics & Home Appliances** (Corporate Store, Multiple branches)
- **Auto Trade Egypt** (Verified Car Dealership, Nasr City branch)
- **Al-Safwa Architectural Finishing & Contracting** (Engineering Office, Cairo)
- **Individual Demo Sellers** (Verified Egyptian phone identities)

All demo accounts adhere to KYC constraints and are pre-verified for seamless browsing in mobile MVP testing.

---

## 5. Media & Image Strategy

- Each listing is associated with high-resolution imagery served via Unsplash CDN with optimized WebP/JPEG parameters (`auto=format&fit=crop&w=800&q=80`).
- Category-relevant images: Real estate depicts contemporary Egyptian compounds and apartments; cars depict actual vehicle brands; building materials depict steel rebar, cement bags, and wiring.
- If an image fails to load on a mobile device due to carrier filtering or poor connectivity, the Flutter UI incorporates a graceful image placeholder with retry logic.

---

## 6. Environment Policies & Safeguards

| Environment | Policy | Behavior |
| :--- | :--- | :--- |
| **Local Dev** | Enabled | Full 340 listings populated for fast frontend iteration. |
| **Staging / QA** | Enabled | Provides consistent test fixtures for automated UI & manual mobile QA. |
| **Production** | **STRICTLY DISABLED** | Seed execution aborted automatically if `NODE_ENV=production` unless explicit override environment variable `ALLOW_PRODUCTION_DEMO_SEED=true` is provided. |
