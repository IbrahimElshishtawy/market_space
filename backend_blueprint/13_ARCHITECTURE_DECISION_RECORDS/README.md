# Architecture Decision Records (ADR) — Deal One

## Register of Architecture Decisions

| ADR ID | Title | Status | Scope |
|---|---|---|---|
| [ADR-001](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-001_HYBRID_MULTI_CATEGORY_PLATFORM.md) | Strategic Direction: Hybrid Multi-Category Platform | Approved | V1 / V2 / V3 |
| [ADR-002](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-002_SHARED_CORE_ARCHITECTURE.md) | Shared Core Architecture | Approved | V1 |
| [ADR-003](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-003_CATEGORY_DRIVEN_ARCHITECTURE.md) | Category-Driven Architecture & Hybrid Data Modeling | Approved | V1 |
| [ADR-004](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-004_SELLER_ACCOUNT_VERIFICATION.md) | Tiered Seller Account Verification & Separation of Duties | Approved | V1 |
| [ADR-005](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-005_INDEPENDENT_SELLER_ACCOUNTS.md) | Multiple Independent Seller Accounts per User Identity | Approved | V1 |
| [ADR-006](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-006_GEOGRAPHIC_ARCHITECTURE_PRIVACY.md) | Two-Tier Geographic Architecture & Spatial Privacy | Approved | V1 |
| [ADR-007](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-007_ORTHOGONAL_LISTING_LIFECYCLE_STATES.md) | Orthogonal Independent Listing Lifecycle Axes | Approved | V1 |
| [ADR-008](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-008_V1_CONTACT_ONLY_TRANSACTION_MODE.md) | V1 Transaction Modes: Contact-Only Discovery Scope | Approved | V1 |
| [ADR-009](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-009_COMMERCE_MODULE_BOUNDARY.md) | E-Commerce Module Boundary & Listing vs. Product Separation | Approved | V3 Planned |
| [ADR-010](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-010_BOOKING_MODULE_BOUNDARY.md) | Booking & Appointments Module Boundary | Approved | V3 Planned |
| [ADR-011](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-011_NOTIFICATIONS_AND_SAVED_SEARCHES.md) | Operational Push Notifications (V1) vs. Saved Searches (V2) | Approved | V1 / V2 |
| [ADR-012](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-012_MODULAR_MONOLITH_ARCHITECTURE.md) | Modular Monolith Backend Pattern | Approved | V1 |
| [ADR-013](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-013_TECHNOLOGY_STACK.md) | Production Technology Stack: NestJS + Fastify + PostgreSQL + Redis | Approved | V1 |
| [ADR-014](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/13_ARCHITECTURE_DECISION_RECORDS/ADR-014_PYTHON_TESTING_HARNESS.md) | Automated Python Quality & Load Testing Harness (Pytest + Locust) | Approved | V1 |

---

## Detailed ADR Records

### ADR-013: Production Technology Stack Selection
- **Status:** Approved
- **Context:** Deal One requires high-throughput API processing, low latency, robust validation, relational data integrity, PostGIS geographic queries, Redis-backed rate limiting and daily midnight resets, asynchronous job execution, and strong developer productivity.
- **Alternatives Considered:**
  1. *Laravel (PHP 8.3):* Excellent developer experience and built-in admin ecosystems, but higher memory footprint per worker, inferior native WebSocket/asynchronous event streaming concurrency compared to Node.js/Go, and context switching for Flutter/TypeScript teams.
  2. *FastAPI / Django (Python):* Excellent for data science and ML, but higher latency under high concurrent I/O without heavy async tuning; team ecosystem in Node/TypeScript matches Flutter mobile models better.
  3. *Go (Golang / Gin):* Extreme raw performance and low memory, but high development cost for dynamic JSONB category schema validations, migrations, and team velocity at startup stage.
  4. *NestJS with Fastify (Node.js 20 LTS + TypeScript):* Combines enterprise architectural patterns (Dependency Injection, modular structure, strict TypeScript typings, class-validator/Zod) with the extreme performance of the Fastify HTTP engine (2x faster than Express, near-zero overhead).
- **Decision:** Select **NestJS on Fastify with PostgreSQL 16 + PostGIS, Redis 7 (ioredis + BullMQ), and Prisma ORM**.
- **Consequences:** Low latency (<50ms API overhead), strong type safety across models, structured modularity matching ADR-012, and seamless migration path if individual modules ever need extraction.

### ADR-014: Automated Python Quality & Load Testing Harness
- **Status:** Approved
- **Context:** To ensure the backend withstands production traffic up to 10,000 concurrent users without regressions, a decoupled, language-independent testing harness is required that runs against live HTTP/WebSocket endpoints.
- **Decision:** Implement a Python 3.11+ testing infrastructure located in `backend_tests/` utilizing:
  - `pytest` + `httpx` for functional, integration, BOLA, IDOR, and security fuzzing.
  - `locust` for scalable, distributed concurrent load and stress testing.
- **Consequences:** Completely isolates tests from backend implementation details; tests behave exactly like real mobile clients and malicious actors.
