# Deal One — Authorization, RBAC & IDOR Deep-Dive Audit

**Document Reference:** `docs/security-review/04_AUTHORIZATION_AND_IDOR_AUDIT.md`  
**Auditor:** Deal One Independent Security Reviewer (Agent 2)  
**Date:** 5 November 2026  
**Focus:** Broken Object-Level Authorization (BOLA/IDOR), Privilege Escalation, Tenant Isolation, Listing Ownership, and Role Boundaries  

---

## 1. Executive Summary

This audit evaluates the server-side access control boundaries of the Deal One backend. The architecture incorporates three distinct authorization layers:
1. **User Identity Context:** Authenticated user via JWT (`AuthenticatedUser` extracted by `JwtAuthGuard`).
2. **Tenant/Account Context:** Multi-tenant seller account identity via `AccountMember` and `AccountTenantGuard`.
3. **Staff/Administrative Roles:** Elevated staff operations via `RolesGuard` (`MODERATOR`, `SUPER_ADMIN`).

### Key Audit Findings:
- **Listing Status Modification (IDOR Protection):** Properly enforced. `updateListingStatus` verifies that `listing.account.ownerUserId === userId` before permitting state changes.
- **Listing Creation (Seller Verification Boundary):** Defective. Does not verify whether the account has `verificationStatus === 'approved'`, permitting unverified or rejected accounts to publish listings.
- **Draft & Rejected Listing Leakage (IDOR/Information Disclosure):** Defective. `getListingById` allows unauthenticated callers to inspect draft, pending, and rejected listings.
- **In-App Chat (Team Member Boundary):** Disconnected from Team RBAC. Restricts chat access strictly to `ownerUserId`, locking out legitimate managers and responders from responding to customer inquiries.
- **Phone Reveal Action:** Unauthenticated and unthrottled, bypassing daily quotas.

---

## 2. Comprehensive Endpoint Authorization Matrix

| Endpoint | Method | Required Auth | Intended Role / Ownership | Server-Side Enforcement Status | Vulnerability / Gap |
|---|:---:|:---:|:---:|:---:|---|
| `/auth/otp/send` | `POST` | None | Public | **ENFORCED** | Subject to Redis IP & Phone rate limiting. |
| `/auth/otp/verify` | `POST` | None | Public | **DEFECTIVE** | OTP attempt limit vulnerable to race condition under concurrency (DO-SEC-009). |
| `/auth/sessions/terminate-all` | `POST` | Bearer JWT | Authenticated User | **ENFORCED** | Scoped to `user.id`. |
| `/auth/sessions` | `GET` | Bearer JWT | Authenticated User | **ENFORCED** | Scoped to `user.id`. |
| `/users/me` | `GET` | Bearer JWT | Authenticated User | **ENFORCED** | Scoped to `user.id`. |
| `/users/me` | `PUT` | Bearer JWT | Authenticated User | **ENFORCED** | Modifies only `user.id`. |
| `/users/me` | `DELETE` | Bearer JWT | Authenticated User | **DEFECTIVE** | Soft delete does not invalidate sessions or unpublish listings (DO-SEC-012). |
| `/accounts/my-accounts` | `GET` | Bearer JWT | Authenticated User | **ENFORCED** | Returns only accounts where user has active membership. |
| `/accounts/:id` | `GET` | None | Public | **ENFORCED** | Public seller profile; filters inactive/deleted accounts. |
| `/accounts/:id/branches` | `GET` | None | Public | **ENFORCED** | Returns branches for given account. |
| `/listings` | `GET` | None | Public | **CRITICAL DEFECT** | Leaks private `sellerPhone` on all listings (DO-SEC-001). |
| `/listings/:id` | `GET` | None | Public | **DEFECTIVE** | Returns draft, pending, and rejected listings to unauthenticated callers (DO-SEC-011). |
| `/listings` | `POST` | Bearer JWT | Verified Seller | **HIGH DEFECT** | Auto-approves listings; does not check account verification status (DO-SEC-004). |
| `/listings/:id/status` | `PATCH` | Bearer JWT | Listing Owner / Admin | **ENFORCED** | IDOR check validates `ownerUserId === userId` (Pass). |
| `/listings/:id/contact` | `POST` | None | Authenticated Buyer | **HIGH DEFECT** | Unauthenticated and unthrottled; no daily quota deduction (DO-SEC-008). |
| `/favorites` | `GET` | Bearer JWT | Authenticated User | **ENFORCED** | Scoped to `user.id`. |
| `/favorites/:listingId` | `POST` | Bearer JWT | Authenticated User | **ENFORCED** | Scoped to `user.id`. |
| `/favorites/:listingId` | `DELETE` | Bearer JWT | Authenticated User | **ENFORCED** | Scoped to `user.id`. |
| `/conversations` | `GET` | Bearer JWT | Participant | **PARTIAL** | Only checks `ownerUserId`; team members locked out. |
| `/conversations` | `POST` | Bearer JWT | Buyer (not owner) | **ENFORCED** | Rejects seller starting conversation on own listing. |
| `/conversations/:id/messages` | `GET` | Bearer JWT | Participant | **PARTIAL** | IDOR check present, but blocks team managers/responders. |
| `/conversations/:id/messages` | `POST` | Bearer JWT | Participant | **PARTIAL** | IDOR check present, but blocks team managers/responders. |
| `/media/images/upload-url` | `POST` | Bearer JWT | Authenticated User | **ENFORCED** | Storage keys restricted to `uploads/images/.../${userId}/...`. |
| `/media/video/upload-token` | `POST` | Bearer JWT | Authenticated User | **ENFORCED** | Requires valid JWT. |
| `/media/video/webhook` | `POST` | None | Cloudflare Webhook | **CRITICAL DEFECT** | Zero authentication or signature check; bulk tampering risk (DO-SEC-002). |
| `/payments/checkout` | `POST` | Bearer JWT | Listing Owner | **ENFORCED** | Checks `listing.account.ownerUserId === userId`. |
| `/payments/webhook` | `POST` | None | Paymob Webhook | **CRITICAL DEFECT** | Bypasses HMAC signature when query param omitted (DO-SEC-003). |
| `/admin/moderation/queue` | `GET` | Bearer JWT | Staff (Moderator/Admin) | **ARCHITECTURAL GAP**| Relies on unvalidated JWT claim; staff cannot log in (DO-SEC-006). |
| `/admin/moderation/reports/:id`| `PATCH` | Bearer JWT | Staff (Moderator/Admin) | **ARCHITECTURAL GAP**| Relies on unvalidated JWT claim (DO-SEC-006). |
| `/admin/categories` | `POST` | Bearer JWT | Staff (Super Admin) | **ARCHITECTURAL GAP**| Relies on unvalidated JWT claim (DO-SEC-006). |
| `/admin/audit-logs` | `GET` | Bearer JWT | Staff (Super Admin) | **ARCHITECTURAL GAP**| Relies on unvalidated JWT claim (DO-SEC-006). |

---

## 3. Horizontal Privilege Escalation & IDOR Analysis

### 3.1 Listing Management IDOR Testing
- **Target:** `PATCH /api/v1/listings/:id/status`
- **Mechanism:**
  ```typescript
  if (listing.account.ownerUserId !== userId && userRole !== 'SUPER_ADMIN') {
    throw new ForbiddenException('You do not have permission to modify this listing');
  }
  ```
- **Evaluation:** **SECURE.** A malicious seller cannot alter the status, archive, or unhide a listing belonging to another seller account.

### 3.2 Chat & Messaging IDOR Testing
- **Target:** `GET /api/v1/conversations/:id/messages` & `POST /api/v1/conversations/:id/messages`
- **Mechanism:**
  ```typescript
  if (
    conversation.buyerUserId !== userId &&
    conversation.sellerAccount.ownerUserId !== userId
  ) {
    throw new ForbiddenException('You are not a participant in this conversation');
  }
  ```
- **Evaluation:**
  - **Horizontal IDOR Protection:** **PASS.** Unauthorized third parties cannot read or inject messages into other users' private conversations.
  - **Multi-Tenant Team Member Isolation:** **FAIL.** If a company account adds a team member (`AccountMember` with role `manager` or `responder`), that member is erroneously treated as an unauthorized third party and blocked with `403 Forbidden`.

### 3.3 Favorites & Saved Listings IDOR Testing
- **Target:** `GET /api/v1/favorites`, `POST /api/v1/favorites/:listingId`, `DELETE /api/v1/favorites/:listingId`
- **Evaluation:** **SECURE.** All database queries are filtered by `where: { userId: user.id }`. No user can inspect or delete another user's saved items.

---

## 4. Vertical Privilege Escalation & Role Boundaries

### 4.1 Regular User to Administrator Escalation
- **Target:** Admin routes (`/admin/moderation/*`, `/admin/categories/*`, `/admin/audit-logs`)
- **Vulnerability Analysis:**
  - In `jwt.strategy.ts`:
    ```typescript
    role: payload.role || 'USER',
    ```
  - Because `RolesGuard` compares `user.role` directly against `requiredRoles`, if an attacker is able to sign or modify a token (e.g., using the committed development secret), they can inject `role: "SUPER_ADMIN"`.
  - `JwtStrategy` performs no lookup against the `StaffUser` table to determine whether `user.id` actually corresponds to an authorized staff member.
  - **Verdict:** **HIGH RISK (VULNERABLE VIA TOKEN FORGERY).**

### 4.2 Unverified Seller Publishing Escalation
- **Target:** `POST /api/v1/listings`
- **Business Rule:** Unapproved sellers cannot publish listings (ADR-004, ADR-007).
- **Vulnerability Analysis:**
  - In `listings.service.ts`, `createListing` retrieves the user's account:
    ```typescript
    let account = await tx.account.findFirst({
      where: { ownerUserId: userId },
    });
    ```
  - It does NOT check `account.verificationStatus === 'approved'`.
  - If the account has `verificationStatus: 'pending'` or `'rejected'`, the user can still create and publish listings without hindrance.
  - **Verdict:** **FAIL — BUSINESS LOGIC ESCALATION.**

---

## 5. Required Authorization Remediations

1. **Enforce Seller Approval Check in `createListing`:**
   ```typescript
   if (account.verificationStatus !== 'approved') {
     throw new ForbiddenException('Your seller account must be approved before publishing listings.');
   }
   ```
2. **Restrict Public Listing Details to Published Only:**
   ```typescript
   if (
     listing.publicationStatus !== 'published' ||
     listing.moderationStatus !== 'approved'
   ) {
     if (!callerUserId || (listing.account.ownerUserId !== callerUserId && callerRole !== 'SUPER_ADMIN')) {
       throw new NotFoundException('Listing not found');
     }
   }
   ```
3. **Upgrade Chat Participant Verification to Support Team RBAC:**
   Check both `ownerUserId` and `AccountMember`:
   ```typescript
   const isSellerMember = await this.prisma.accountMember.findFirst({
     where: { accountId: conversation.sellerAccountId, userId },
   });
   if (conversation.buyerUserId !== userId && !isSellerMember) {
     throw new ForbiddenException('You are not an authorized participant in this conversation.');
   }
   ```
4. **Require Authentication and Quota Deduction on Contact Action:**
   Protect `POST /listings/:id/contact` with `JwtAuthGuard` and enforce daily quota deductions.
