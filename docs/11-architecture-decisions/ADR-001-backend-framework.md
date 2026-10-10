# ADR-001: Backend Framework and Language Selection

## Status
Approved

## Context
Market Space requires a robust, maintainable backend for an Egyptian classifieds platform. Key requirements include:
- Rapid development velocity by a lean engineering team.
- High developer synergy with the Next.js (TypeScript) administrative web dashboard and Flutter mobile clients.
- Clean architectural structure supporting Dependency Injection, strict validation, and OpenAPI documentation generation.
- Efficient memory and CPU resource utilization for deployment on an initial VPS (4 vCPUs, 8 GB RAM).

Options evaluated:
1. **NestJS (TypeScript / Node.js):** Modular architecture, first-class TypeScript typing, shared interfaces with Next.js, built-in validation pipes, native microservice/worker transport, rich ecosystem (Prisma, BullMQ).
2. **Laravel (PHP 8.3):** Highly mature MVC framework, rich ecosystem (Filament, Queues), but creates a split tech stack (PHP for backend, TypeScript for admin web, Dart for Flutter).
3. **Go (Gin / Fiber):** Maximum raw performance and low RAM footprint, but higher development overhead for dynamic category schemas, validation, and complex business logic.

## Decision
We select **NestJS (TypeScript / Node.js 20 LTS)** with the Fastify adapter as the authoritative backend framework.

## Consequences
- **Positive:**
  - Complete type safety across backend modules and shared TypeScript DTOs with the Next.js back-office.
  - Native integration with BullMQ for background job processing and Prisma for type-safe database queries.
  - Declarative validation via `class-validator` and automated OpenAPI generation via `@nestjs/swagger`.
- **Negative:**
  - Slightly higher baseline memory footprint than Go (approx. 150MB RSS per process), but easily accommodated by the 8GB VPS.
