# ADR-009: Payments Architecture, Paymob Integration & Mobile Store Policies

## Status
Approved

## Context
Market Space monetizes listings through premium visibility options:
- Bumping an ad back to the top of category feeds.
- Featured ribbons with highlighted borders for 7 or 14 days.

Key considerations in Egypt:
- Egyptian consumers predominantly pay using local cards, Meeza cards, and mobile wallets (Vodafone Cash, Orange Money, Etisalat Cash, WE Pay).
- Paymob is the leading payment orchestrator in Egypt supporting all these payment rails under unified API contracts and webhook delivery.
- Mobile Store Policies (Apple App Store Guideline 3.1.1 and Google Play Billing): Selling purely digital goods in an app typically requires Apple/Google In-App Purchase (IAP) with a 15–30% commission. However, advertising services that promote physical classifieds products historically benefit from specific physical/advertising service exemptions, provided checkout is handled transparently.

## Decision
1. We integrate **Paymob as the authoritative payment gateway** for EGP transactions (Cards, Meeza, and Mobile Wallets).
2. All pricing is computed authoritatively on the backend.
3. Entitlements are applied strictly upon verified server-to-server webhook confirmation featuring cryptographic HMAC SHA512 signature validation and database idempotency checks.
4. For mobile app clients, promotional purchases will open a secure Paymob hosted checkout URL in an in-app browser sheet, or initiate localized mobile wallet prompts.
5. In-App Purchase (IAP) policies will undergo formal review by the project owner and legal/store consultants prior to public App Store / Google Play submission.

## Consequences
- **Positive:**
  - Full support for the most popular Egyptian payment rails (especially Vodafone Cash and Meeza).
  - Robust protection against client-side spoofing or fake transaction alerts.
- **Negative:**
  - Reliance on Paymob webhook delivery uptime; mitigated by automated manual reconciliation tools in the Next.js admin portal.
