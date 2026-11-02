# Phase 04: Multi-Tenant Accounts & Team RBAC

## 1. Role & Objective
You are the Senior Backend Engineer. Your objective is to implement the independent seller account system, the mobile Account Switcher APIs, and the team RBAC authorization guard protecting against BOLA / IDOR attacks.

## 2. Relevant Blueprint Documents
- `backend_blueprint/01_BACKEND_ARCHITECTURE.md` (Section 1.7 Authorization Flow)
- `backend_blueprint/03_API_SPECIFICATION.md` (APIs: API-ACC-001 through API-ACC-007)
- `backend_blueprint/04_SECURITY_ARCHITECTURE.md` (Section 4 BOLA Defenses)

## 3. Exact Implementation Scope
1. Implement `AccountsService` and `AccountsController`:
   - `GET /api/v1/accounts/my-accounts` (Returns all accounts joined/owned by user)
   - `POST /api/v1/accounts` (Creates new account with `verification_status = 'pending'`)
   - `POST /api/v1/accounts/{id}/verification-documents`
   - `GET /api/v1/accounts/{id}/members`
   - `POST /api/v1/accounts/{id}/members` (Invites member with role `manager`, `lister`, or `responder`)
2. Implement `@TenantContext()` decorator extracting `X-Account-ID` header.
3. Implement `TenantGuard` verifying:
   - Authenticated user is an active member of `X-Account-ID`.
   - User's role has sufficient permission for the requested operation.
4. Enforce strict repository-level tenant scoping (`accountId: tenantContext.activeAccountId`).

## 4. Files to Create / Modify
- `backend/src/modules/accounts/accounts.controller.ts`
- `backend/src/modules/accounts/accounts.service.ts`
- `backend/src/modules/accounts/guards/tenant.guard.ts`
- `backend/src/modules/accounts/decorators/tenant-context.decorator.ts`

## 5. Acceptance Criteria
- All tests in `backend_tests/security/test_bola.py` pass.
- Attempting to pass an `X-Account-ID` that does not belong to the user returns 403 Forbidden.
