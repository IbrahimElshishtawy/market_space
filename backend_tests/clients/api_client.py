import os
import httpx
from typing import Optional, Dict, Any
from backend_tests.config.settings import settings
from backend_tests.clients.security_simulator import simulate_deal_one_security

class ApiClient:
    def __init__(self, token: Optional[str] = None, account_id: Optional[str] = None, use_simulator: Optional[bool] = None):
        self.base_url = settings.base_url.rstrip("/")
        self.headers: Dict[str, str] = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Accept-Language": "ar",
        }
        if token:
            self.headers["Authorization"] = f"Bearer {token}"
        if account_id:
            self.headers["X-Account-ID"] = account_id

        # Use simulator by default in pre-implementation audit if live server is not listening
        self.use_simulator = use_simulator if use_simulator is not None else (os.getenv("TEST_USE_SIMULATOR", "true").lower() == "true")

    def _get_client(self) -> httpx.AsyncClient:
        if self.use_simulator:
            return httpx.AsyncClient(transport=httpx.MockTransport(simulate_deal_one_security))
        return httpx.AsyncClient(timeout=settings.timeout_seconds)

    async def get(self, endpoint: str, params: Optional[Dict[str, Any]] = None) -> httpx.Response:
        async with self._get_client() as client:
            return await client.get(f"{self.base_url}{endpoint}", params=params, headers=self.headers)

    async def post(self, endpoint: str, json: Optional[Dict[str, Any]] = None) -> httpx.Response:
        async with self._get_client() as client:
            return await client.post(f"{self.base_url}{endpoint}", json=json, headers=self.headers)

    async def put(self, endpoint: str, json: Optional[Dict[str, Any]] = None) -> httpx.Response:
        async with self._get_client() as client:
            return await client.put(f"{self.base_url}{endpoint}", json=json, headers=self.headers)

    async def patch(self, endpoint: str, json: Optional[Dict[str, Any]] = None) -> httpx.Response:
        async with self._get_client() as client:
            return await client.patch(f"{self.base_url}{endpoint}", json=json, headers=self.headers)

    async def delete(self, endpoint: str) -> httpx.Response:
        async with self._get_client() as client:
            return await client.delete(f"{self.base_url}{endpoint}", headers=self.headers)

