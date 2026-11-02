# Deal One (صفقة ون) — Hybrid Multi-Category Platform

## 1. Project Overview
**Deal One** is a high-performance, production-grade hybrid multi-category marketplace engineered specifically for the Egyptian market. The platform connects consumers, independent merchants, property developers, vehicle dealers, industrial factories, and service contractors across six core industries:
1. **Real Estate (عقارات)**
2. **Automotive (سيارات)**
3. **Building Materials & Electricity (مواد بناء وكهرباء)**
4. **Home & Technical Services (خدمات منزلية وفنية)**
5. **Fashion & Apparel (أزياء وإكسسوارات)**
6. **Home Appliances & Decor (أجهزة منزلية وديكور)**

---

## 2. Repository Structure

```
.
├── backend/                     # NestJS + Fastify Modular Monolith application
├── backend_blueprint/           # Complete architectural blueprints & engineering specs
│   ├── 00_EXECUTIVE_SUMMARY.md
│   ├── 01_BACKEND_ARCHITECTURE.md
│   ├── 02_DATABASE_DESIGN.md
│   ├── 03_API_SPECIFICATION.md
│   ├── 04_SECURITY_ARCHITECTURE.md
│   ├── 05_ADMIN_CONTROL_CENTER.md
│   ├── 06_OBSERVABILITY_AND_OPERATIONS.md
│   ├── 07_PERFORMANCE_TESTING.md
│   ├── 08_QUALITY_ASSURANCE.md
│   ├── 09_FLUTTER_INTEGRATION.md
│   ├── 10_DEPLOYMENT_AND_INFRASTRUCTURE.md
│   ├── 11_IMPLEMENTATION_ROADMAP.md
│   ├── 12_EXECUTION_PROTOCOL.md
│   ├── 13_ARCHITECTURE_DECISION_RECORDS/
│   ├── 14_DIAGRAMS/
│   ├── 15_OPENAPI/
│   └── 16_AUDIT_REPORTS/
├── backend_execution_prompts/   # Sequential implementation execution prompts (Phase 00 - 17)
├── backend_tests/               # Independent Python test suite (Pytest, HTTPX, Locust)
├── market_space/                # Flutter Clean Architecture mobile applications
├── mock_data/                   # Business analysis, SRS, original specs, and mock data
├── BACKEND_PROJECT_STATUS.md    # Live phase tracker, approved ADRs, and quality status
└── README.md                    # This file
```

---

## 3. How to Use the Backend Engineering System

### For Architects & Reviewers:
- Start with the [`backend_blueprint/00_EXECUTIVE_SUMMARY.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/00_EXECUTIVE_SUMMARY.md).
- Review the PostGIS database design in [`backend_blueprint/02_DATABASE_DESIGN.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/02_DATABASE_DESIGN.md).
- Inspect the complete API contracts in [`backend_blueprint/openapi/deal_one_openapi.yaml`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/openapi/deal_one_openapi.yaml).
- Check the conflict and consistency audit report in [`backend_blueprint/16_AUDIT_REPORTS/01_DOCUMENTATION_CONFLICT_AUDIT.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/16_AUDIT_REPORTS/01_DOCUMENTATION_CONFLICT_AUDIT.md).

### For AI Implementers & Developers:
1. Consult [`BACKEND_PROJECT_STATUS.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/BACKEND_PROJECT_STATUS.md) to identify the current active phase.
2. Review [`backend_blueprint/12_EXECUTION_PROTOCOL.md`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_blueprint/12_EXECUTION_PROTOCOL.md) for mandatory rules and reporting formats.
3. Open the corresponding execution prompt from [`backend_execution_prompts/`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_execution_prompts/) and execute strictly according to scope.
4. Run automated verification tests in [`backend_tests/`](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/backend_tests/).
