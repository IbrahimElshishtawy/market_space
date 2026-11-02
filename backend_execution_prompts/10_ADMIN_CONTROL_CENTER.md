# Phase 10: Admin Control Center, Moderation Queues & Audit Trail

## 1. Role & Objective
You are the Lead Backend & Security Architect. Your objective is to build the internal operations portal APIs: listing moderation queue, seller verification workflow, user abuse investigations, dynamic platform settings, and immutable audit logs.

## 2. Relevant Blueprint Documents
- `backend_blueprint/05_ADMIN_CONTROL_CENTER.md` (Full Admin Specification & Permissions Matrix)
- `backend_blueprint/03_API_SPECIFICATION.md` (APIs: API-ADM-001 through API-ADM-007)

## 3. Exact Implementation Scope
1. Implement `AdminModerationService` and `AdminController`:
   - `GET /api/v1/admin/moderation/pending-listings` (FIFO moderation queue)
   - `POST /api/v1/admin/moderation/listings/{id}/decision` (Approve/Reject with reason codes)
   - `GET /api/v1/admin/verifications/pending`
   - `POST /api/v1/admin/verifications/{id}/decision`
   - `PATCH /api/v1/admin/accounts/{id}/status` (Suspend account, auto-hides listings)
   - `PUT /api/v1/admin/settings/{key}` (Updates platform settings)
   - `GET /api/v1/admin/audit-logs`
2. Enforce Staff JWT Authentication & RBAC permissions guard (`staff_roles`).
3. Write immutable records to `moderation_log` and `audit_log` with actor IP and before/after diffs.
4. Prevent any user or non-staff token from accessing `/admin/*` routes.

## 4. Files to Create / Modify
- `backend/src/modules/admin/admin.controller.ts`
- `backend/src/modules/admin/admin.service.ts`
- `backend/src/modules/admin/guards/staff-role.guard.ts`
- `backend/src/modules/admin/services/audit-logger.service.ts`

## 5. Acceptance Criteria
- All tests in `backend_tests/functional/test_admin.py` pass.
- Public user tokens calling admin endpoints receive 403 Forbidden.
- Rejecting a listing records reason code in `moderation_log` and dispatches notification.
