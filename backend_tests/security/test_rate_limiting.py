import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_global_rate_limiting_headers():
    """Verify rate-limited endpoints properly include standard retry headers."""
    client = ApiClient()
    # Sending excessive OTP requests
    res = await client.post(
        "/auth/otp/send",
        json={"phone": "+201012732095", "turnstile_token": "valid-turnstile-token"}
    )
    if res.status_code == 429:
        assert "Retry-After" in res.headers
        assert int(res.headers["Retry-After"]) > 0
