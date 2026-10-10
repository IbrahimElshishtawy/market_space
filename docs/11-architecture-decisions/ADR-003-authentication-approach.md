# ADR-003: Authentication and Identity Verification Strategy

## Status
Approved

## Context
In Egypt, peer-to-peer commerce platforms rely predominantly on mobile phone numbers rather than email addresses. Sellers and buyers anticipate friction-free registration, but the platform must also prevent phone-spoofing and bot accounts.
Options:
1. **Email + Password:** Lowest friction/cost, but poor alignment with Egyptian user habits; invites throwaway bot accounts.
2. **Egyptian Mobile Phone Number + SMS OTP (Primary) with Optional Password:** Standard industry pattern in Egypt (used by Dubizzle, Talabat, etc.). Validates user authenticity immediately.
3. **Third-Party Social Auth (Google / Apple):** Convenient on mobile, but Apple requires specific sign-in rules, and many Egyptian users lack synchronized Apple/Google accounts for classifieds.

## Decision
We adopt **Egyptian Mobile Phone Number (`+20`) with SMS OTP as the primary authentication and registration mechanism**, supplemented by a password option for recurring logins.
- Authentication tokens use the standard JWT pair: short-lived Access Token (15 min) and long-lived, rotatable Refresh Token (30 days).
- Social login is deferred to Phase 2.
- Local Egyptian SMS gateways (SMS Misr / Infobip) will be used to optimize delivery rates and costs.

## Consequences
- **Positive:**
  - High trust: Every seller has a verified phone number for communication (Call / WhatsApp).
  - Matches native user expectations in Egypt.
- **Negative:**
  - SMS OTP incurs financial cost per message. Mitigated by strict Redis rate limiting (max 3 OTP requests / 15 min per number and IP) and 3-minute token validity.
