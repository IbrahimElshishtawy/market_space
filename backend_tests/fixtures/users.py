import pytest
from backend_tests.clients.auth_client import AuthClient

@pytest.fixture
async def regular_user():
    phone = "+201099990001"
    auth = AuthClient()
    await auth.send_otp(phone)
    token, refresh, data = await auth.verify_otp(phone, "123456")
    return {"phone": phone, "token": token, "refresh_token": refresh, "user": data.get("user")}

@pytest.fixture
async def merchant_user():
    phone = "+201099990002"
    auth = AuthClient()
    await auth.send_otp(phone)
    token, refresh, data = await auth.verify_otp(phone, "123456")
    return {
        "phone": phone,
        "token": token,
        "refresh_token": refresh,
        "account_id": "acc-merchant-fixture-uuid",
    }
