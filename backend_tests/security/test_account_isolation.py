import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_unauthorized_account_access_prohibited():
    """
    Tenant Isolation: User A cannot manage or list details of Account B
    if they are not a member of Account B.
    """
    client = ApiClient(token="user_a_token", account_id="account-a-uuid")
    
    # Attempt to invite a member into Account B
    res = await client.post(
        "/accounts/account-b-uuid/members/invite",
        json={"phone": "+201011112222", "role": "manager"}
    )
    # Must fail with 404 or 403
    assert res.status_code in [404, 403]
    assert res.json()["success"] is False

@pytest.mark.security
@pytest.mark.asyncio
async def test_header_spoofing_without_membership_blocked():
    """
    Spoofing X-Account-ID header with an account where user is NOT a member
    must be immediately rejected.
    """
    # User A tries to pass X-Account-ID = account-b-uuid
    spoof_client = ApiClient(token="user_a_token", account_id="account-b-uuid")
    
    res = await spoof_client.post(
        "/accounts/account-b-uuid/members/invite",
        json={"phone": "+201011112222", "role": "manager"}
    )
    assert res.status_code in [404, 403]
