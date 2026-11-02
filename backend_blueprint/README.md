# Deal One — Backend Engineering Blueprint & System Architecture

## Overview
This directory contains the production-grade architectural specification, engineering blueprint, database designs, API contracts, security frameworks, and implementation guides for the **Deal One** platform.

Deal One is a hybrid multi-category marketplace operating in Egypt across six vertical industries:
1. **Real Estate (عقارات)**
2. **Cars / Automotive (سيارات)**
3. **Building Materials & Electricity (مواد بناء وكهرباء)**
4. **Home Services (خدمات منزلية وفنية)**
5. **Fashion & Accessories (أزياء وإكسسوارات)**
6. **Home Appliances & Decor (أجهزة منزلية وديكور)**

---

## Directory Structure

```
backend_blueprint/
├── README.md                                    # This directory index & guidance
├── 00_EXECUTIVE_SUMMARY.md                      # High-level strategic & technical summary
├── 01_BACKEND_ARCHITECTURE.md                   # Modular Monolith system design & request flow
├── 02_DATABASE_DESIGN.md                        # Complete PostGIS + PostgreSQL schema (24+ entities)
├── 03_API_SPECIFICATION.md                      # Complete API inventory, contracts & validation
├── 04_SECURITY_ARCHITECTURE.md                  # ASVS Level 2, API Top 10, Turnstile, RBAC
├── 05_ADMIN_CONTROL_CENTER.md                   # Moderation queues, RBAC, audit trails, and quotas
├── 06_OBSERVABILITY_AND_OPERATIONS.md           # Prometheus, Grafana, OpenTelemetry, SLOs/SLIs
├── 07_PERFORMANCE_TESTING.md                    # 100 to 10,000 CCU test strategy & Locust suite
├── 08_QUALITY_ASSURANCE.md                      # Release gates, static analysis, P0-P3 classifications
├── 09_FLUTTER_INTEGRATION.md                    # Mobile client mapping, Dio interceptors, Drift cache
├── 10_DEPLOYMENT_AND_INFRASTRUCTURE.md          # Docker, Nginx, PostgreSQL 16, Redis 7, Cloudflare
├── 11_IMPLEMENTATION_ROADMAP.md                 # 17 phased delivery plan with dependencies
├── 12_EXECUTION_PROTOCOL.md                     # Mandatory rules and reporting templates for AI runs
├── 13_ARCHITECTURE_DECISION_RECORDS/           # ADR-001 through ADR-014
├── 14_DIAGRAMS/                                 # Architectural & Flow Diagrams (Mermaid & ASCII)
├── 15_OPENAPI/                                  # Complete OpenAPI 3.1.0 YAML definition
└── 16_AUDIT_REPORTS/                            # Document consistency & code discrepancy audit
```

---

## Key Architectural Principles (The Three Pillars)

1. **Shared Core Architecture:**
   Authentication, Identity, Multi-tenant Accounts, RBAC, Media Management, Locations, PostGIS Geo-search, Real-time Chat, Moderation, and Quotas are unified across all categories.

2. **Category-Driven Business Rules:**
   Each category defines its own dynamic attributes, validation rules, search filters, and operational listings constraints using a hybrid PostgreSQL model (JSONB + GIN indexing alongside relational core tables).

3. **Independently Evolving Transaction Modules:**
   V1 is strictly scoped to **`contact_only`** discovery, listing moderation, and secure communication (in-app WebSocket chat and quota-controlled external WhatsApp/call reveal). Future modules (E-commerce catalog, multi-branch inventory, shopping carts, online payments, and appointment bookings) are architecturally separated and scheduled for V3.

---

## How to Use This Blueprint

1. **Review the Executive Summary:** Start with [`00_EXECUTIVE_SUMMARY.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/00_EXECUTIVE_SUMMARY.md).
2. **Review the Database & APIs:** Inspect [`02_DATABASE_DESIGN.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/02_DATABASE_DESIGN.md) and [`03_API_SPECIFICATION.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/03_API_SPECIFICATION.md).
3. **Execute Implementation:** Follow the sequential execution prompts located in `backend_execution_prompts/` in numeric order, strictly obeying [`12_EXECUTION_PROTOCOL.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/12_EXECUTION_PROTOCOL.md).
4. **Run Verification & Load Tests:** Execute the test suites in `backend_tests/` against local or staging environments.
