# Deal One — Automated Python Testing & Load Test Suite

## Overview
This directory contains the independent, production-grade automated testing harness for the **Deal One** backend. It validates functional API contracts, database transaction integrity, multi-tenant BOLA/IDOR security boundaries, and high-concurrency Locust load capacity (100 to 10,000 CCU).

---

## Directory Structure
```
backend_tests/
├── requirements.txt           # Test dependencies (pytest, httpx, locust, pydantic)
├── pytest.ini                 # Pytest configuration & markers
├── config/
│   ├── settings.py            # Pydantic test environment configuration
│   └── environments.py        # Local, staging, and production URL presets
├── clients/
│   ├── api_client.py          # HTTPX asynchronous client with error handling
│   └── auth_client.py         # OTP & Token rotation helper client
├── fixtures/
│   ├── users.py               # Deterministic synthetic user personas
│   ├── authentication.py      # Authenticated session fixtures
│   └── test_data.py           # Sample categories, locations, and listings
├── functional/                # 9 Functional API test suites
│   ├── test_authentication.py
│   ├── test_users.py
│   ├── test_profiles.py
│   ├── test_listings.py
│   ├── test_search.py
│   ├── test_filters.py
│   ├── test_uploads.py
│   ├── test_notifications.py
│   └── test_admin.py
├── integration/               # Database, transaction & concurrency test suites
│   ├── test_database.py
│   ├── test_transactions.py
│   ├── test_authorization.py
│   └── test_concurrency.py
├── security/                  # OWASP ASVS & API Top 10 security test suites
│   ├── test_auth_attacks.py
│   ├── test_authorization_attacks.py
│   ├── test_rate_limiting.py
│   ├── test_input_validation.py
│   ├── test_file_upload_security.py
│   ├── test_bola.py
│   └── test_idor.py
├── performance/               # Locust concurrent load testing suite
│   ├── locustfile.py          # Locust entrypoint & user persona weights
│   └── scenarios/
│       ├── normal_traffic.py
│       ├── peak_traffic.py
│       ├── authentication_load.py
│       ├── search_load.py
│       ├── listing_load.py
│       └── admin_load.py
└── reports/                   # Test output artifacts, coverage & Locust HTML
    └── .gitkeep
```

---

## How to Run Tests

### 1. Setup Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r backend_tests/requirements.txt
```

### 2. Run Functional & Security Tests
```bash
# Run all tests
pytest backend_tests/

# Run security fuzzing tests only
pytest backend_tests/security/

# Run with coverage report
pytest --cov=backend_tests --cov-report=html:backend_tests/reports/coverage
```

### 3. Run Locust Concurrent Load Tests
```bash
# Run 100 concurrent users for 5 minutes headless
locust -f backend_tests/performance/locustfile.py --headless -u 100 -r 10 -t 5m --host http://localhost:3000 --html backend_tests/reports/load_100ccu.html

# Run with interactive Web UI
locust -f backend_tests/performance/locustfile.py --host http://localhost:3000
```
