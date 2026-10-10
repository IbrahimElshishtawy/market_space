# ADR-002: Modular Monolith vs. Microservices Architecture

## Status
Approved

## Context
A major architectural choice for Market Space is determining the system topology: deploying a set of distributed microservices versus a single cohesive Modular Monolith.
Key project factors:
- Initial team size: 1–3 backend engineers.
- Primary deployment environment: Single Virtual Private Server (VPS) with Docker Compose.
- Expected initial scale: Target growth toward 50,000 registered users, with typical concurrency of 100–300 users.

Microservices introduce significant operational overhead: distributed tracing, cross-service transactions (Saga pattern), network latency, complex CI/CD pipelines, and multi-container resource pressure on a modest VPS.

## Decision
We select a **Modular Monolith** architecture. All business domains (Auth, Categories, Listings, Media, Chat, Payments, Moderation, Notifications) reside within a single codebase, strictly divided into independent NestJS modules with encapsulated dependencies and dedicated domain services.

## Consequences
- **Positive:**
  - Simple deployment and operations via a single Docker container set.
  - ACID transactions available across related tables when essential (e.g., listings and initial media records).
  - No distributed networking overhead or partial failure handling across microservices.
  - Very fast development iteration.
- **Negative:**
  - Strict coding discipline is required to avoid leaking dependencies between modules.
  - Scaling a single hot module independently requires future extraction, but modular boundaries make this straightforward if needed.
