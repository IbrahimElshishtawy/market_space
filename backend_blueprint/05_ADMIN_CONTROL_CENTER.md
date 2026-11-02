# Deal One — Admin Control Center & Platform Governance

## 1. Overview & Architectural Principles

The **Admin Control Center** provides a hardened, centralized web portal for Deal One operations, support staff, content moderators, and executive leadership.

### Mandatory Operational Rules:
1. **Zero Direct Database Edits:** No operator or support engineer is permitted to execute manual `UPDATE` or `DELETE` SQL queries against production database tables. All administrative interventions must execute via audited internal APIs.
2. **Principle of Least Privilege (PoLP):** Administrative accounts belong to the dedicated `staff_users` table with strict RBAC permissions. Support personnel cannot approve listings; moderators cannot modify system billing or global quota settings.
3. **Mandatory Append-Only Audit Logging:** Every administrative action generates an immutable record in `moderation_log` (for content and seller decisions) or `audit_log` (for platform settings and account suspensions).
4. **No Security Bypasses:** Critical security protections (e.g., Turnstile verification, password hashing, encryption) cannot be disabled via administrative toggles.

---

## 2. Administrative Role Hierarchy & Permissions Matrix

```
┌────────────────────────────────────────────────────────┐
│                      SUPER ADMIN                       │
│  (System Config, Quotas, Admin Staff Management, DB)   │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                         ADMIN                          │
│     (Account Bans, Category Tree, Global Analytics)    │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                       MODERATOR                        │
│   (Listing Approvals/Rejections, Seller Verifications) │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                        SUPPORT                         │
│     (Abuse Reports, User Inquiries, View Audit Logs)   │
└────────────────────────────────────────────────────────┘
```

### Detailed Permissions Matrix

| Permission Key | Description | Super Admin | Admin | Moderator | Support |
|---|---|:---:|:---:|:---:|:---:|
| `listings:moderate` | Approve, reject, or request revisions on pending listings | Yes | Yes | Yes | No |
| `accounts:verify` | Review official documents and approve/reject seller accounts | Yes | Yes | Yes | No |
| `reports:resolve` | Investigate and dismiss or act upon user abuse reports | Yes | Yes | Yes | Yes |
| `accounts:suspend` | Temporarily or permanently ban a merchant account | Yes | Yes | No | No |
| `categories:manage` | Add/edit category tree nodes and dynamic field schemas | Yes | Yes | No | No |
| `quotas:override` | Increase daily quota limits for specific strategic accounts | Yes | Yes | No | No |
| `settings:manage` | Modify global platform settings, default quotas, TTLs | Yes | No | No | No |
| `staff:manage` | Create, invite, or deactivate administrative staff users | Yes | No | No | No |
| `audit:view` | Query and inspect complete system and security audit logs | Yes | Yes | No | View Only |

---

## 3. Administrative Workflows & Operations Catalog

### 3.1 Listing Moderation Queue (`listings:moderate`)
- **Queue Logic:** FIFO queue displaying listings where `moderation_status = 'pending'`, sorted by `created_at ASC` (oldest first).
- **Endpoint:** `POST /api/v1/admin/moderation/listings/{id}/decision`
- **Actions:**
  - **Approve:** Sets `moderation_status = 'approved'` and `publication_status = 'published'`. Automatically dispatches FCM push notification: *"تهانينا! تم اعتماد إعلانك وهو معروض الآن للجمهور"*.
  - **Reject:** Requires a mandatory standard `reason_code` and explanation notes:
    - `PROHIBITED_OR_ILLEGAL_ITEM`
    - `MISLEADING_PRICE_OR_TITLE`
    - `POOR_QUALITY_OR_WATERMARKED_IMAGES`
    - `WRONG_CATEGORY_CLASSIFICATION`
    - `CONTACT_INFO_IN_DESCRIPTION`
  - Sets `moderation_status = 'rejected'`. Inserts full record into `moderation_log`. Dispatches push notification detailing the rejection reason and providing a deep-link to edit the draft.
- **Reversibility:** A rejected listing can be re-submitted by the seller; an approved listing can be rejected or suspended later if reported.

### 3.2 Seller Verification Review (`accounts:verify`)
- **Queue Logic:** Displays submitted commercial registrations, tax cards, and national IDs for accounts with `verification_status = 'pending'`.
- **Endpoint:** `POST /api/v1/admin/verifications/{accountId}/decision`
- **Validation Checklist for Moderator:**
  1. Commercial Register number matches official registry records.
  2. Document expiry date is in the future.
  3. Authorized signatory name matches account owner's legal name.
- **Decision:**
  - **Approve:** Updates `accounts.verification_status = 'approved'`. Releases all pre-approved listings of this account to public search feeds.
  - **Reject:** Requires reason code (`EXPIRED_DOCUMENT`, `ILLEGIBLE_SCAN`, `NAME_MISMATCH`) and explanatory note for the seller to re-upload.

### 3.3 User Abuse & Fraud Investigation (`reports:resolve`)
- **Queue Logic:** Aggregates user reports from table `reports` grouped by listing or account.
- **Endpoint:** `POST /api/v1/admin/reports/{reportId}/action`
- **Resolution Options:**
  1. `dismiss`: Report deemed malicious, duplicate, or unfounded.
  2. `hide_listing`: Flips `listings.publication_status = 'hidden'` pending seller clarification.
  3. `ban_account`: Triggers immediate account suspension (`accounts.is_active = false`), terminates all active user sessions, and sends fraud alert to platform administrators.

### 3.4 Dynamic Platform Settings Management (`settings:manage`)
- **Endpoint:** `PUT /api/v1/admin/settings/{key}`
- **Controlled Configurations:**
  - `quotas.daily_listings_individual` (default: 3)
  - `quotas.daily_listings_company` (default: 30)
  - `quotas.daily_contact_reveals` (default: 15)
  - `quotas.daily_chat_initiations` (default: 20)
  - `listings.default_expiry_days` (default: 30 days)
  - `cache.search_feed_ttl_seconds` (default: 60)
- **Security Safeguards:**
  - Changes require Super Admin credentials.
  - Generates before/after JSON diff in `audit_log`.
  - Automatically invalidates corresponding cache keys in Redis across all API instances.

---

## 4. Admin Security & Hardening Protocols

1. **Dedicated Domain & Network Isolation:**
   - The Admin Web Dashboard is hosted on an isolated subdomain (`https://ops.deal-one.eg`) restricted via Cloudflare Access and IP allowlisting (corporate VPN required).
2. **Mandatory Two-Factor Authentication (2FA / TOTP):**
   - All `staff_users` are required to enroll in Time-based One-Time Password (TOTP) authenticator apps (Google Authenticator, Microsoft Authenticator) before accessing moderation queues.
3. **Short Session Expiration:**
   - Staff sessions expire after **2 hours** of inactivity. Refresh tokens for staff accounts are capped at a maximum lifetime of **8 hours**.
