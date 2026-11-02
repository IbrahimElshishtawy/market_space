import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_responder_cannot_invite_members():
    """
    Vertical Privilege Escalation:
    In Account A, User B is only a 'responder' (chat support).
    User B must be prohibited from inviting new members or modifying roles.
    """
    responder_client = ApiClient(token="user_b_token", account_id="account-a-uuid")
    
    res = await responder_client.post(
        "/accounts/account-a-uuid/members/invite",
        json={"phone": "+201099887766", "role": "manager"}
    )
    assert res.status_code == 403, f"Expected 403 Forbidden for role escalation, got {res.status_code}"
    err = res.json()
    assert err["success"] is False
    assert err["error"]["code"] == "FORBIDDEN_INSUFFICIENT_ROLE"

@pytest.mark.security
@pytest.mark.asyncio
async def test_owner_can_invite_members():
    """Account Owner has administrative authority to invite members."""
    owner_client = ApiClient(token="user_a_token", account_id="account-a-uuid")
    res = await owner_client.post(
        "/accounts/account-a-uuid/members/invite",
        json={"phone": "+201099887766", "role": "manager"}
    )
    assert res.status_code == 200
    assert res.json()["success"] is True
