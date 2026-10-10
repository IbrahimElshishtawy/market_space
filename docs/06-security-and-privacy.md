# Security Architecture and Privacy Plan — Market Space

---

## 1. Threat Model & Trust Boundaries

```
[ Untrusted Public Internet ]
           │
  (TLS 1.3 Termination, Cloudflare DDoS / WAF, IP Rate Limiting)
           │
┌──────────▼─────────────────────────────────────────────────┐
│ Trust Boundary: Edge Reverse Proxy (Nginx)                 │
└──────────┬─────────────────────────────────────────────────┘
           │ (Internal Docker Bridge Network)
┌──────────▼─────────────────────────────────────────────────┐
│ Trust Boundary: Application Layer (NestJS API & BullMQ)    │
│  - Input Validation (Class-Validator)                      │
│  - JWT & RBAC Authorization Guards                          │
│  - Object-Level Ownership Checks (IDOR Prevention)         │
│  - HMAC Webhook Cryptographic Verification                 │
└──────────┬─────────────────────────────────────────────────┘
           │ (Encrypted / Localhost Only)
┌──────────▼─────────────────────────────────────────────────┐
│ Trust Boundary: Storage Layer (PostgreSQL 16 & Redis 7)    │
│  - Parameterized Queries (No SQL Injection)                │
│  - Row-Level Principle of Least Privilege                  │
└─────────────────────────────────────────────────────────────┘
```

### 1.1 Identified Threats & Mitigations (STRIDE Matrix)
| STRIDE Category | Threat Scenario | Architectural Mitigation |
| :--- | :--- | :--- |
| **Spoofing** | Attacker impersonates seller to alter or delete listings. | Cryptographically signed JWT access tokens with strict user ownership validation. |
| **Tampering** | Buyer alters promotion package price during checkout. | Authoritative server-side pricing; client payload price is ignored completely. |
| **Repudiation** | Moderator bans user without record, causing support dispute. | Append-only `audit_logs` table tracking admin ID, target ID, diff, IP, and timestamp. |
| **Information Disclosure** | Seller's exact home address or private phone number leaked publicly. | Geolocation fuzzing (Gov/City only); phone number hidden behind explicit contact action. |
| **Denial of Service** | Bot script exhausts SMS gateway credit via OTP flooding. | Redis-backed sliding-window rate limit (max 3 OTP requests / 15 min per phone and IP). |
| **Elevation of Privilege** | Normal user accesses `/admin/moderation` endpoints. | NestJS RBAC Guard verifying `role == 'MODERATOR' \|\| 'SUPER_ADMIN'` on all admin routes. |

---

## 2. Authentication, Session & Access Control

### 2.1 Password Hashing & Key Derivation
- Passwords (when set) are hashed using **Argon2id** (memory: 64MB, iterations: 3, parallelism: 4) or **bcrypt** with a minimum work factor of 12.
- Plaintext passwords or OTP codes are never logged, cached, or reflected in API responses.

### 2.2 Token Lifecycle & Rotation
- **Access Token:** Short-lived (15 minutes), signed with `RS256` or `HS512`, containing `{ sub: user_id, role, jti }`.
- **Refresh Token:** Cryptographically random 64-byte string, stored as a SHA-256 hash in `user_sessions`.
- **Rotation:** Upon refresh, the old refresh token is marked revoked, and a newly generated pair is returned.
- **Revocation:** Password change, logout, or account suspension immediately invalidates all active sessions.

### 2.3 Object-Level Access Control (IDOR Prevention)
- For every state-changing endpoint (e.g., `PUT /listings/{id}`, `DELETE /listings/{id}`, `GET /conversations/{id}`), the service layer validates:
  ```typescript
  if (listing.userId !== currentUser.id && currentUser.role !== 'SUPER_ADMIN') {
    throw new ForbiddenException('You do not own this listing');
  }
  ```

---

## 3. Upload & Media Ingestion Security

### 3.1 Direct-to-Storage Isolation
1. **No Multipart Processing on API Server:** The VPS never handles multi-megabyte image binaries directly, preventing memory exhaustion and ReDoS vulnerabilities.
2. **Presigned Upload URLs:** Upload URLs generated for Cloudflare R2 / S3 have an expiration of exactly 15 minutes, restricted to expected MIME types (`image/jpeg`, `image/png`, `image/webp`).
3. **HeadObject Metadata Verification:** When a listing is submitted with media keys, the backend issues an asynchronous `HeadObject` call to R2 to verify:
   - File exists in the user's isolated upload path (`uploads/images/{userId}/...`).
   - Content length does not exceed 8 MB.
   - Declared Content-Type matches image formats.
4. **Cloudflare Stream Video Security:** Video uploads use single-use direct upload URLs with automated 30-second duration clipping enforced at the provider level.

---

## 4. Webhook Security & Idempotency

### 4.1 Paymob HMAC Verification
Paymob transaction webhooks deliver raw JSON payloads accompanied by an `hmac` query parameter.
```typescript
const calculatedHmac = crypto
  .createHmac('sha512', process.env.PAYMOB_HMAC_SECRET)
  .update(concatenatedPaymobFields)
  .digest('hex');

if (calculatedHmac !== incomingHmac) {
  throw new UnauthorizedException('Invalid Paymob signature');
}
```

### 4.2 Webhook Idempotency & Replay Protection
- Every transaction webhook payload contains a `gateway_transaction_id`.
- The database lookup executes within a serializable transaction:
  ```sql
  SELECT id FROM payments WHERE gateway_transaction_id = $1 FOR UPDATE;
  ```
  If a record already exists with status `SUCCESS`, the endpoint immediately returns HTTP 200 without re-applying promotional entitlements.

---

## 5. Privacy, Data Retention & Egyptian Law Considerations

> **Legal Disclaimer:** The following notes outline technical compliance architecture for review by qualified legal counsel in Egypt. They do not constitute formal legal advice.

### 5.1 Alignment with Egypt Personal Data Protection Law (Law No. 151 of 2020)
- **User Consent:** Explicit opt-in checkbox during registration for Terms of Service and Privacy Policy.
- **Right to Erasure (Account Deletion):**
  - Users can trigger account deletion in profile settings.
  - Active listings are permanently unindexed (`ARCHIVED`).
  - Personal identifiable fields (`full_name`, `avatar_url`, `phone`) are anonymized or purged.
  - **Exception:** Financial payment transactions are retained in compliance with Egyptian Tax and Anti-Money Laundering regulations for the mandatory statutory retention period.
- **Data Minimization:** No unnecessary PII (such as national ID numbers, exact GPS addresses, or contact lists) is collected during standard marketplace usage.

---

## 6. Security Testing & Verification Checklist

- [ ] **SQL Injection:** Automated Static Application Security Testing (SAST) and ORM parameterized query validation.
- [ ] **Cross-Site Scripting (XSS):** Strict sanitization of listing descriptions using DOMPurify before HTML rendering in web admin; Flutter native widgets mitigate web DOM XSS by default.
- [ ] **IDOR Check:** Test cases verifying User A cannot view, update, or delete User B's drafts, conversations, or listings.
- [ ] **Rate Limiting:** Penetration script testing brute-force OTP attempts to confirm HTTP 429 lockout.
- [ ] **Secret Scanning:** Pre-commit hooks (`gitleaks`) scanning for committed private keys, JWT secrets, and AWS tokens.
- [ ] **Dependency Audits:** Automated `npm audit` / `snyk` scanning in CI pipeline failing on critical vulnerabilities.
