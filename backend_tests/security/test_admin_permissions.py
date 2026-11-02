import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_regular_user_cannot_access_admin_endpoints():
    """Regular authenticated consumer cannot access staff moderation queue."""
    user_client = ApiClient(token="user_a_token")
    res = await user_client.get("/admin/moderation/listings")
    assert res.status_code == 403
    err = res.json()
    assert err["success"] is False
    assert err["error"]["code"] == "STAFF_PERMISSION_REQUIRED"

@pytest.mark.security
@pytest.mark.asyncio
async def test_seller_cannot_modify_platform_settings():
    """Seller cannot modify global platform quotas or settings."""
    seller_client = ApiClient(token="user_b_token", account_id="account-b-uuid")
    res = await seller_client.put(
        "/admin/platform-settings",
        json={"settings": {"daily_quota_individual_listings": 999}}
    )
    assert res.status_code == 403

@pytest.mark.security
@pytest.mark.asyncio
async def test_staff_admin_can_access_admin_panel():
    """Staff user with valid staff token can access admin operations."""
    admin_client = ApiClient(token="staff_admin_token")
    res = await admin_client.get("/admin/moderation/listings")
    assert res.status_code == 200
    assert res.json()["success"] is True
