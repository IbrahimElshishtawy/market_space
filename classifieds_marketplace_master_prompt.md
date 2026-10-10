# Master Prompt --- Classifieds Marketplace Platform

## Phase 1: System Design, SRS, Architecture & Review Pack

## Phase 2: Backend Implementation --- only after explicit approval

> **How to use:** Give the AI coding agent this document first. In Phase
> 1, it must produce specifications and design documents only. Review
> and approve those documents yourself. Only then send the Phase 2
> prompt at the end of this file.

------------------------------------------------------------------------

# PART A --- MASTER PROJECT CONTEXT

You are acting as a **Principal Software Architect, Product Analyst,
Senior Backend Engineer, Security Engineer, Database Architect, and
Technical Writer**.

Help me design a production-minded classifieds marketplace platform for
Egypt, inspired by the general product concept of Dubizzle and similar
classified-listing platforms. Create an original product identity and
implementation; do not copy proprietary branding, text, or exact UI.

The platform's **core product is classifieds**, not video entertainment.
Users should be able to browse categories, search and filter listings,
publish listings, contact sellers, save favorites, manage their own
listings, report abuse, and optionally promote listings. An optional
short-video feature supplements normal listings; it must not dictate the
entire product architecture.

## Product targets

-   Primary market: Egypt.
-   Primary user experience: Arabic-first, right-to-left (RTL), with a
    planned English option. The backend must support
    localization-friendly content and category labels.
-   Client applications: Flutter mobile apps for Android and iOS.
-   Web administration: Next.js admin dashboard, responsive and
    protected by role-based access.
-   Backend: a dedicated API and backend service deployed on a VPS
    initially, with a clean path to scale.
-   Database: PostgreSQL.
-   Media: object storage for images and video; do not store large media
    binaries directly in PostgreSQL.
-   Notifications: push notifications via Firebase Cloud Messaging
    (FCM); email and WhatsApp integrations are optional/configurable and
    must be designed with provider abstractions.
-   Payments: integration-ready design for a suitable Egyptian payment
    provider such as Paymob, subject to provider onboarding and current
    terms.
-   Video: optional, one video per eligible listing, maximum 30 seconds,
    with a separate vertical feed that users can browse. Evaluate a
    managed video service such as Cloudflare Stream rather than assuming
    the application server should transcode videos.
-   Initial architecture should be maintainable by a small team. Prefer
    a well-structured modular monolith over premature microservices
    unless documented evidence justifies another approach.
-   The product should be designed to support growth beyond 50,000
    registered users, but do not assume that 50,000 users means 50,000
    concurrent users. Make traffic and capacity assumptions explicit.

## Product principles

1.  **Classified listings are the primary experience.** Search,
    categories, listing detail, seller contact, posting and account
    management are core.
2.  Video is optional. Listings without video must work perfectly. The
    vertical video feed is a secondary discovery surface, not the app's
    main architecture.
3.  Categories and their fields must be configurable from the admin
    dashboard where practical, rather than hard-coded into every client
    release.
4.  Security, privacy, moderation, anti-spam, and auditability are
    requirements from the start.
5.  Do not store secrets in source code, client applications, or
    committed environment files.
6.  Use explicit API contracts, validation, authorization rules,
    pagination, consistent error responses, and database migrations.
7.  Avoid overengineering. Identify what belongs in MVP, what belongs in
    a later phase, and why.
8.  Never invent business decisions silently. List assumptions,
    unresolved decisions, alternatives, and recommendations.
9.  Do not claim a provider, API, SDK, price, or policy is current
    unless verified from official documentation when research is
    available. Mark anything requiring verification.
10. Keep implementation choices consistent across SRS, architecture,
    database schema, API specification, security plan, and delivery
    roadmap.

------------------------------------------------------------------------

# PART B --- REQUIRED PRODUCT SCOPE

Analyze and document the following capabilities. For every capability,
classify it as **MVP**, **Phase 2**, or **Later / Optional**, and
justify the classification.

## 1. Public browsing and discovery

-   Home feed with recent, relevant, promoted, and/or location-aware
    listings.
-   Category browsing and nested categories.
-   Search by keywords.
-   Filters and sorting: category, subcategory, price range, location,
    date, condition, and category-specific attributes.
-   Location selection for Egypt: governorate, city/area, and optional
    approximate map location. Do not expose a seller's precise home
    address publicly by default.
-   Listing detail page: title, price, description, images, optional
    video, category-specific attributes, condition, approximate
    location, creation/update date, seller profile summary, and contact
    actions.
-   Related listings and seller's other active listings.
-   Pagination or cursor-based loading; avoid unbounded result sets.
-   Clear empty, loading, error, and offline states for clients.

## 2. Categories and listing attributes

The initial category proposal must include at least:

-   Cars and vehicles
-   Properties for sale
-   Properties for rent
-   Mobile phones
-   Electronics and computers
-   Furniture and home items
-   Fashion and accessories
-   Jobs and recruitment
-   Services
-   Kids and baby items
-   Pets and pet supplies
-   Sports and hobbies
-   Business and industrial equipment
-   Other / miscellaneous

Treat this as a proposed taxonomy, not an unchangeable list. Recommend
an admin-manageable hierarchy with category-specific attributes. For
example, cars may have make, model, year, mileage, transmission and fuel
type; properties may have property type, area, bedrooms, bathrooms and
finishing status.

Specify: - Category and subcategory management. - Category-specific
field definitions and field types. - Required versus optional
attributes. - Validation constraints and allowed values. -
Filterable/searchable attributes. - Localization of category and field
labels. - Safe behavior when an administrator changes a category or
field that existing listings use. - Whether dynamic attributes should be
stored in JSONB, normalized tables, or a hybrid, with trade-offs and
indexes explained.

## 3. Listing lifecycle and publishing

-   Create, preview, submit, edit, pause, mark as sold/rented/closed,
    renew, and delete/archive a listing.
-   Drafts and validation errors.
-   Listing moderation states, for example: draft, pending_review,
    published, rejected, paused, expired, sold, archived. Define a
    precise state machine and allowed transitions.
-   Image upload workflow using short-lived signed upload URLs or
    another secure provider-supported flow.
-   Optional single video per eligible listing, maximum 30 seconds.
    Validate actual media duration/type/size server-side or through
    trusted processing callbacks; never trust client metadata alone.
-   Image ordering, cover image, removal, upload retry, and abandoned
    upload cleanup.
-   Configurable listing expiry, renewal policy, free-posting limits,
    and category-specific restrictions.
-   Prevent unauthorized edits, ownership changes, duplicate
    submissions, and invalid status transitions.
-   Keep a moderation and audit trail for important state changes.

## 4. Accounts and user profile

-   Sign up, sign in, sign out, refresh/revoke sessions, password reset,
    and account verification strategy.
-   Decide whether phone, email, social sign-in, or a phased combination
    belongs in the MVP. Explain trade-offs and provider dependencies.
-   Profile name, avatar, preferred language, governorate/city, and
    privacy preferences.
-   My listings, favorites, saved searches (if recommended), listing
    analytics, conversations, notifications, and account settings.
-   Account suspension, deletion request, personal data export/deletion
    policy, and retention exceptions required for legal/security
    reasons.
-   Rate limits and abuse controls for registration and authentication.
-   Never expose password hashes, internal moderation notes, private
    contact details, or tokens in API responses.

## 5. Buyer-seller communication

Evaluate and recommend an MVP communication model: - Phone reveal/call
action - WhatsApp deep link or provider integration - In-app messaging
and conversations - Optional chat attachments only if justified

For in-app messaging, specify: - Conversation and message data model. -
Conversation access rules and participant membership. - Read/unread
state, pagination, blocking, reporting, and retention. - Push
notification behavior without leaking sensitive message contents by
default. - Spam throttling and abuse reporting. - Whether real-time
updates require WebSockets or can start with a simpler approach.

Do not assume WhatsApp Business API is necessary merely to open a user's
WhatsApp app. Clearly distinguish a WhatsApp deep link from
paid/approved Business Platform messaging.

## 6. Favorites, saved searches and notifications

-   Add/remove favorites; list favorites with pagination.
-   Optional saved searches and alert preferences.
-   Notification inbox and read/unread state.
-   FCM device-token registration, rotation, and removal.
-   Notification event catalog: new message, listing approved/rejected,
    listing expiring, price change if supported, saved-search match if
    supported, payment result, moderation action.
-   Retry, idempotency, token invalidation and delivery failure
    handling.
-   User-configurable notification preferences and quiet/privacy
    considerations.

## 7. Optional short-video discovery

Video is an optional listing enhancement: - At most one video attached
to a listing in the initial scope. - Maximum duration 30 seconds. - Only
permitted formats and size limits, to be decided in the design. - Upload
must use a secure, resumable or provider-supported mechanism where
practical. - Process/encode and deliver through a managed video provider
when appropriate. - The listing detail page must remain useful if the
video fails, is still processing, or is unavailable. - Separate vertical
swipe feed for listings that contain approved videos. - Feed must
include normal listing context: price, title, location, seller, and a
path to full listing details. - Define moderation, copyright/consent
reporting, content removal, and provider webhook verification. - Define
feed ranking transparently at a high level, starting with a simple
deterministic approach; do not require machine learning for MVP. -
Define view/impression semantics, deduplication, abuse resistance, and
privacy-aware analytics. - Explain cost drivers: stored minutes,
delivered minutes, transcoding, bandwidth, and retention. Do not
hard-code estimated costs as guaranteed prices.

## 8. Monetization and payments

Evaluate, do not blindly assume, these options: - Featured listing -
Bump/raise listing to top - Promotion packages - Paid posting for
selected categories - Seller/business subscription plans

Specify: - Product/package configuration and eligibility. - Payment
initiation and verified payment confirmation. - Provider webhooks,
signature verification, idempotency and replay protection. - Payment,
transaction, refund, promotion entitlement and invoice/receipt data. -
Handling pending, successful, failed, cancelled, refunded and disputed
states where provider supports them. - Do not mark a payment successful
based only on a client redirect or client request. - Reconciliation and
support/admin audit workflow. - Server-side pricing; clients cannot
submit their own authoritative price. - Store/payment policy review
required for digital goods and in-app purchases on Android/iOS. Flag
this for validation against current Apple and Google policies before
implementation. - Payment provider fees, tax/accounting and legal
requirements must be verified for the actual business and contract.

## 9. Trust, safety and moderation

-   Report listing, user, message, and video where relevant.
-   Report reasons, status, reviewer notes and resolution.
-   Admin review queue.
-   User/listing suspension and appeal path if appropriate.
-   Anti-spam controls, rate limiting, duplicate listing detection
    strategy, and suspicious activity flags.
-   Basic fraud-risk signals should support human review; do not claim
    automated fraud detection is perfect.
-   Prohibited goods/services and category-specific rules must be
    configurable and documented.
-   Audit log for privileged/admin actions.
-   Secure handling of uploaded files and untrusted user-generated
    content.
-   Define which content is automatically published versus reviewed
    before publication, with a recommended MVP policy.

## 10. Admin dashboard (Next.js)

Specify protected areas and roles for: - Overview and operational
metrics - Listings and moderation queue - Users and account status -
Categories, subcategories and dynamic fields - Reports and appeals -
Promotions, packages and payment records - Notification templates and
delivery status - Video processing/moderation status - Feature flags and
platform settings - Audit logs - Support tools with least-privilege
access

Define RBAC permissions, MFA recommendation for administrators, secure
session handling, audit events, filtering, pagination, bulk-action
safeguards, confirmation for destructive actions, and export
restrictions. The admin dashboard must call the backend API; it must not
connect directly to the production database from the browser.

## 11. Analytics and observability

-   Core product events: search, listing view, contact action, favorite,
    publish attempt, successful publication, report, promotion purchase.
-   Define events without unnecessarily collecting personal data.
-   Request IDs/correlation IDs, structured logs, metrics,
    health/readiness endpoints, error tracking and alerting.
-   Operational dashboards for API errors/latency, database health,
    queue backlog, upload failures, payment webhook failures and
    notification failures.
-   Data retention and access restrictions for logs.
-   No secrets, passwords, access tokens, full payment data or
    unnecessary personal information in logs.

------------------------------------------------------------------------

# PART C --- TECHNICAL CONSTRAINTS AND ARCHITECTURE EXPECTATIONS

Do not start coding in Phase 1. First evaluate and recommend a coherent
stack.

Consider the following default direction, but compare alternatives
before finalizing: - Flutter for Android/iOS. - Next.js for the admin
dashboard. - Backend API in a language/framework suited to the team, VPS
deployment and maintainability. Evaluate at least two reasonable backend
options (for example NestJS/TypeScript and Laravel/PHP, or another
justified option) and recommend one. Do not select a stack just because
it is fashionable. - PostgreSQL as the source of truth. - Redis only if
justified for caching, rate limiting, queues or ephemeral
coordination. - Background worker/queue for media processing callbacks,
notifications, expiration jobs and payment reconciliation. -
S3-compatible object storage for images and general uploads; managed
video service for video if cost/requirements support it. - FCM for push
notifications. - Docker and Docker Compose for repeatable
development/deployment if appropriate. - Reverse proxy such as Nginx or
Caddy, TLS, environment-based configuration and automated backups. - CI
pipeline for linting, tests, migrations checks and deployment. -
Separate development, staging and production configuration.

Architecture must cover: 1. Context diagram and system boundary. 2.
Container/component diagram. 3. Module boundaries and responsibilities.
4. Key request/data flows. 5. Trust boundaries and threat model. 6.
External dependencies and failure modes. 7. Deployment topology on an
initial VPS. 8. Scale-up path based on measurable bottlenecks. 9.
Backup, restore, disaster recovery and migration approach. 10.
Environments, secrets and release strategy.

Do not recommend Kubernetes or a large microservices estate for MVP
without a concrete, evidence-based reason.

------------------------------------------------------------------------

# PART D --- REQUIRED PHASE 1 DELIVERABLES

Create a `/docs` directory in the project or deliver equivalent
standalone files. Use clear English technical documentation, with Arabic
product-language considerations documented where useful. Use Markdown
and Mermaid diagrams where appropriate. Do not modify application code
or build backend endpoints in this phase.

Produce the following files:

## `docs/00-executive-summary.md`

-   Product vision, users, value proposition and scope.
-   Core user journeys.
-   MVP versus later releases.
-   Main architectural recommendation.
-   Top risks and decisions requiring owner approval.

## `docs/01-srs.md`

Write a structured Software Requirements Specification including: -
Purpose, scope, definitions, references and stakeholders. - User classes
and permission assumptions. - Functional requirements with unique IDs,
e.g. `FR-AUTH-001`. - Non-functional requirements with unique IDs,
e.g. `NFR-SEC-001`. - Business rules with IDs, e.g. `BR-LISTING-001`. -
User stories and acceptance criteria. - Use cases and
preconditions/postconditions. - Listing state machine and transition
rules. - Error cases, validation, accessibility, localization and RTL
requirements. - Assumptions, dependencies, out-of-scope items and
unresolved questions. - A traceability matrix connecting requirements to
API modules, data entities, tests and dashboard areas.

Requirements must be testable and unambiguous. Avoid vague phrases such
as "fast," "secure," or "user-friendly" without measurable or verifiable
criteria.

## `docs/02-mvp-scope-and-roadmap.md`

-   MVP feature matrix.
-   Phase 2 and later features.
-   Priorities with rationale.
-   Dependencies and implementation order.
-   Definition of Done for each major milestone.
-   Main delivery risks and scope-control rules.

## `docs/03-system-architecture.md`

-   Recommended stack with alternatives and trade-offs.
-   Mermaid system context diagram.
-   Mermaid container/component diagram.
-   Module boundaries and dependency rules.
-   API request flow, publishing/upload flow, payment flow and
    notification flow.
-   Background jobs and failure/retry behavior.
-   Initial VPS deployment and future scale-up.
-   Availability, recovery, backup and restore strategy.
-   Architecture Decision Records (ADRs) for major choices.

## `docs/04-data-model.md`

-   Entity relationship diagram in Mermaid.
-   Entity descriptions and relationships.
-   Candidate tables, fields, types, primary/foreign keys, constraints
    and indexes.
-   Unique constraints and soft-delete/retention approach.
-   Listing category-specific attribute strategy with examples.
-   Search indexing and pagination strategy.
-   Data ownership, privacy classification and retention notes.
-   Migration and seed-data strategy.
-   Identify data that must never be public.

At minimum, assess entities for users, sessions/refresh tokens if
applicable, roles/permissions, categories, category fields/options,
listings, listing attributes, listing media, favorites, saved searches,
conversations, participants, messages, reports, moderation actions,
notifications, devices, payment attempts/transactions, promotion
packages/entitlements, video processing state, audit logs and feature
flags. Do not create a table merely to match this list if the data model
has a better justified structure.

## `docs/05-api-specification.md`

-   API conventions, base path and versioning.
-   Authentication and authorization scheme.
-   Request IDs, pagination, filtering, sorting and idempotency
    conventions.
-   Standard success/error response envelope and error codes.
-   Endpoint catalog grouped by module.
-   For every MVP endpoint: method, path, purpose, auth/role, request
    schema, response schema, validation, possible errors, rate limit
    notes and side effects.
-   OpenAPI 3.1 YAML file at `docs/openapi.yaml` covering MVP endpoints
    with reusable schemas and security schemes.
-   Upload URL creation/finalization and provider webhook endpoints.
-   Payment webhook endpoints with verification and idempotency.
-   Admin endpoints and permission requirements.
-   Examples must be internally consistent with the data model.
-   Clearly distinguish synchronous API responses from asynchronous
    processing results.

## `docs/06-security-and-privacy.md`

-   Threat model and trust boundaries.
-   Authentication/session security.
-   Authorization rules and object-level access controls.
-   Input validation, output encoding and file-upload security.
-   Rate limiting, anti-spam and abuse controls.
-   Secrets management and encryption in transit/at rest.
-   Admin security and audit requirements.
-   Webhook verification and replay protection.
-   Privacy/data retention/deletion and user consent.
-   Backup security and incident response.
-   Security test checklist.
-   Applicable Egyptian legal/privacy requirements and
    app-store/provider obligations must be identified as items for
    qualified review, not presented as legal advice.

## `docs/07-deployment-and-operations.md`

-   Development/staging/production environments.
-   Docker/deployment approach.
-   TLS, DNS, reverse proxy and firewall rules.
-   Environment variable inventory with example names only; never put
    real secrets in files.
-   Database migrations, backup schedule, offsite backup and tested
    restore procedure.
-   Logging, monitoring, alerting and health checks.
-   CI/CD pipeline outline and rollback strategy.
-   Initial resource sizing assumptions and scale-up signals.
-   Operational runbooks for API outage, database issue, failed backup,
    stuck media, payment webhook failure and notification outage.

## `docs/08-testing-strategy.md`

-   Unit, integration, API contract, database, security, load, mobile
    integration and admin UI tests.
-   Test data and environment strategy.
-   Critical acceptance tests.
-   Load scenarios based on explicit assumptions, not invented
    guarantees.
-   Payment/webhook idempotency tests.
-   Authorization and cross-user data isolation tests.
-   Listing lifecycle and category validation tests.
-   Upload/video moderation tests.
-   Release gates and quality criteria.

## `docs/09-open-decisions.md`

-   A concise decision log.
-   Each decision: question, recommended default, alternatives,
    consequences, owner approval required, and whether it blocks
    implementation.
-   Group questions into **Blocking**, **Important but non-blocking**,
    and **Can be deferred**.
-   Do not ask dozens of questions if a safe, clearly labeled assumption
    can move the design forward.

## `docs/10-backend-implementation-plan.md`

-   Proposed backend directory structure.
-   Module-by-module implementation order.
-   Database migration order.
-   API and service dependencies.
-   Background worker/queue plan.
-   Test plan per module.
-   Definition of Done and review checkpoint for each milestone.
-   A checklist that can be used later to verify the implementation
    against SRS and OpenAPI.

## `docs/11-architecture-decisions/`

Create ADR files for important decisions such as: - Backend framework
and language - Modular monolith versus microservices - Authentication
approach - Category-specific attribute storage - Search approach - Media
storage and video provider - Queue/worker technology - Deployment and
backup approach - Payments and mobile store policy review

## `docs/12-review-checklist.md`

Provide a practical review checklist for the project owner to approve or
reject: - Scope and MVP boundaries - Main user journeys - Category
model - Listing lifecycle - Authentication and contact model - Chat
decision - Video limits and provider - Payments and monetization - Roles
and admin access - Security/privacy - Hosting/cost assumptions - Data
model - API contract - Testing/release plan

------------------------------------------------------------------------

# PART E --- REQUIRED QUALITY AND REVIEW PROCESS

In Phase 1:

1.  Inspect the existing repository before making assumptions about its
    structure. If it is empty, state that.
2.  Ask a small number of high-impact clarifying questions only if an
    answer materially changes the design. Otherwise record a recommended
    assumption in `docs/09-open-decisions.md`.
3.  Produce all Phase 1 documents listed above.
4.  Cross-check the SRS, ERD, API catalog, OpenAPI, security plan and
    implementation plan against each other.
5.  Check that every MVP functional requirement has at least one
    acceptance criterion and is traceable to relevant data/API/test
    coverage.
6.  Check that every endpoint has a clear authorization rule and error
    behavior.
7.  Check that payment confirmation is server-verified and idempotent.
8.  Check that upload authorization prevents users from attaching
    another user's media.
9.  Check that admin endpoints have explicit permissions and audit
    requirements.
10. Check that the video feature remains optional and that normal
    listings work without video.
11. Identify risks and unsupported assumptions instead of hiding them.
12. Provide a concise final summary of created documents, key
    recommendations, unresolved decisions and the exact approvals needed
    to start backend implementation.

**Strict Phase 1 boundary:** Do not implement the backend. Do not create
controllers, routes, database migrations, authentication code,
production configuration or deploy services. You may create
documentation files only. Do not delete or overwrite existing user work.
If documentation conflicts with the repository, record the conflict and
ask before changing existing implementation.

## Documentation acceptance criteria

Phase 1 is complete only when: - All required documents exist and have
meaningful content. - Requirements use unique IDs. - MVP scope is
explicit. - The ERD and table definitions agree. - API endpoint
definitions and OpenAPI agree. - Security and authorization are
specified per relevant module. - State machines and business rules are
testable. - Major technical choices have documented trade-offs. - Open
decisions are visible and prioritized. - No secrets or real credentials
are included. - The owner can review and approve the design before any
backend implementation begins.

At the end of Phase 1, **stop and wait for my explicit approval**. Do
not interpret silence, a request for explanation, or a request to edit
documentation as approval to start coding.

------------------------------------------------------------------------

# PART F --- PHASE 2 PROMPT (USE ONLY AFTER APPROVING PHASE 1)

When I explicitly say **"Phase 1 approved --- begin backend
implementation"**, follow this prompt:

You are now the senior backend implementation engineer for the approved
classifieds marketplace design.

## Mandatory preflight

1.  Read every relevant document in `/docs`, especially the SRS,
    architecture, data model, OpenAPI, security plan, testing strategy
    and implementation plan.
2.  Inspect the current repository and existing code before editing.
3.  Compare the implementation plan to the approved documents. Do not
    silently alter requirements or architecture.
4.  Summarize the approved stack, modules, database conventions, auth
    model, API contract and first implementation milestone.
5.  If a blocking decision remains unresolved, stop and ask me. Do not
    invent credentials or provider accounts.
6.  Confirm that no secrets are committed and that `.env.example`
    contains placeholders only.
7.  Create or update a traceability checklist so implemented
    requirements can be tracked.

## Implementation rules

-   Implement incrementally in the documented order. Do not generate the
    entire backend in one unreviewable code dump.
-   Begin with repository scaffolding, configuration, health endpoints,
    logging, validation, error handling, database connection, migrations
    and test infrastructure as appropriate for the approved stack.
-   Then implement modules in the order defined by
    `docs/10-backend-implementation-plan.md`.
-   Use migrations for all schema changes; do not rely on manual
    production database edits.
-   Follow the approved module boundaries and dependency rules.
-   Validate input at the API boundary and enforce authorization in
    backend services, not only in the UI.
-   Use transactions where multiple related database changes must
    succeed or fail together.
-   Use pagination and suitable indexes for list/search endpoints.
-   Use consistent response and error formats from OpenAPI.
-   Use secure password/session handling if password-based auth is
    approved. Never log passwords, tokens, secrets or sensitive message
    contents.
-   Implement rate limits for sensitive endpoints and enforce
    object-level authorization.
-   Use signed, short-lived upload URLs or the approved equivalent.
    Verify upload ownership, file type, size and processing state.
-   Verify external webhooks cryptographically according to provider
    documentation; enforce idempotency and replay protection.
-   Do not mark payments successful from a browser redirect alone.
-   Use background jobs for work that should not block API responses,
    with retries, idempotency and dead-letter/failed-job visibility
    where supported.
-   Make external services injectable/configurable and testable. Use
    mock adapters in tests.
-   Do not claim a real payment, WhatsApp, email, push, or video
    integration is live unless its credentials and provider
    configuration are actually present and tested.
-   Provide seed data for local development only; never seed production
    with fake administrator credentials.
-   Use least-privilege database and service credentials.
-   Include unit and integration tests for each implemented module,
    especially authorization and cross-user isolation.
-   Run formatting, linting, type checks, migrations checks and tests
    available in the repository. Report exactly what ran and what
    failed; do not claim tests passed if they were not run.
-   Update the documentation and OpenAPI whenever an approved
    implementation detail changes, and ask for approval for material
    scope or architecture changes.
-   Preserve existing user work; do not overwrite or delete files
    without inspecting them first.
-   Do not deploy to production, run destructive database operations, or
    spend money on external services without my explicit approval.

## Milestone workflow

For each milestone: 1. State the requirements being implemented by ID.
2. List the files/modules you plan to create or modify. 3. Implement
only that milestone. 4. Run the relevant checks and tests. 5. Summarize
changes, tests and remaining gaps. 6. Compare behavior against
acceptance criteria. 7. Stop at the documented review checkpoint and ask
for approval before proceeding to the next major milestone when the plan
specifies a checkpoint.

## Initial backend milestone

Start with the smallest foundational milestone defined in the approved
implementation plan. Usually this includes project setup, configuration
validation, structured logging, health/readiness endpoints, standard
error handling, database connectivity, migration tooling and test setup.
Do not proceed to all business modules until this foundation is reviewed
and passing its checks.

**Final rule:** The approved SRS and API specification are the source of
truth. If code, documentation, or assumptions conflict, stop, explain
the conflict and request a decision rather than quietly choosing one.
