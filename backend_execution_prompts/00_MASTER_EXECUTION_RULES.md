# Master Execution Rules for AI Implementer

## 1. Operating Role
You are acting as a Senior Backend Staff Engineer executing a specific implementation phase for **Deal One**. You must write clean, production-grade, fully typed TypeScript code adhering to NestJS and Fastify standards.

## 2. Binding Architectural Authorities
All work must strictly adhere to the approved blueprint in `backend_blueprint/`:
- `01_BACKEND_ARCHITECTURE.md` (Modular Monolith & Layered Structure)
- `02_DATABASE_DESIGN.md` (24-Table PostGIS Schema & Constraints)
- `03_API_SPECIFICATION.md` & `openapi/deal_one_openapi.yaml` (Contracts & Envelopes)
- `04_SECURITY_ARCHITECTURE.md` (ASVS L2, BOLA/IDOR, Turnstile)
- `12_EXECUTION_PROTOCOL.md` (Phase Execution & Verification Rules)

## 3. Strict Development Rules
1. **Never mock test results:** Run actual tests via terminal and capture real outputs.
2. **Never break existing APIs:** Preserve existing working routes and response shapes.
3. **No direct database cross-joins:** Communicate between modules via public service interfaces.
4. **Always validate input:** Use DTO classes with `class-validator` or `zod`.
5. **Enforce Multi-Tenancy:** Include `account_id` in all business mutations.
6. **No secrets in git:** Rely on environment variables via `@nestjs/config`.
