import httpx
from typing import Dict, Any, Tuple
from backend_tests.config.settings import settings

class AuthClient:
    def __init__(self):
        self.base_url = settings.base_url.rstrip("/")

    async def send_otp(self, phone: str) -> httpx.Response:
        async with httpx.AsyncClient(timeout=settings.timeout_seconds) as client:
            return await client.post(
                f"{self.base_url}/auth/otp/send",
                json={"phone": phone, "turnstile_token": settings.test_turnstile_bypass},
            )

    async def verify_otp(self, phone: str, code: str) -> Tuple[str, str, Dict[str, Any]]:
        async with httpx.AsyncClient(timeout=settings.timeout_seconds) as client:
            response = await client.post(
                f"{self.base_url}/auth/otp/verify",
                json={
                    "phone": phone,
                    "code": code,
                    "device_info": {"platform": "android", "fcm_token": "mock_fcm_token"},
                },
            )
            data = response.json().get("data", {})
            return data.get("access_token", ""), data.get("refresh_token", ""), data

    async def refresh_token(self, refresh_token: str) -> httpx.Response:
        async with httpx.AsyncClient(timeout=settings.timeout_seconds) as client:
            return await client.post(
                f"{self.base_url}/auth/token/refresh",
                json={"refresh_token": refresh_token},
            )
