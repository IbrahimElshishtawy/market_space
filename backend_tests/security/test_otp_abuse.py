import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_otp_turnstile_bypass_blocked():
    """Attempting to request an OTP without a valid Turnstile token is blocked with 403."""
    client = ApiClient()
    res = await client.post(
        "/auth/otp/send",
        json={"phone": "+201012732095", "turnstile_token": "invalid-turnstile-token"}
    )
    assert res.status_code == 403
    err = res.json()
    assert err["success"] is False
    assert err["error"]["code"] == "TURNSTILE_FAILED"

@pytest.mark.security
@pytest.mark.asyncio
async def test_otp_rate_limiting_enforced():
    """Flooding OTP requests beyond 3 per 15-minute window returns 429."""
    client = ApiClient()
    phone = "+201012732095"

    # Send up to limit
    for _ in range(2):
        await client.post("/auth/otp/send", json={"phone": phone, "turnstile_token": "valid-turnstile-token"})

    # 4th request must be rate limited
    limit_res = await client.post("/auth/otp/send", json={"phone": phone, "turnstile_token": "valid-turnstile-token"})
    assert limit_res.status_code == 429
    assert "Retry-After" in limit_res.headers
    assert limit_res.json()["error"]["code"] == "RATE_LIMIT_EXCEEDED"

@pytest.mark.security
@pytest.mark.asyncio
async def test_otp_brute_force_max_attempts():
    """Submitting incorrect OTP codes repeatedly locks out after max attempts."""
    client = ApiClient()
    phone = "+201012732095"

    for i in range(5):
        res = await client.post("/auth/otp/verify", json={"phone": phone, "code": "000000"})
        if i < 4:
            assert res.status_code == 400
            assert res.json()["error"]["code"] == "INVALID_OTP"

    # Attempt after limit is reached
    locked_res = await client.post("/auth/otp/verify", json={"phone": phone, "code": "583921"})
    assert locked_res.status_code == 429
    assert locked_res.json()["error"]["code"] == "OTP_ATTEMPTS_EXCEEDED"
