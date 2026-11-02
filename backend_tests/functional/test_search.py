import pytest
from backend_tests.clients.api_client import ApiClient

@pytest.mark.functional
@pytest.mark.asyncio
async def test_search_and_postgis_distance():
    client = ApiClient()

    # 1. Text and Category Search
    res = await client.get("/search", params={"q": "هيونداي", "category_slug": "cars", "limit": 10})
    assert res.status_code == 200
    body = res.json()
    assert body["success"] is True
    assert isinstance(body["data"], list)

    # 2. Spatial Radius Search around Cairo
    geo_res = await client.get("/search", params={
        "lat": 30.0444,
        "lng": 31.2357,
        "radius_km": 20,
        "sort_by": "nearest"
    })
    assert geo_res.status_code == 200
    assert "data" in geo_res.json()
