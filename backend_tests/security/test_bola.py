import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_cross_tenant_bola_protection():
    # User A from Account A attempts to mutate an item in Account B
    attacker_client = ApiClient(token="user_a_token", account_id="account-a-uuid")
    victim_listing_id = "listing-owned-by-account-b-uuid"

    # Attacker attempts to update price of victim's listing
    update_res = await attacker_client.put(
        f"/listings/{victim_listing_id}",
        json={"price": 10.0}
    )
    # Must fail with 404 Not Found (Never reveal entity existence across tenants) or 403 Forbidden
    assert update_res.status_code in [404, 403]

    # Attacker attempts to delete victim's listing
    delete_res = await attacker_client.delete(f"/listings/{victim_listing_id}")
    assert delete_res.status_code in [404, 403]
