import pytest
from backend_tests.clients.api_client import ApiClient
from backend_tests.fixtures.test_data import sample_listing_payload

@pytest.mark.functional
@pytest.mark.asyncio
async def test_listing_crud_and_status_transitions():
    client = ApiClient(token="mock_valid_merchant_token", account_id="acc-uuid-1")

    # 1. Create Listing Draft
    payload = sample_listing_payload()
    create_res = await client.post("/listings", json=payload)
    assert create_res.status_code in [201, 200]
    listing_id = create_res.json()["data"]["id"]
    assert create_res.json()["data"]["moderation_status"] == "draft"

    # 2. Public lookup must not show draft
    public_client = ApiClient()
    pub_res = await public_client.get(f"/listings/{listing_id}")
    assert pub_res.status_code in [404, 403]

    # 3. Toggle Visibility
    vis_res = await client.patch(f"/listings/{listing_id}/visibility", json={"publication_status": "hidden"})
    assert vis_res.status_code == 200
