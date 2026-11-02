import pytest
from backend_tests.clients.auth_client import AuthClient

@pytest.mark.functional
@pytest.mark.asyncio
async def test_otp_flow_and_session_generation():
    auth = AuthClient()
    phone = "+201011112222"

    # 1. Send OTP
    send_res = await auth.send_otp(phone)
    assert send_res.status_code in [200, 429]

    if send_res.status_code == 200:
        # 2. Verify OTP
        token, refresh, data = await auth.verify_otp(phone, "123456")
        assert token != ""
        assert refresh != ""
        assert "user" in data

        # 3. Silent Refresh Token Rotation
        ref_res = await auth.refresh_token(refresh)
        assert ref_res.status_code == 200
        ref_data = ref_res.json()["data"]
        assert "access_token" in ref_data
        assert "refresh_token" in ref_data

        # 4. Theft Detection: Reusing old refresh token must fail with 401
        reuse_res = await auth.refresh_token(refresh)
        assert reuse_res.status_code == 401
