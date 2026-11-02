import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_third_party_cannot_read_private_chat():
    """
    Chat Eavesdropping Defense:
    Conversation between Buyer A and Seller B cannot be read by User C
    who has no relationship with Account A or Account B.
    """
    unauthorized_client = ApiClient(token="user_a_token", account_id="unrelated-account-c")
    
    res = await unauthorized_client.get("/chat/conversations/conv-between-a-and-b/messages")
    assert res.status_code == 404, f"Expected 404 to protect conversation privacy, got {res.status_code}"
    assert res.json()["success"] is False

@pytest.mark.security
@pytest.mark.asyncio
async def test_participant_can_access_chat():
    """Legitimate participant can access conversation history."""
    participant_client = ApiClient(token="user_a_token", account_id="account-a-uuid")
    res = await participant_client.get("/chat/conversations/conv-between-a-and-b/messages")
    assert res.status_code == 200
    assert res.json()["success"] is True
