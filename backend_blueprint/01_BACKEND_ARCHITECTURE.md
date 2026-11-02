# Deal One — Comprehensive Backend Architecture Document

## 1. System Architecture Overview

Deal One is architected as an enterprise-grade **Modular Monolith** engineered for high concurrency, low latency, robust data isolation, and smooth maintainability. The system serves multiple client applications (Flutter Android/iOS apps for consumers and merchants, and an administrative web control portal for moderation and operations) from a unified, strictly modular backend.

---

### 1.1 Architectural Pattern: The Modular Monolith

Rather than introducing distributed microservice overhead during the launch phase, Deal One enforces domain separation at compile time and runtime within a single monolithic codebase.

#### Rules of the Modular Monolith:
1. **Explicit Module Boundaries:** The codebase is partitioned into distinct Bounded Contexts.
2. **Encapsulated Data Access:** No module may directly query the database tables belonging to another module. All cross-domain operations must execute via designated Module Public Services / Domain Interfaces.
3. **No Circular Dependencies:** Module dependencies follow a strict directed acyclic graph (DAG).
4. **Shared Infrastructure:** Database connections, Redis caches, object storage adapters, and logging pipelines are provided as shared core infrastructure.
5. **Microservices Ready (Extractability):** In the event of extreme scale, any module (such as Search or Real-time Chat) can be carved out into an independent service without refactoring core business logic.

---

### 1.2 High-Level System Architecture Diagram

```mermaid
graph TD
    subgraph Clients["Client Tier"]
        CustomerApp["Flutter Mobile App<br/>(Consumer Mode)"]
        MerchantApp["Flutter Mobile App<br/>(Merchant Mode)"]
        AdminWeb["Admin Control Portal<br/>(Web Dashboard)"]
    end

    subgraph Edge["Edge & Security Layer"]
        CF["Cloudflare Edge Network<br/>(WAF, DDoS, Turnstile, CDN)"]
        Nginx["Nginx Reverse Proxy<br/>(SSL Termination, Rate Limiting)"]
    end

    subgraph Backend["NestJS + Fastify Modular Monolith (Node.js 20 LTS)"]
        subgraph CoreModules["Core Domain Modules"]
            AuthMod["Auth & Identity Module"]
            AccountMod["Accounts & RBAC Module"]
            GeoMod["Location & PostGIS Module"]
            CatMod["Categories & Dynamic Schema"]
            ListMod["Listings Core Module"]
            MediaMod["Media & Storage Module"]
            SearchMod["Search & Indexing Module"]
            ChatMod["Chat & WebSocket Module"]
            ModLogMod["Moderation & Audit Module"]
            NotifMod["Notifications Module"]
            QuotaMod["Quotas & Settings Module"]
        end
        Worker["BullMQ Worker Service<br/>(Thumbnailing, Expiration, FCM)"]
    end

    subgraph Data["Persistence & Caching Tier"]
        Postgres[(PostgreSQL 16 + PostGIS<br/>24 Relational Tables)]
        Redis[(Redis 7 Cluster / Sentinel<br/>Sessions, Pub/Sub, Cairo Quotas)]
        R2[(Cloudflare R2 Storage<br/>Presigned Image Bucket)]
    end

    subgraph External["External Services"]
        FCM["Firebase Cloud Messaging"]
        TurnstileAPI["Cloudflare Turnstile Verification API"]
    end

    CustomerApp -->|HTTPS / WSS| CF
    MerchantApp -->|HTTPS / WSS| CF
    AdminWeb -->|HTTPS| CF

    CF --> Nginx
    Nginx --> AuthMod
    Nginx --> ListMod
    Nginx --> SearchMod
    Nginx --> ChatMod
    Nginx --> ModLogMod
    Nginx --> AccountMod

    AuthMod --> Postgres
    AuthMod --> Redis
    AuthMod --> TurnstileAPI

    AccountMod --> Postgres
    ListMod --> Postgres
    ListMod --> QuotaMod
    SearchMod --> Postgres
    SearchMod --> Redis

    ChatMod --> Postgres
    ChatMod --> Redis
    MediaMod --> R2

    Worker --> Postgres
    Worker --> Redis
    Worker --> FCM
    Worker --> R2
```

---

### 1.3 Container & Service Architecture Diagram

```mermaid
graph TB
    subgraph Host["Production Server / Kubernetes Node"]
        subgraph IngressPod["Ingress & Edge Container"]
            NGINX_C["Nginx Container<br/>Port: 80 / 443<br/>Worker Processes: auto"]
        end

        subgraph AppPod["Application Containers (Stateless Clustered)"]
            APP_1["NestJS Node Worker 1<br/>Port: 3001 (Fastify)"]
            APP_2["NestJS Node Worker 2<br/>Port: 3002 (Fastify)"]
            APP_3["NestJS Node Worker 3<br/>Port: 3003 (Fastify)"]
            APP_4["NestJS Node Worker 4<br/>Port: 3004 (Fastify)"]
        end

        subgraph BackgroundPod["Asynchronous Worker Containers"]
            WORKER_1["BullMQ Consumer Container<br/>Concurrency: 10<br/>Tasks: Video/Img/Notif"]
        end

        subgraph DataPod["Persistence Containers (Stateful)"]
            PG_C["PostgreSQL 16 + PostGIS Container<br/>Shared Buffers: 2GB<br/>Work Mem: 32MB"]
            REDIS_C["Redis 7 Container<br/>MaxMemory: 1.5GB<br/>Policy: volatile-lru"]
        end
    end

    NGINX_C -->|Load Balance Round-Robin| APP_1
    NGINX_C -->|Load Balance Round-Robin| APP_2
    NGINX_C -->|Load Balance Round-Robin| APP_3
    NGINX_C -->|Load Balance Round-Robin| APP_4

    APP_1 --> PG_C
    APP_2 --> PG_C
    APP_3 --> PG_C
    APP_4 --> PG_C

    APP_1 --> REDIS_C
    APP_2 --> REDIS_C
    APP_3 --> REDIS_C
    APP_4 --> REDIS_C

    WORKER_1 --> PG_C
    WORKER_1 --> REDIS_C
```

---

### 1.4 Backend Module Dependency Architecture

```mermaid
graph LR
    subgraph Foundation["Shared Foundation (Infrastructure)"]
        PrismaService["Prisma ORM Service"]
        RedisService["Redis Cache & Pub/Sub"]
        ConfigService["Environment & Secrets"]
        LoggerService["Pino Structured Logger"]
    end

    subgraph CoreDomains["Domain Modules"]
        Auth["Auth & Identity"]
        Accounts["Accounts & RBAC"]
        Categories["Categories & Taxonomy"]
        Locations["Locations & PostGIS"]
        Quotas["Daily Quota Engine"]
        Media["Media Management"]
        Listings["Listings Core"]
        Moderation["Moderation & Audit"]
        Search["Search & Filtering"]
        Chat["In-App Chat Engine"]
        Notifications["FCM Notifications"]
    end

    Auth --> Accounts
    Accounts --> Quotas
    Listings --> Accounts
    Listings --> Categories
    Listings --> Locations
    Listings --> Media
    Listings --> Quotas
    Moderation --> Listings
    Moderation --> Accounts
    Search --> Listings
    Search --> Locations
    Search --> Categories
    Chat --> Listings
    Chat --> Accounts
    Chat --> Quotas
    Notifications --> Accounts

    Auth -.-> PrismaService
    Listings -.-> PrismaService
    Search -.-> PrismaService
    Quotas -.-> RedisService
    Chat -.-> RedisService
```

---

### 1.5 Detailed Request Lifecycle

```mermaid
sequenceDiagram
    autonumber
    actor Client as Flutter App / Admin Web
    participant CF as Cloudflare WAF / Turnstile
    participant Nginx as Nginx Proxy
    participant Fastify as Fastify Engine
    participant Guard as Global Auth & RBAC Guards
    participant Interceptor as Logging & Trace Interceptor
    participant Pipe as Validation Pipe (Zod / class-validator)
    participant Controller as Domain Controller
    participant Service as Business Domain Service
    participant Quota as Redis Quota Guard
    participant DB as PostgreSQL 16 (PostGIS)
    participant Queue as BullMQ Background Queue

    Client->>CF: HTTPS Request (Bearer JWT, X-Request-ID, Device-Info)
    CF->>CF: Inspect WAF rules, TLS termination, Turnstile token
    CF->>Nginx: Forward Request + Client Real IP
    Nginx->>Fastify: Proxy Pass to App Instance
    Fastify->>Interceptor: Inject Correlation ID (X-Trace-ID), Start Latency Timer
    Fastify->>Guard: Validate Access Token (JWT) & Account Permissions
    alt Invalid Token or Insufficient Role
        Guard-->>Client: 401 Unauthorized / 403 Forbidden Response
    end
    Fastify->>Pipe: Validate Request Body & Query DTO
    alt Validation Failed
        Pipe-->>Client: 422 Unprocessable Entity (Field Error Map)
    end
    Fastify->>Controller: Dispatch to Route Handler
    Controller->>Service: Call Business Logic Method
    Service->>Quota: Check & Deduct Daily Quota (Redis)
    alt Daily Quota Exceeded
        Quota-->>Client: 429 Too Many Requests (Quota limit reached)
    end
    Service->>DB: Execute Parameterized SQL / Prisma Query
    DB-->>Service: Return Result Set
    opt Asynchronous Side Effects
        Service->>Queue: Push Job (Send Push Notification, Audit Log)
    end
    Service-->>Controller: Return Domain Entity / Result DTO
    Controller-->>Fastify: Return Standard JSON Envelope
    Fastify->>Interceptor: Log Structured Access Event (Pino)
    Fastify-->>Client: 200 OK Response (Data + Meta)
```

---

### 1.6 Authentication & Token Rotation Flow

```mermaid
sequenceDiagram
    autonumber
    actor User as Mobile User
    participant App as Flutter Mobile Client
    participant Auth as Auth Module (/api/v1/auth)
    participant Redis as Redis (Revocation & Blacklist)
    participant DB as PostgreSQL (Users & Sessions)

    Note over User,DB: Phase 1: Authentication via OTP
    User->>App: Enter Mobile (+2010xxxxxxxx) + Solve Turnstile
    App->>Auth: POST /auth/otp/send {phone, turnstile_token}
    Auth->>Redis: Check Rate Limit (Max 3 OTP / 15 min per IP/Phone)
    Auth->>DB: Store Hashed OTP (Argon2id, Exp: 5 min)
    Auth-->>App: 200 OK {message: "OTP sent"}

    User->>App: Enter 6-digit OTP code
    App->>Auth: POST /auth/otp/verify {phone, code}
    Auth->>DB: Validate code hash & check expiration
    Auth->>DB: Upsert User Profile & Create UserSession record
    Auth->>Auth: Mint Access Token (JWT, 15 min, RS256/HS256)
    Auth->>Auth: Mint Refresh Token (UUID v4 cryptographically secure, 30 days)
    Auth->>DB: Store hashed Refresh Token in user_sessions
    Auth-->>App: 200 OK {access_token, refresh_token, user, accounts}

    Note over User,DB: Phase 2: Silent Refresh Token Rotation
    App->>Auth: POST /auth/token/refresh {refresh_token}
    Auth->>DB: Lookup session by token hash
    alt Token Revoked or Already Reused (Theft Detected!)
        Auth->>DB: Invalidate ALL sessions for this user!
        Auth-->>App: 401 Unauthorized (Session Compromised)
    else Token Valid
        Auth->>DB: Invalidate old Refresh Token
        Auth->>Auth: Generate new Access Token + new Refresh Token
        Auth->>DB: Save new Refresh Token hash
        Auth-->>App: 200 OK {access_token, refresh_token}
    end
```

---

### 1.7 Authorization & Multi-Tenant RBAC Flow

```mermaid
sequenceDiagram
    autonumber
    actor Lister as Account Lister (Agent)
    participant App as Mobile App
    participant Guard as RBAC & Tenancy Guard
    participant DB as PostgreSQL (account_members)
    participant Controller as Listing Controller

    Lister->>App: Create Listing in "Real Estate"
    App->>Guard: POST /api/v1/listings<br/>Headers: Authorization: Bearer <token><br/>X-Account-ID: <active_account_uuid>
    Guard->>Guard: Extract authenticated userId from JWT
    Guard->>DB: Query account_members WHERE user_id = :u AND account_id = :a
    alt User is not a member of active_account_uuid
        Guard-->>App: 403 Forbidden (Tenancy Violation - Cross-Tenant Access Denied)
    end
    Guard->>Guard: Verify Member Role against Route Permission
    Note over Guard: Required: "lister", "manager", or "owner"<br/>Found: "lister" (Allowed!)
    Guard->>Controller: Forward with TenantContext(userId, accountId, role)
    Controller->>DB: Insert Listing with account_id = active_account_uuid
    DB-->>Controller: Listing Created
    Controller-->>App: 201 Created {id, moderation_status: "draft"}
```

---

### 1.8 Background Job & Worker Architecture Flow

```mermaid
sequenceDiagram
    autonumber
    participant App as Backend API Server
    participant RedisQueue as BullMQ (Redis Queues)
    participant Worker as BullMQ Worker Service
    participant S3 as Cloudflare R2 Storage
    participant FCM as Firebase Cloud Messaging
    participant DB as PostgreSQL Database

    Note over App,DB: Asynchronous Task Offloading
    App->>RedisQueue: enqueue("process-media", {listingId, storageKey})
    App->>RedisQueue: enqueue("dispatch-push", {userId, title, body, payload})
    App->>RedisQueue: enqueue("audit-event", {actorId, action, diff})
    App-->>App: HTTP Request completed without delay!

    Worker->>RedisQueue: Pop job from "process-media" queue
    Worker->>S3: Download original high-res image
    Worker->>Worker: Validate magic bytes, strip EXIF GPS metadata, generate WebP thumbnails
    Worker->>S3: Upload optimized WebP thumbnails
    Worker->>DB: Update media record status = "READY"

    Worker->>RedisQueue: Pop job from "dispatch-push" queue
    Worker->>DB: Fetch active FCM device tokens for userId
    Worker->>FCM: Send Multicast Push Notification
    FCM-->>Worker: Status: Success (Invalidate dead tokens in DB)
```

---

### 1.9 Operational Notification Flow

```mermaid
graph TD
    Trigger["System Event Trigger<br/>(Listing Approved / Rejected / New Chat)"] --> Dispatcher["Notification Dispatcher Service"]
    Dispatcher --> InAppDB["Insert into `notifications` Table<br/>(In-App Notification Center)"]
    Dispatcher --> Queue["Push to BullMQ `push-notifications` Queue"]
    Queue --> Worker["Notification Worker"]
    Worker --> DeviceLookup["Lookup `user_devices` for active FCM tokens"]
    DeviceLookup --> FCM["Firebase Cloud Messaging (HTTP v1 API)"]
    FCM --> MobileDevice["iOS (APNs) & Android Devices"]
```

---

### 1.10 Deployment & Infrastructure Topology

```mermaid
graph TD
    Internet((Public Internet)) --> CF[Cloudflare DNS, WAF & DDoS Shield]

    subgraph ProductionVPC["Production VPC (Private Network 10.0.0.0/16)"]
        subgraph DMZ["Public Subnet (DMZ 10.0.1.0/24)"]
            NginxProxy["Nginx Load Balancer / Reverse Proxy<br/>IP: 10.0.1.10"]
        end

        subgraph AppSubnet["Application Subnet (Private 10.0.2.0/24)"]
            AppNode1["App Instance 1 (NestJS + Fastify)<br/>IP: 10.0.2.11"]
            AppNode2["App Instance 2 (NestJS + Fastify)<br/>IP: 10.0.2.12"]
            WorkerNode["Background Worker (BullMQ)<br/>IP: 10.0.2.20"]
        end

        subgraph DataSubnet["Database Subnet (Isolated 10.0.3.0/24)"]
            PG_Primary["PostgreSQL 16 Primary (PostGIS)<br/>IP: 10.0.3.10 (Read/Write)"]
            PG_Replica["PostgreSQL 16 Standby Replica<br/>IP: 10.0.3.11 (Read Only - Future)"]
            RedisCluster["Redis 7 Instance (Sentinel Protected)<br/>IP: 10.0.3.20"]
        end
    end

    CF -->|SSL Full Strict| NginxProxy
    NginxProxy --> AppNode1
    NginxProxy --> AppNode2

    AppNode1 --> PG_Primary
    AppNode2 --> PG_Primary
    AppNode1 --> RedisCluster
    AppNode2 --> RedisCluster

    WorkerNode --> PG_Primary
    WorkerNode --> RedisCluster

    PG_Primary -.->|Streaming Replication| PG_Replica
```

---

## 2. Key Architecture Decisions Summary

| Decision ID | Topic | Selected Choice | Rationale & Trade-offs |
|---|---|---|---|
| **ADR-001** | Platform Strategy | Hybrid Multi-Category Platform | Balances common foundation with category-specific business rules. Avoids building separate apps while preventing rigid unified tables. |
| **ADR-002** | Core System Design | Shared Core Architecture | Identity, auth, multi-tenant accounts, media, and chat are standardized across all categories, eliminating duplicate systems. |
| **ADR-003** | Data Modeling | Hybrid Relational + JSONB (GIN) | High-performance relational core tables for standard search keys alongside indexed JSONB attributes for custom category fields. |
| **ADR-004** | Trust & Safety | Tiered Account Verification | Mandatory official document audit per account type (`individual`, `company`, `factory`, `office`, `store`) before public listing visibility. |
| **ADR-005** | Identity Model | Multi-Tenant Independent Accounts | Separates personal user identity from commercial entities. Enables multiple team members and multi-business ownership. |
| **ADR-006** | Spatial Privacy | Two-Tier Geographic Coordinates | Exact coordinates (`physical_lat/lng`) are stored securely for PostGIS distance sorting; fuzzed coordinates (`display_lat/lng`) are served publicly. |
| **ADR-007** | Listing State | 3 Orthogonal Status Axes | Decouples moderation (`draft/pending/approved/rejected`), publication (`published/hidden/archived`), and stock (`available/reserved/sold`). |
| **ADR-008** | Transaction Scope | Strict V1 Contact-Only Scope | Excludes online payment gateways and checkout in V1 to maximize market listing liquidity and reduce launch complexity. |
| **ADR-012** | Backend Pattern | Modular Monolith | Single codebase with strict compile-time boundaries. Lowers cloud infrastructure costs and eliminates distributed transaction failures. |
| **ADR-013** | Tech Stack | NestJS + Fastify + PostgreSQL + Redis | High I/O performance (Fastify), enterprise architectural discipline (NestJS), spatial capabilities (PostGIS), and rapid caching (Redis). |

---

## 3. Scalability Strategy & Load Capacity Engineering

The Deal One backend is engineered for stateless horizontal scaling.

### 3.1 Engineering Capacity Targets

| Concurrency Tier | Target Concurrent Users (CCU) | Expected Requests/sec (RPS) | Infrastructure Footprint | Key Potential Bottlenecks & Mitigations |
|---|---|---|---|---|
| **Tier 1 (Launch)** | 100 CCU | 50 – 150 RPS | 1x App Server (4 vCPU, 8GB RAM), 1x DB (2 vCPU, 4GB RAM), Redis (2GB) | Unindexed DB queries. *Mitigation:* Ensure strict composite B-tree & GIST indexes on all search queries. |
| **Tier 2 (Growth)** | 1,000 CCU | 500 – 1,200 RPS | 2x App Servers (4 vCPU each), 1x DB (4 vCPU, 16GB RAM), Redis (4GB) | DB connection pool exhaustion. *Mitigation:* PgBouncer connection pooler; keep pool size at 25-30 per app instance. |
| **Tier 3 (Scale)** | 5,000 CCU | 2,500 – 5,000 RPS | 4x App Servers behind Nginx round-robin, DB Primary (8 vCPU, 32GB RAM) + Read Replica | High PostGIS distance calculation overhead. *Mitigation:* Redis caching of district centroids & popular category listings (TTL: 60s). |
| **Tier 4 (Peak)** | 10,000 CCU | 5,000 – 12,000 RPS | 8x Clustered App Nodes, Dedicated DB Primary (16 vCPU, 64GB RAM) + 2 Read Replicas, Redis Cluster | Redis memory saturation for daily quotas & chat Pub/Sub. *Mitigation:* Sharded Redis; offload historical chat logs to cold storage. |

### 3.2 Core Architectural Principles for High Concurrency
1. **100% Stateless Application Instances:** No local memory state or file persistence exists on API nodes. Sessions are verified via cryptographically signed JWTs and checked against Redis blacklists. Any app node can handle any request.
2. **Database Connection Pooling (PgBouncer / Prisma Tuning):** Each NestJS instance maintains a tuned connection pool limit (max 20–25 connections) to prevent saturating PostgreSQL's backend process table.
3. **Multi-Level Caching:**
   - *HTTP Layer:* Edge caching for immutable category taxonomies, governorates, and cities (Cache-Control: public, max-age=86400).
   - *Application Layer:* Redis cache for popular feed listings and seller account profiles (TTL: 60–180 seconds with cache eviction on listing modification).
   - *Database Layer:* PostgreSQL `shared_buffers` sized to 25% of RAM with query plans verified using `EXPLAIN ANALYZE`.
4. **Rate Limiting & Abuse Defense:** Redis sliding window rate limiters protect OTP generation (3 per 15 min), login attempts (5 per 15 min), and public search requests (60 per minute per IP).
