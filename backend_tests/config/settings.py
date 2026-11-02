import os
from pydantic_settings import BaseSettings

class TestSettings(BaseSettings):
    base_url: str = os.getenv("TEST_BASE_URL", "http://localhost:3000/api/v1")
    admin_base_url: str = os.getenv("TEST_ADMIN_BASE_URL", "http://localhost:3000/api/v1")
    database_url: str = os.getenv("TEST_DATABASE_URL", "postgresql://deal_one_app:SecureDBPassword_2026@localhost:5432/deal_one_dev")
    redis_url: str = os.getenv("TEST_REDIS_URL", "redis://:SecureRedisAuthToken_2026!@localhost:6379/0")
    test_turnstile_bypass: str = "mock-turnstile-token-passed"
    timeout_seconds: float = 15.0

    class Config:
        env_file = ".env.test"
        extra = "allow"

settings = TestSettings()
