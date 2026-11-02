import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_refresh_token_rotation_and_theft_revocation():
    """
    OWASP API2 / ASVS: Single-use Refresh Token Rotation with Reuse Breach Detection.
    When a refresh token is used once, a new pair is issued.
    If the OLD refresh token is replayed (e.g. intercepted by attacker),
    the server must immediately revoke all active sessions for that user.
    """
    public_client = ApiClient()

    # 1. Legitimate user rotates their valid refresh token
    rotate_res = await public_client.post(
        "/auth/token/refresh",
        json={"refresh_token": "valid-refresh-token-1"}
    )
    assert rotate_res.status_code == 200
    data = rotate_res.json()["data"]
    assert "access_token" in data
    assert "refresh_token" in data

    # 2. Attacker attempts to replay the already-used refresh token
    replay_res = await public_client.post(
        "/auth/token/refresh",
        json={"refresh_token": "already-used-refresh-token"}
    )
    # Must fail with 401 and trigger breach revocation
    assert replay_res.status_code == 401
    err = replay_res.json()
    assert err["success"] is False
    assert err["error"]["code"] == "TOKEN_COMPROMISED"
