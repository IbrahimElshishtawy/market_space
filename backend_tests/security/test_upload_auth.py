import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.security
@pytest.mark.asyncio
async def test_upload_requires_authentication():
    """Unauthenticated users cannot request presigned R2 upload URLs."""
    public_client = ApiClient()
    res = await public_client.post(
        "/media/presigned-url",
        json={"filename": "photo.jpg", "mime_type": "image/jpeg", "size_bytes": 1024}
    )
    assert res.status_code == 401
    assert res.json()["success"] is False

@pytest.mark.security
@pytest.mark.asyncio
async def test_disallowed_mime_types_rejected():
    """Executable and dangerous script uploads are strictly rejected."""
    client = ApiClient(token="user_a_token")
    res = await client.post(
        "/media/presigned-url",
        json={"filename": "payload.exe", "mime_type": "application/x-msdownload", "size_bytes": 5000}
    )
    assert res.status_code == 400
    err = res.json()
    assert err["error"]["code"] == "UNSUPPORTED_MEDIA_TYPE"

@pytest.mark.security
@pytest.mark.asyncio
async def test_file_size_exceeding_10mb_rejected():
    """Files exceeding 10MB limit are rejected."""
    client = ApiClient(token="user_a_token")
    res = await client.post(
        "/media/presigned-url",
        json={"filename": "heavy_video.mp4", "mime_type": "video/mp4", "size_bytes": 15 * 1024 * 1024}
    )
    assert res.status_code == 400
    assert res.json()["error"]["code"] == "FILE_TOO_LARGE"

@pytest.mark.security
@pytest.mark.asyncio
async def test_valid_image_upload_url_granted():
    """Legitimate image upload request receives signed upload URL."""
    client = ApiClient(token="user_a_token")
    res = await client.post(
        "/media/presigned-url",
        json={"filename": "apartment.webp", "mime_type": "image/webp", "size_bytes": 1024 * 500}
    )
    assert res.status_code == 200
    data = res.json()["data"]
    assert "upload_url" in data
    assert "key" in data
