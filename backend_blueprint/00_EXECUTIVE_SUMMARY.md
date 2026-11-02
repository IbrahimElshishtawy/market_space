# Deal One — Backend Architecture Executive Summary

## 1. Product Vision & Architectural Mission

**Deal One** is a modern, high-performance hybrid multi-category marketplace engineered specifically for the Egyptian market. It connects individual buyers, sellers, property seekers, vehicle dealers, industrial factories, engineering consultancies, and retailers across six core industries:
1. **Real Estate (عقارات)**
2. **Automotive (سيارات)**
3. **Building Materials & Electrical Supplies (مواد بناء وكهرباء)**
4. **Home & Technical Services (خدمات صيانة ومنزلية)**
5. **Fashion & Apparel (أزياء وإكسسوارات)**
6. **Home Appliances & Decor (أجهزة منزلية وديكور)**

To address the divergent business rules across these industries without introducing software bloat or fragile hacks, Deal One is designed around three foundational architectural principles:
- **Shared Core:** Standardized Identity, Authentication, Multi-tenant Accounts, Team RBAC, PostGIS Spatial Engine, Media Processing, Real-time Chat, Moderation Queues, Daily Quotas, and Auditing.
- **Category-Driven Rules:** Domain-specific dynamic attributes, localized validation rules, and specialized faceted search indexes.
- **Independently Evolving Transaction Modules:** A strict three-phase roadmap where **V1 focuses exclusively on high-trust discovery and `contact_only` communication** (in-app WebSocket chat and quota-controlled WhatsApp/phone reveal), while heavy transactional modules (E-commerce catalog, SKU variants, multi-branch inventory, carts, checkout, payment gateways, and booking calendars) remain cleanly decoupled for **V3**.

---

## 2. Technology Stack Evaluation & Selection

| Component | Selected Technology | Alternative Evaluated | Why It Fits Deal One |
|---|---|---|---|
| **Backend Framework** | **Node.js (v20 LTS) + NestJS + Fastify** | Laravel 11 / Express / Go Gin | Fastify provides ~2x throughput of Express and sub-millisecond route dispatching. NestJS delivers enterprise-grade Modular Monolith structure, strong TypeScript type safety matching the Flutter client, dependency injection, and out-of-the-box OpenAPI documentation. |
| **Primary Database** | **PostgreSQL 16 + PostGIS Extension** | MySQL 8 / MongoDB | PostGIS offers the industry standard for spatial indexing (`ST_DWithin`, `ST_Distance`, GIST index) essential for Egypt governorates/cities and GPS radius queries. PostgreSQL JSONB + GIN indexing provides the ideal hybrid store for dynamic category attributes. |
| **Caching & Fast State** | **Redis 7 (Standalone / Cluster ready)** | Memcached / KeyDB | Handles user session tokens, rate limiting counters, pub/sub for real-time WebSocket chat distribution, and daily quota tracking resetting at midnight Africa/Cairo time. |
| **Background Jobs** | **BullMQ (Redis-backed)** | RabbitMQ / Celery | Lightweight, reliable asynchronous job processing for media thumbnail generation, FCM push dispatch, audit logging, and scheduled expiration without Kafka/RabbitMQ operational overhead. |
| **Object Storage** | **Cloudflare R2 (S3-compatible)** | AWS S3 / MinIO | Zero-egress fee storage with direct Presigned URL uploads, integrated with Cloudflare Image Optimization and global CDN edge caching. |
| **Edge Security & WAF** | **Cloudflare WAF + Turnstile** | reCAPTCHA v3 / AWS WAF | Privacy-first, CAPTCHA-less bot defense for phone OTP verification, login endpoints, and DDoS protection tailored to Egyptian telecommunication latencies. |
| **Testing Harness** | **Python 3.11+ (Pytest + HTTPX + Locust)** | Postman / k6 / JMeter | Completely decoupled, scriptable test suite executing functional, BOLA/IDOR security fuzzing, and scalable concurrent load tests (100 to 10,000 CCU) against running live servers. |

---

## 3. High-Level System Architecture

Deal One follows a **Modular Monolith** architecture pattern. Code is organized into strict, decoupled Bounded Contexts residing in a single deployment artifact:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DEAL ONE CLIENT TIER                             │
├──────────────────────────────────────┬──────────────────────────────────────┤
│  Flutter Mobile App (Customer Feed,  │   Admin Web Control Center (React/   │
│  Explore, Search, Chat, Switcher)    │   Next.js - Moderation, Logs, Quotas)│
└──────────────────┬───────────────────┴──────────────────┬───────────────────┘
                   │ HTTPS / WSS                          │ HTTPS
                   ▼                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EDGE & REVERSE PROXY INFRASTRUCTURE                      │
│        Cloudflare WAF / Turnstile DDoS Shield  ──►  Nginx Reverse Proxy     │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Unix Socket / HTTP:3000
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                 NESTJS + FASTIFY MODULAR MONOLITH BACKEND                   │
│                                                                             │
│  ┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────┐  │
│  │ 1. Identity & Auth    │ │ 2. Accounts & Members │ │ 3. Geo & Locations│  │
│  │ (OTP, JWT, Sessions)  │ │ (Multi-tenant, RBAC)  │ │ (PostGIS, Areas)  │  │
│  └───────────────────────┘ └───────────────────────┘ └───────────────────┘  │
│  ┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────┐  │
│  │ 4. Categories & Schema│ │ 5. Listings Core      │ │ 6. Media Engine   │  │
│  │ (Dynamic Attributes)  │ │ (3-Axis Lifecycle)    │ │ (R2 Presigned)    │  │
│  └───────────────────────┘ └───────────────────────┘ └───────────────────┘  │
│  ┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────┐  │
│  │ 7. Search & Filter    │ │ 8. Chat & Real-Time   │ │ 9. Moderation/Logs│  │
│  │ (PostGIS + GIN JSONB) │ │ (WebSocket, Outbox)   │ │ (Append-Only Log) │  │
│  └───────────────────────┘ └───────────────────────┘ └───────────────────┘  │
│  ┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────┐  │
│  │ 10. Notifications     │ │ 11. Quotas Engine     │ │ 12. Settings/Audit│  │
│  │ (FCM Push Service)    │ │ (Redis Cairo Midnight)│ │ (Platform Config) │  │
│  └───────────────────────┘ └───────────────────────┘ └───────────────────┘  │
└──────────────────────┬──────────────────────────────────┬───────────────────┘
                       │                                  │
                       ▼                                  ▼
┌──────────────────────────────────────┐  ┌───────────────────────────────────┐
│     POSTGRESQL 16 + POSTGIS          │  │              REDIS 7              │
│  • 24 Relational Core Tables         │  │  • Session Tokens & Revocation    │
│  • GIST Spatial Indexes              │  │  • Daily Rate Limiting & Quotas   │
│  • GIN Index on JSONB Attributes     │  │  • BullMQ Task Queues             │
│  • Append-Only Moderation/Audit Logs │  │  • Real-Time Pub/Sub Message Bus  │
└──────────────────────────────────────┘  └───────────────────────────────────┘
```

---

## 4. Key Architectural Highlights

### 4.1 Multi-Tenant Account Architecture (ADR-005)
A single authenticated human user (`users`) can own or join multiple independent business entities (`accounts`). An account can represent an individual, real estate developer, building material distributor, contractor, or retail outlet. Each account maintains its own verification status, team members with distinct roles (`owner`, `manager`, `lister`, `responder`), branch locations, service polygons, and daily quotas.

### 4.2 Orthogonal 3-Axis Listing Lifecycle (ADR-007)
Listings never collapse their lifecycle into a single fragile status column. Every listing is governed by three independent status dimensions:
1. `moderation_status`: `draft` ➔ `pending` ➔ `approved` or `rejected` (with reason codes recorded in an append-only `moderation_log`).
2. `publication_status`: `unpublished` ➔ `published` ➔ `hidden` (seller preference) ➔ `archived` (auto-expired).
3. `availability_status`: `available` ➔ `reserved` ➔ `sold` / `rented` / `out_of_stock` / `discontinued`.

### 4.3 Two-Tier Privacy-Preserving Geographic Engine (ADR-006)
- **Physical Coordinates (`physical_lat`, `physical_lng`):** Exact high-precision coordinates indexed using PostGIS GIST geometry. Kept strictly confidential and never returned to public clients for residential real estate and personal assets.
- **Display Coordinates (`display_lat`, `display_lng`):** Automatically fuzzed coordinates (300–600m centroid offset) returned to public clients.
- **Graceful GPS Degradation:** If a user denies location permissions, the app degrades seamlessly to administrative district selection (`area_id`) without blocking search.

### 4.4 Automated Midnight Quota Engine (Cairo Time)
To prevent scraping, spam, and platform abuse, all accounts are bound by daily quotas for:
- Listing submissions.
- Initiating chat conversations.
- Phone number reveals / external WhatsApp click-throughs.
Quotas are enforced in sub-millisecond Redis counters and automatically reset at **00:00:00 Africa/Cairo time** taking daylight saving time shifts into account.

---

## 5. Summary Metrics of Backend Architecture

- **Total Database Tables Identified:** **24 core tables** (V1) + 4 planned V2 tables + 9 planned V3 tables.
- **Total Production API Endpoints Specified:** **52 endpoints** across 12 domain modules.
- **Security Compliance Level:** OWASP ASVS Level 2 and OWASP API Security Top 10 (2023).
- **Concurrent User Scaling Targets:** Tested and validated for 100, 500, 1,000, 5,000, and 10,000 concurrent active users.
- **Response Time SLO:** p95 latency < 150ms for cached queries, < 300ms for PostGIS spatial searches.
