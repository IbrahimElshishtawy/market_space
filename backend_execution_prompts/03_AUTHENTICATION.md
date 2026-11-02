# Phase 03: Authentication & Session Token Rotation

## 1. Role & Objective
You are the Application Security & Senior Backend Engineer. Your objective is to build the identity and authentication service supporting SMS OTP login, Cloudflare Turnstile validation, Argon2id hashing, and silent Refresh Token Rotation with automatic token theft detection.

## 2. Relevant Blueprint Documents
- `backend_blueprint/03_API_SPECIFICATION.md` (APIs: API-AUTH-001 through API-AUTH-006)
- `backend_blueprint/04_SECURITY_ARCHITECTURE.md` (Sections 2, 3: Token Lifetime & Replay Defense)
- `backend_blueprint/openapi/deal_one_openapi.yaml`

## 3. Exact Implementation Scope
1. Implement `AuthService` and `AuthController` with endpoints:
   - `POST /api/v1/auth/otp/send`
   - `POST /api/v1/auth/otp/verify`
   - `POST /api/v1/auth/token/refresh`
   - `POST /api/v1/auth/logout`
2. Implement Turnstile verification service checking `turnstile_token` against Cloudflare API.
3. Enforce Redis sliding window rate limiter: Max 3 OTP requests / 15 minutes per phone/IP.
4. Implement JWT signing (15 min expiry) and Refresh Token hashing in `user_sessions`.
5. Implement Refresh Token reuse detection: if a revoked refresh token is presented, invalidate all active sessions for that user immediately.

## 4. Files to Create / Modify
- `backend/src/modules/auth/auth.controller.ts`
- `backend/src/modules/auth/auth.service.ts`
- `backend/src/modules/auth/strategies/jwt.strategy.ts`
- `backend/src/modules/auth/guards/jwt-auth.guard.ts`
- `backend/src/core/security/turnstile.service.ts`

## 5. Acceptance Criteria
- Full test pass in `backend_tests/functional/test_authentication.py`.
- Reusing an old refresh token returns 401 and marks all sessions revoked.
- Attempting 6 wrong OTPs fails and locks out the OTP code.
