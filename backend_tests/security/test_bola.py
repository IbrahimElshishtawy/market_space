import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_cross_tenant_bola_protection():
    """
    OWASP API1: Broken Object Level Authorization (BOLA).
    User A (Account A) attempts to mutate an item owned by Account B.
    Backend must enforce `WHERE id = :id AND account_id = :active_account_id`.
    Must return 404 Not Found to prevent entity existence enumeration.
    """
    attacker_client = ApiClient(token="user_a_token", account_id="account-a-uuid")
    victim_listing_id = "listing-owned-by-account-b-uuid"

    # Attacker attempts to update price of victim's listing
    update_res = await attacker_client.put(
        f"/listings/{victim_listing_id}",
        json={"price": 10.0}
    )
    assert update_res.status_code == 404, f"Expected 404 Not Found to prevent enumeration, got {update_res.status_code}"
    err_body = update_res.json()
    assert err_body["success"] is False
    assert err_body["error"]["code"] == "NOT_FOUND"

    # Attacker attempts to delete victim's listing
    delete_res = await attacker_client.delete(f"/listings/{victim_listing_id}")
    assert delete_res.status_code == 404, f"Expected 404 Not Found to prevent enumeration, got {delete_res.status_code}"

@pytest.mark.security
@pytest.mark.asyncio
async def test_authorized_owner_mutation_succeeds():
    """Legitimate owner mutates their own listing successfully."""
    legitimate_client = ApiClient(token="user_b_token", account_id="account-b-uuid")
    victim_listing_id = "listing-owned-by-account-b-uuid"

    res = await legitimate_client.put(f"/listings/{victim_listing_id}", json={"price": 250.0})
    assert res.status_code == 200
    assert res.json()["success"] is True
