"""
Security contract simulator for Deal One.
Simulates backend RBAC, BOLA, Token Rotation, Quota and OTP protection
to enable deterministic security testing both pre-implementation and in CI.
"""
import json
import httpx
from typing import Dict, Any, Tuple

# Mock DB State for Security Testing
USERS = {
    "user_a_token": {"id": "usr-uuid-a", "phone": "+201011111111", "is_staff": False},
    "user_b_token": {"id": "usr-uuid-b", "phone": "+201022222222", "is_staff": False},
    "staff_admin_token": {"id": "staff-admin-uuid", "phone": "+201099999999", "is_staff": True, "role": "super_admin"},
}

ACCOUNTS = {
    "account-a-uuid": {"owner_id": "usr-uuid-a", "members": {"usr-uuid-a": "owner", "usr-uuid-b": "responder"}},
    "account-b-uuid": {"owner_id": "usr-uuid-b", "members": {"usr-uuid-b": "owner"}},
}

LISTINGS = {
    "listing-owned-by-account-a-uuid": {"account_id": "account-a-uuid", "title": "Listing A", "price": 100},
    "listing-owned-by-account-b-uuid": {"account_id": "account-b-uuid", "title": "Listing B", "price": 200},
}

CONVERSATIONS = {
    "conv-between-a-and-b": {"buyer_account_id": "account-a-uuid", "seller_account_id": "account-b-uuid"},
}

REFRESH_TOKENS = {
    "valid-refresh-token-1": {"user_id": "usr-uuid-a", "is_revoked": False, "is_used": False},
    "already-used-refresh-token": {"user_id": "usr-uuid-a", "is_revoked": False, "is_used": True},
}

OTP_STORE = {
    "+201012732095": {"code": "583921", "attempts": 0, "max_attempts": 5, "requests_in_window": 1},
}

def simulate_deal_one_security(request: httpx.Request) -> httpx.Response:
    url_path = request.url.path
    method = request.method.upper()
    headers = request.headers

    auth_header = headers.get("Authorization", "")
    token = auth_header.replace("Bearer ", "") if auth_header.startswith("Bearer ") else None
    account_id = headers.get("X-Account-ID")

    user = USERS.get(token) if token else None

    # 1. Admin endpoints
    if "/api/v1/admin" in url_path:
        if not user or not user.get("is_staff"):
            return httpx.Response(403, json={"success": False, "error": {"code": "STAFF_PERMISSION_REQUIRED", "message": "Access denied"}})
        return httpx.Response(200, json={"success": True, "data": []})

    # 2. Token Refresh & Rotation
    if url_path.endswith("/auth/token/refresh") and method == "POST":
        body = json.loads(request.content.decode() or "{}")
        rf_token = body.get("refresh_token")
        record = REFRESH_TOKENS.get(rf_token)
        if not record:
            return httpx.Response(401, json={"success": False, "error": {"code": "INVALID_TOKEN", "message": "Token not found"}})
        if record.get("is_used"):
            # Breach detected: Token reuse! Revoke all tokens for this user
            for k, v in REFRESH_TOKENS.items():
                if v.get("user_id") == record.get("user_id"):
                    v["is_revoked"] = True
            return httpx.Response(401, json={"success": False, "error": {"code": "TOKEN_COMPROMISED", "message": "Refresh token reuse detected. All sessions revoked."}})
        record["is_used"] = True
        return httpx.Response(200, json={"success": True, "data": {"access_token": "new-access-token", "refresh_token": "new-refresh-token"}})

    # 3. OTP Send & Verify
    if url_path.endswith("/auth/otp/send") and method == "POST":
        body = json.loads(request.content.decode() or "{}")
        phone = body.get("phone", "")
        turnstile = body.get("turnstile_token", "")
        if not turnstile or turnstile == "invalid-turnstile-token":
            return httpx.Response(403, json={"success": False, "error": {"code": "TURNSTILE_FAILED", "message": "Bot verification failed"}})
        otp_info = OTP_STORE.get(phone, {"requests_in_window": 0})
        if otp_info.get("requests_in_window", 0) >= 3:
            return httpx.Response(429, headers={"Retry-After": "900"}, json={"success": False, "error": {"code": "RATE_LIMIT_EXCEEDED", "message": "Max 3 OTP requests per 15 min"}})
        otp_info["requests_in_window"] = otp_info.get("requests_in_window", 0) + 1
        OTP_STORE[phone] = otp_info
        return httpx.Response(200, json={"success": True, "data": {"message": "OTP dispatched", "expires_in": 300}})

    if url_path.endswith("/auth/otp/verify") and method == "POST":
        body = json.loads(request.content.decode() or "{}")
        phone = body.get("phone", "")
        code = body.get("code", "")
        record = OTP_STORE.get(phone)
        if not record:
            return httpx.Response(400, json={"success": False, "error": {"code": "OTP_EXPIRED_OR_NOT_FOUND", "message": "No active OTP"}})
        if record["attempts"] >= record["max_attempts"]:
            return httpx.Response(429, json={"success": False, "error": {"code": "OTP_ATTEMPTS_EXCEEDED", "message": "Maximum OTP verification attempts exceeded"}})
        if record["code"] != code:
            record["attempts"] += 1
            return httpx.Response(400, json={"success": False, "error": {"code": "INVALID_OTP", "message": f"Incorrect code. {record['max_attempts'] - record['attempts']} attempts left."}})
        return httpx.Response(200, json={"success": True, "data": {"access_token": "valid-jwt", "refresh_token": "valid-refresh"}})

    # 4. Media Presigned URL Upload Authorization
    if url_path.endswith("/media/presigned-url") and method == "POST":
        if not user:
            return httpx.Response(401, json={"success": False, "error": {"code": "UNAUTHORIZED", "message": "Auth required"}})
        body = json.loads(request.content.decode() or "{}")
        mime = body.get("mime_type", "")
        size = body.get("size_bytes", 0)
        allowed_mimes = ["image/jpeg", "image/png", "image/webp", "video/mp4"]
        if mime not in allowed_mimes:
            return httpx.Response(400, json={"success": False, "error": {"code": "UNSUPPORTED_MEDIA_TYPE", "message": "Disallowed file type"}})
        if size > 10 * 1024 * 1024:  # 10MB limit
            return httpx.Response(400, json={"success": False, "error": {"code": "FILE_TOO_LARGE", "message": "Max size is 10MB"}})
        return httpx.Response(200, json={"success": True, "data": {"upload_url": "https://r2.deal-one.eg/upload?sig=xyz", "key": "uploads/uuid.jpg"}})

    # 5. Listings BOLA / IDOR Protection
    if "/listings/" in url_path:
        parts = url_path.split("/")
        listing_id = parts[parts.index("listings") + 1] if "listings" in parts else None
        if listing_id and listing_id in LISTINGS:
            item = LISTINGS[listing_id]
            # Mutating operations (PUT, DELETE, PATCH)
            if method in ["PUT", "DELETE", "PATCH"]:
                if not user:
                    return httpx.Response(401, json={"success": False, "error": {"code": "UNAUTHORIZED"}})
                # BOLA check: Must match active account_id
                if item["account_id"] != account_id:
                    # Enforce strict 404 to avoid object enumeration
                    return httpx.Response(404, json={"success": False, "error": {"code": "NOT_FOUND", "message": "Listing not found"}})
                return httpx.Response(200, json={"success": True, "data": {"id": listing_id, "deleted": method == "DELETE"}})

    # 6. Account Isolation & Role Escalation
    if "/accounts/" in url_path:
        parts = url_path.split("/")
        acc_idx = parts.index("accounts")
        target_acc_id = parts[acc_idx + 1] if len(parts) > acc_idx + 1 else None
        if target_acc_id and target_acc_id in ACCOUNTS:
            acc = ACCOUNTS[target_acc_id]
            if not user:
                return httpx.Response(401, json={"success": False, "error": {"code": "UNAUTHORIZED"}})
            user_id = user["id"]
            if user_id not in acc["members"]:
                return httpx.Response(404, json={"success": False, "error": {"code": "NOT_FOUND", "message": "Account not found"}})
            role = acc["members"][user_id]
            # Role Escalation check: Inviting members requires owner or manager
            if "members/invite" in url_path and method == "POST":
                if role not in ["owner", "manager"]:
                    return httpx.Response(403, json={"success": False, "error": {"code": "FORBIDDEN_INSUFFICIENT_ROLE", "message": "Role escalation prohibited"}})
                return httpx.Response(200, json={"success": True, "data": {"invited": True}})

    # 7. Chat Authorization (Eavesdropping Protection)
    if "/chat/conversations/" in url_path:
        parts = url_path.split("/")
        conv_idx = parts.index("conversations")
        conv_id = parts[conv_idx + 1] if len(parts) > conv_idx + 1 else None
        if conv_id and conv_id in CONVERSATIONS:
            conv = CONVERSATIONS[conv_id]
            if not user:
                return httpx.Response(401, json={"success": False, "error": {"code": "UNAUTHORIZED"}})
            # Caller's account_id must be buyer or seller
            if account_id not in [conv["buyer_account_id"], conv["seller_account_id"]]:
                return httpx.Response(404, json={"success": False, "error": {"code": "NOT_FOUND", "message": "Conversation not found"}})
            return httpx.Response(200, json={"success": True, "data": []})

    # Default fallback response
    return httpx.Response(200, json={"success": True, "data": {}})
