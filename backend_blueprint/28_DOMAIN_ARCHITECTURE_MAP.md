# Deal One — Domain Architecture & Bounded Contexts Map

**Document Reference:** `28_DOMAIN_ARCHITECTURE_MAP.md`  
**Architecture Version:** `1.0.0-ENTERPRISE-SIGN-OFF`  
**Sign-off Status:** APPROVED ARCHITECTURAL SPECIFICATION  
**Scope:** Complete Domain Map, Bounded Contexts, Entity Allocations, and Key Operational Flows  

---

## 1. Domain Bounded Contexts & Module Registry

Deal One is structured into **8 Bounded Contexts** adhering strictly to Domain-Driven Design (DDD) principles within a Modular Monolith.

```mermaid
graph TD
    subgraph IdentityContext["1. Identity & Auth Context"]
        Users["users"]
        Sessions["user_sessions"]
        Devices["user_devices"]
        Otps["otps"]
    end

    subgraph AccountContext["2. Multi-Tenant Accounts & RBAC Context"]
        Accounts["accounts"]
        Members["account_members"]
        Verifications["account_verifications"]
        Branches["branches"]
        ServiceAreas["service_areas"]
        Projects["projects"]
    end

    subgraph GeographyContext["3. Geography & Spatial Context"]
        Governorates["governorates"]
        Cities["cities"]
        Areas["areas (PostGIS Centroid)"]
    end

    subgraph CategoryContext["4. Categories & Taxonomy Context"]
        Categories["categories"]
        CategoryFields["category_fields"]
    end

    subgraph ListingContext["5. Listings & Content Context"]
        Listings["listings (3-Axis Status & Dual PostGIS)"]
        ListingMedia["listing_media"]
        Favorites["favorites"]
        Reports["reports"]
    end

    subgraph MessagingContext["6. Chat & Real-Time Context"]
        Conversations["conversations"]
        Messages["messages"]
    end

    subgraph GovernanceContext["7. Quotas, Platform & Notifications Context"]
        DailyQuotas["daily_quotas"]
        PlatformSettings["platform_settings"]
        Notifications["notifications"]
    end

    subgraph AdministrationContext["8. Staff, Moderation & Audit Context"]
        StaffRoles["staff_roles"]
        StaffUsers["staff_users"]
        ModerationLog["moderation_log"]
        AuditLog["audit_log"]
    end

    IdentityContext -->|identifies| AccountContext
    AccountContext -->|operates in| GeographyContext
    ListingContext -->|owned by| AccountContext
    ListingContext -->|classified by| CategoryContext
    ListingContext -->|located in| GeographyContext
    MessagingContext -->|discusses| ListingContext
    MessagingContext -->|involves| AccountContext
    GovernanceContext -->|limits & controls| AccountContext
    AdministrationContext -->|audits & reviews| ListingContext
    AdministrationContext -->|moderates| AccountContext
```

---

## 2. Table-to-Context Mapping Matrix (28 Relational Tables)

| # | Table Name | Bounded Context | Aggregate Root | Data Access Scope | Primary Index Type |
|---|---|---|---|---|---|
| 1 | `governorates` | Geography | Governorate | Shared Public Read | B-Tree |
| 2 | `cities` | Geography | Governorate | Shared Public Read | B-Tree |
| 3 | `areas` | Geography | Governorate | Spatial Search | GIST (`centroid`) |
| 4 | `users` | Identity & Auth | User | Private Identity | B-Tree |
| 5 | `user_sessions` | Identity & Auth | User | Auth Boundary | B-Tree (TTL) |
| 6 | `user_devices` | Identity & Auth | User | Push Target | B-Tree |
| 7 | `otps` | Identity & Auth | User | Transient Auth | B-Tree (Hash) |
| 8 | `accounts` | Multi-Tenant Accounts | Account | Tenant Root | B-Tree (Slug) |
| 9 | `account_members` | Multi-Tenant Accounts | Account | Tenant Security | B-Tree (Composite) |
| 10 | `account_verifications` | Multi-Tenant Accounts | Account | Compliance | B-Tree |
| 11 | `branches` | Multi-Tenant Accounts | Account | Tenant Spatial | GIST (`location`) |
| 12 | `service_areas` | Multi-Tenant Accounts | Account | Tenant Territory | B-Tree |
| 13 | `projects` | Multi-Tenant Accounts | Account | Real Estate Sub-Root | B-Tree |
| 14 | `categories` | Categories & Taxonomy | Category | Shared Taxonomy | B-Tree (Slug) |
| 15 | `category_fields` | Categories & Taxonomy | Category | Dynamic Attributes | B-Tree (Composite) |
| 16 | `listings` | Listings & Content | Listing | Public/Tenant Asset | GIST (`physical_loc`) + GIN (`attributes`) |
| 17 | `listing_media` | Listings & Content | Listing | Media Attachments | B-Tree |
| 18 | `favorites` | Listings & Content | User | User Engagement | B-Tree (Composite) |
| 19 | `reports` | Listings & Content | Listing / User | Trust & Safety | B-Tree |
| 20 | `conversations` | Chat & Real-Time | Conversation | Direct Messaging | B-Tree (Pair) |
| 21 | `messages` | Chat & Real-Time | Conversation | Message Stream | B-Tree (Chronological) |
| 22 | `notifications` | Governance | User | Notification Center | B-Tree (Chronological) |
| 23 | `daily_quotas` | Governance | Account | Quota Ledger | B-Tree (Date Composite) |
| 24 | `platform_settings` | Governance | PlatformSettings | Configuration Root | B-Tree (PK Key) |
| 25 | `staff_roles` | Administration | StaffUser | RBAC Permissions | B-Tree |
| 26 | `staff_users` | Administration | StaffUser | Admin Operator | B-Tree |
| 27 | `moderation_log` | Administration | StaffUser | Immutable Audit | B-Tree (Append Only) |
| 28 | `audit_log` | Administration | StaffUser | Immutable Audit | B-Tree (Append Only) |

---

## 3. End-to-End Operational Flow Architectures

### Flow 1: Multi-Tenant Account Onboarding & Verification

```mermaid
sequenceDiagram
    autonumber
    actor User as Verified User
    participant Gateway as API Gateway / Auth Guard
    participant AccountSvc as Account Service
    participant Policy as Account Membership Policy
    participant DB as PostgreSQL (Accounts)
    participant Outbox as Transactional Outbox
    participant Worker as BullMQ Notification Worker

    User->>Gateway: POST /api/v1/accounts (Type: company, Name, Documents)
    Gateway->>AccountSvc: createAccount(userId, payload)
    AccountSvc->>Policy: assertCanCreateAccount(userId, type)
    AccountSvc->>DB: INSERT into accounts (status: pending, owner: userId)
    AccountSvc->>DB: INSERT into account_members (role: owner, user: userId)
    AccountSvc->>DB: INSERT into account_verifications (doc_urls, status: pending)
    AccountSvc->>Outbox: INSERT outbox_events (ACCOUNT_VERIFICATION_SUBMITTED)
    AccountSvc-->>User: 201 Created (AccountContext: accountId, role: owner)
    
    Outbox->>Worker: Dispatch Event
    Worker->>Staff: Alert Moderation Team in Admin Portal
```

---

### Flow 2: Listing Submission, Category Strategy Validation & Orthogonal Lifecycle

```mermaid
sequenceDiagram
    autonumber
    actor Seller as Merchant / Seller
    participant API as Listings Controller
    participant TenantGuard as Account Tenant Guard
    participant QuotaEngine as Atomic Quota Engine (Redis)
    participant StrategyRegistry as Category Strategy Registry
    participant StateMachine as Listing Lifecycle State Machine
    participant DB as PostgreSQL 16 (PostGIS)

    Seller->>API: POST /api/v1/listings (Header: X-Account-ID, Category: automotive, GPS, Price)
    API->>TenantGuard: verifyAccountMembership(userId, accountId, 'lister')
    
    API->>QuotaEngine: consumeQuota(accountId, 'listings', accountType)
    alt Quota Exceeded
        QuotaEngine-->>API: { allowed: false, resetsAt: Cairo Midnight }
        API-->>Seller: 429 Too Many Requests (QUOTA_LIMIT_EXCEEDED)
    else Quota Approved
        API->>StrategyRegistry: getStrategy('automotive')
        StrategyRegistry->>StrategyRegistry: validateAttributes(mileage, transmission, fuel)
        StrategyRegistry->>StrategyRegistry: calculateExpirationDate(NOW()) -> NOW + 60 days
        
        API->>StateMachine: initializeListing()
        Note over StateMachine: Moderation: pending<br/>Publication: unpublished<br/>Availability: available
        
        API->>DB: INSERT into listings with ST_SetSRID(ST_MakePoint(lng, lat), 4326)
        API->>DB: INSERT outbox_events (LISTING_SUBMITTED_FOR_REVIEW)
        API-->>Seller: 201 Created (Listing pending review)
    end
```

---

### Flow 3: Geospatial Search & Discovery with Privacy Fuzzing

```mermaid
sequenceDiagram
    autonumber
    actor Buyer as Buyer Mobile App
    participant SearchAPI as Search Controller
    participant SpecBuilder as Search Query Specification Builder
    participant Cache as Redis Cache (Port 6379)
    participant PostGIS as PostgreSQL 16 + PostGIS

    Buyer->>SearchAPI: GET /api/v1/search?category=real-estate&lat=30.04&lng=31.23&radiusKm=10
    SearchAPI->>Cache: Check cached query hash
    alt Cache Hit
        Cache-->>SearchAPI: Cached Search Results
        SearchAPI-->>Buyer: 200 OK (Listings List with fuzzed display_location)
    else Cache Miss
        SearchAPI->>SpecBuilder: buildPostgisQuery(params)
        Note over SpecBuilder: WHERE ST_DWithin(physical_location, ST_MakePoint(31.23, 30.04)::geography, 10000)<br/>AND moderation_status = 'approved'<br/>AND publication_status = 'published'<br/>AND availability_status = 'available'
        SpecBuilder->>PostGIS: Execute parameterized PostGIS query via GIST Index
        PostGIS-->>SearchAPI: Rows with exact distance & display_location coordinates
        SearchAPI->>Cache: Cache result set (TTL: 120s)
        SearchAPI-->>Buyer: 200 OK (Listings with distanceKm, display_location)
    end
```

---

### Flow 4: Real-Time Chat Message Delivery with 3-Step Receipts

```mermaid
sequenceDiagram
    autonumber
    actor Buyer as Buyer User
    participant Gateway as WebSocket Gateway / Chat Controller
    participant ChatService as Chat Domain Service
    participant RedisQueue as Redis Queue (Port 6380)
    participant DB as PostgreSQL
    actor Seller as Seller Responder

    Buyer->>Gateway: SEND message (conversationId, body)
    Gateway->>ChatService: saveMessage(buyerId, conversationId, body)
    ChatService->>DB: INSERT into messages (status: sent, sent_at: NOW())
    Gateway-->>Buyer: ACK (messageId, status: sent)

    alt Seller is Connected on WebSocket
        Gateway->>Seller: WS PUSH (messageId, body, conversationId)
        Seller->>Gateway: ACK (messageId, status: delivered)
        Gateway->>DB: UPDATE messages SET status = 'delivered', delivered_at = NOW()
        Gateway->>Buyer: WS NOTIFY (messageId, status: delivered)
    else Seller is Offline
        Gateway->>RedisQueue: Enqueue BullMQ Push Notification Job
        RedisQueue->>FCM: Send FCM High-Priority Notification
    end
```

---

## 4. Cross-Module Communication Governance

1. **Rule of Direct Isolation:** No module may import another module's Prisma repository or internal service classes.
2. **Public Ports:** A module exposes an `@Injectable()` Public Domain Facade (e.g., `CategoriesPublicService`, `AccountsPublicService`) exposing only clean DTOs.
3. **Asynchronous Decoupling:** Non-transactional cross-boundary updates (such as sending push notifications or updating search cache) MUST occur asynchronously through Domain Events dispatched to the Transactional Outbox.
4. **Zero Circular Imports:** Enforced by ESLint rule `import/no-cycle` at compile time and CI build gates.
