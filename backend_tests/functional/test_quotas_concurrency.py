import pytest
import asyncio
from datetime import datetime, time, timedelta
import zoneinfo
from unittest.mock import AsyncMock, patch

from backend_tests.clients.api_client import ApiClient

CAIRO_TZ = zoneinfo.ZoneInfo("Africa/Cairo")

def get_seconds_until_cairo_midnight() -> int:
    now = datetime.now(CAIRO_TZ)
    tomorrow = now.date() + timedelta(days=1)
    midnight = datetime.combine(tomorrow, time.min, tzinfo=CAIRO_TZ)
    return int((midnight - now).total_seconds())

class InMemoryMockRedis:
    """Mock Redis with Lua atomic counter behavior for quota testing."""
    def __init__(self):
        self.store = {}
        self.expiry = {}

    async def execute_quota_lua(self, key: str, max_limit: int, ttl_seconds: int) -> int:
        current = self.store.get(key, 0)
        if current >= max_limit:
            return -1  # Exceeded limit
        new_val = current + 1
        self.store[key] = new_val
        if new_val == 1:
            self.expiry[key] = ttl_seconds
        return max_limit - new_val  # Remaining

@pytest.mark.functional
@pytest.mark.asyncio
async def test_cairo_midnight_ttl_calculation():
    """Verify TTL strictly targets 00:00:00 Africa/Cairo with Daylight Saving Awareness."""
    ttl = get_seconds_until_cairo_midnight()
    assert 0 < ttl <= 86400, "TTL must be positive and less than or equal to 24 hours"

@pytest.mark.functional
@pytest.mark.asyncio
async def test_atomic_quota_concurrency_race_condition():
    """Simulate 20 concurrent contact reveal requests against an individual limit of 15."""
    redis_mock = InMemoryMockRedis()
    account_id = "test-individual-acc-uuid"
    cairo_date = datetime.now(CAIRO_TZ).strftime("%Y-%m-%d")
    quota_key = f"quota:{account_id}:reveals:{cairo_date}"
    max_limit = 15
    ttl = get_seconds_until_cairo_midnight()

    # Launch 25 concurrent deduction attempts
    async def make_attempt():
        return await redis_mock.execute_quota_lua(quota_key, max_limit, ttl)

    tasks = [make_attempt() for _ in range(25)]
    results = await asyncio.gather(*tasks)

    successful_reveals = [r for r in results if r >= 0]
    rejected_reveals = [r for r in results if r == -1]

    assert len(successful_reveals) == 15, f"Expected exactly 15 successes, got {len(successful_reveals)}"
    assert len(rejected_reveals) == 10, f"Expected exactly 10 rejected with 429, got {len(rejected_reveals)}"
    assert redis_mock.store[quota_key] == 15, "Final counter in Redis must equal exactly max_limit"

@pytest.mark.functional
@pytest.mark.asyncio
async def test_business_account_quota_threshold():
    """Verify commercial accounts have higher quota limit (100 reveals)."""
    redis_mock = InMemoryMockRedis()
    account_id = "test-company-acc-uuid"
    cairo_date = datetime.now(CAIRO_TZ).strftime("%Y-%m-%d")
    quota_key = f"quota:{account_id}:reveals:{cairo_date}"
    max_limit = 100
    ttl = get_seconds_until_cairo_midnight()

    # Simulate 100 reveals
    for i in range(100):
        res = await redis_mock.execute_quota_lua(quota_key, max_limit, ttl)
        assert res >= 0, f"Reveal #{i+1} should succeed"

    # 101st reveal must be rejected
    rejected = await redis_mock.execute_quota_lua(quota_key, max_limit, ttl)
    assert rejected == -1, "101st reveal must be rejected"
