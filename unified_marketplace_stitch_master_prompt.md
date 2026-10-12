# Master Prompt — Unified Multi-Sector Marketplace
## Stitch UI/UX + Product Specification + Software Architecture Blueprint

**Primary language:** Arabic RTL, Egyptian market  
**Platform:** Mobile-first marketplace  
**Sectors:** Real Estate, Building Materials, Services & Contracting, Projects & Investment

## 1. Role and objective
Act as a senior product designer, UX architect, design-system specialist, and software solution architect. Use the existing Stitch screens/reference as the primary visual source of truth. Preserve their recognizable visual direction, improve weak hierarchy/spacing/accessibility, and create one coherent product—not four unrelated apps. If a detail is missing, make a reasonable assumption and document it. Do not invent real business facts.

## 2. Product vision
Build one app and one account across four sectors:
1. **العقارات:** بيع وإيجار الشقق والفلل والأراضي والوحدات التجارية.
2. **مواد البناء:** الأسمنت والحديد والكابلات والطوب والبورسلين والدهانات ومستلزمات البناء.
3. **الخدمات والمقاولات:** التشطيب والسباكة والكهرباء والصيانة والتجديد ونقل الأثاث.
4. **المشروعات والاستثمار:** المشروعات السكنية والتجارية والأراضي وفرص التطوير.

Each sector owns its Home, categories, filters, listing fields, details, and create/request flows. Shared platform capabilities are account/profile, authentication, messages, notifications, favorites, global search, location selection, settings, help, and reporting.

**New-user default:** Real Estate. Users can switch sectors immediately without repeating onboarding or signing in again.

## 3. Four distinct Home screens
Create **four separate, full-size mobile frames/pages in the same Stitch project**. Do not make a collage, do not shrink three screens into thumbnails, and do not stop after one screen. Use the existing Stitch reference as the visual baseline.

### A. Home / Real Estate — العقارات
- Arabic RTL; greeting, location, notifications, profile.
- Prominent property search and persistent sector switcher.
- Sale/Rent control.
- Category shortcuts: شقق، فلل، أراضٍ، تجاري.
- Property cards with image, title, location, area, price, and relevant facts.
- Favorite action and “view all” sections.
- Primary CTA: أضف عقارك.
- Bottom nav: الرئيسية، استكشاف، أضف عقارك، الرسائل، حسابي.

### B. Home / Building Materials — مواد البناء
- Same global shell and RTL rules; industrial-blue accent.
- Search by product, material, or supplier.
- Category shortcuts for major building materials.
- Product cards with image, name, unit/packaging, price only if supplied, supplier, and delivery/location context.
- Support “اطلب عرض سعر” for items without a fixed price.
- Bottom nav: الرئيسية، المنتجات، طلب توريد، الرسائل، حسابي.

### C. Home / Services & Contracting — الخدمات والمقاولات
- Same global shell; green accent.
- Search for service or contractor.
- Categories: تشطيب، سباكة، كهرباء، صيانة، نقل.
- Provider cards with service, coverage area, and description. Show ratings/reviews only when backed by real data.
- Clear CTA: اطلب خدمة / اطلب عرض سعر.
- Bottom nav: الرئيسية، الخدمات، طلباتي، الرسائل، حسابي.

### D. Home / Projects & Investment — المشروعات والاستثمار
- Same global shell; deep navy/purple accent.
- Search by project, type, or location.
- Categories: سكني، تجاري، أراضٍ، فرص تطوير.
- Project cards with image, name, location, type, and status only when available.
- CTA to view details or request information.
- Never invent ROI, guaranteed profit, ratings, or financial claims.
- Bottom nav: الرئيسية، المشروعات، المحفوظات، الرسائل، حسابي.

## 4. One app, smoothly connected
Design a persistent sector switcher accessible from every Home and relevant global screen:
- Show the four sector names and consistent icons; highlight the active sector.
- Switching changes Home, categories, filters, contextual CTA, and sector-specific bottom navigation.
- Switching must preserve authentication, profile, messages, notifications, and favorites.
- Persist the preferred sector in app state/user preferences.
- Use a restrained transition; avoid unnecessary full-screen loading.
- Opening a deep link to another sector must open the correct sector and item details.
- Back navigation should preserve the previous browsing state when possible.

Shared screens/features must be truly shared destinations, not duplicated versions per sector. Each tab must have a defined destination; do not make all tabs open the same generic screen.

## 5. Shared navigation and screen inventory
Create or specify these shared screens:
- Sector switcher.
- Global search and sector-aware results/filtering.
- Unified messages inbox and conversation details.
- Unified notifications.
- Favorites grouped/filterable by sector.
- Profile, edit profile, and account settings.
- Login, registration, forgot password, signed-out protected-action states.
- Help/support, report listing/user, block user.

Create reusable sector-specific templates:
- Category listing page.
- Search results with relevant filters and sorting.
- Property/product/service/project details.
- Create listing or submit request.
- Media upload/progress/error states.
- Contact seller/provider/publisher.
- Request status/history where relevant.

Prioritize the four Homes and Design System first, then create the rest in batches without changing the shared visual language.

## 6. Cross-sector user journeys
Show entry point, actions, destination, state changes, and error/empty states for these journeys:

1. **Property → materials:** user saves a property, switches to Building Materials, requests a quotation; the account and saved property remain intact.
2. **Property → services:** user finds a service and submits a request; the request appears in the correct request area and messages can reference it.
3. **Project → contact:** user saves a project, requests information, and sees the contextual conversation in the unified inbox.
4. **One user → multiple sectors:** one account can publish in multiple sectors according to platform rules; each listing uses sector-specific fields and moderation.
5. **Notification → destination:** notification opens the correct listing, request, conversation, or project in its proper sector.

Connect sectors through shared identity, search, favorites, messaging, notifications, and relevant contextual links—not artificial dependencies.

## 7. Design System deliverable
Create a `Design System / Foundations` frame. Extract visible values from the reference where possible. Document:
- Brand/neutral colors and four sector accent colors with exact HEX values and contrast guidance.
- Arabic typography, font recommendation, sizes, weights, and line heights.
- Spacing scale, layout grid, radii, elevation, borders, image ratios.
- One consistent icon family (e.g. Material Symbols or Lucide) and exact icon names for navigation/categories.
- Buttons, inputs, search, cards for each sector, chips, tabs, filters, badges, bottom nav, app bar, dialogs, bottom sheets, snackbars, skeleton loaders.
- Component variants/states: default, pressed, focus, selected, disabled, loading, success, error.
- Accessibility: readable contrast, clear labels, and approximately 44–48 px touch targets.

Use sector colors as accents within one design system—not four unrelated themes. Do not mix unrelated icon styles. Use relevant, credible imagery and do not embed important UI text inside images.

## 8. Arabic RTL and localization
- Arabic is the primary interface language; ensure correct RTL layout and reading order.
- Keep prices, numbers, phone numbers, IDs, and mixed Arabic/English text legible.
- Use Egyptian pounds (ج.م) where currency is displayed.
- Use professional, familiar Egyptian terminology.
- Do not mirror logos or icons whose meaning should not be mirrored.
- Keep components ready for future English/LTR support.
- Avoid text embedded in images.

## 9. Software architecture blueprint
Create an `Architecture / Modules & Boundaries` frame/document. This is a blueprint for developers, not a claim that Stitch has implemented a backend.

Prefer a **modular monolith with clear domain boundaries** initially; do not propose microservices without a demonstrated need.

Suggested modules:
- `app_shell`: routing, global navigation, sector selection.
- `design_system`: tokens, themes, reusable components, icon registry.
- `auth`, `users`.
- `real_estate`.
- `building_materials`.
- `services_contracting`.
- `projects_investment`.
- `search`.
- `messaging`.
- `favorites`.
- `notifications`.
- `media`.
- `moderation`.
- `analytics`.
- `admin`.

Rules:
- Each sector owns its models, validation, filters, forms, and business rules.
- Shared modules must not contain sector-specific business logic.
- Modules communicate through documented interfaces, stable IDs, events, and shared services.
- Use explicit entity types such as `property`, `material_product`, `service`, and `project`.
- Use one canonical user identity, not four accounts.
- Authorization must be enforced by backend/server policies, not UI visibility alone.
- Validate input on client and server.
- Use pagination, appropriate search indexes, image resizing, caching, safe retries, and clear error handling.
- Protect operations from harmful duplicate submissions using transactions/idempotency where needed.
- Define timestamps, status transitions, audit records, backups, monitoring, and rollback.
- Never include privileged credentials or secret keys in a mobile client.

### Suggested Flutter feature-first structure
If implemented in Flutter, keep presentation, application/state, domain, and data layers separate; keep widgets thin and business logic outside the UI. Choose state management and routing consistently, use dependency injection and repository interfaces, and avoid direct UI dependency on backend SDKs.

```text
lib/
  app/
    app.dart
    router/
    sector/
    bootstrap/
  core/
    design_system/
    networking/
    errors/
    storage/
    permissions/
  shared/
    auth/
    users/
    messaging/
    notifications/
    favorites/
    search/
    media/
  features/
    real_estate/
      presentation/
      application/
      domain/
      data/
    building_materials/
      presentation/
      application/
      domain/
      data/
    services_contracting/
      presentation/
      application/
      domain/
      data/
    projects_investment/
      presentation/
      application/
      domain/
      data/
  main.dart
```

## 10. Conceptual data model
Document the entities and relationships before implementation. Do not claim a database is already deployed.

Shared entities:
- `users`, `user_profiles`, `conversations`, `messages`, `notifications`, `favorites`, `media_assets`, `reports`.

Sector entities:
- `properties`
- `material_products`
- `suppliers` (if separate supplier business profiles are needed)
- `quotation_requests`
- `service_listings`
- `service_requests`
- `projects`
- `project_inquiries`

Use sector-specific tables/entities, not one giant table full of nullable fields. Common metadata may include `id`, `owner_user_id`, `sector`, `title`, `description`, `location`, `media`, `status`, `created_at`, `updated_at`. Define relationships, ownership, constraints, lifecycle/status rules, and deletion behavior.

### Conversation context
A conversation can reference a related entity through:
- `context_type`: `property`, `material_product`, `quotation_request`, `service_listing`, `service_request`, or `project`.
- `context_id`: related entity ID.
- participants, timestamps, last-message metadata, unread count.

Clearly show in the UI what the conversation concerns. Backend authorization must prevent users from reading conversations they do not participate in.

## 11. API contract outline
Document proposed API groups and example operations without claiming they already exist:
- Authentication/profile.
- Sector listings: list, details, create/update, archive.
- Global search and sector filters.
- Favorites add/remove/list.
- Conversations list/create; messages send/list.
- Notifications list/read.
- Quotation requests and service requests.
- Project inquiries.
- Media upload initiation and metadata.
- Reports/moderation.

For each operation specify request/response shape, authorization, validation, pagination if relevant, and expected errors. Keep contracts versionable and use a consistent error format.

## 12. Security, trust, and privacy
Include:
- Roles/permissions for users, business/provider accounts, and admins.
- Backend ownership checks for edits/deletes.
- Rate limits for authentication, messages, inquiries, and submissions.
- Input validation and safe media upload rules.
- Reporting, blocking, moderation, and admin audit trail.
- Minimize personal data; do not expose phone/email by default.
- Never show “verified” unless a real verification process/status exists.
- Never fabricate ratings, reviews, sales volume, stock, or investment returns.
- Account deletion/export/deactivation policies and data retention.
- Least-privilege database/storage rules and server-side secret management.

## 13. Non-functional requirements
Document target metrics and tests—not unverified promises—for:
- Performance on mid-range Android and ordinary mobile networks.
- Responsive layouts and Arabic RTL.
- Poor-network/offline feedback and safe retries.
- Accessibility, readable text, and localization.
- Crash/error monitoring and privacy-aware analytics.
- Reliability, backup/restore, deployment rollback.
- Unit, widget/component, integration, API, security, and end-to-end tests.

## 14. Required edge states
For key screens include:
- Loading/skeleton, empty results, no internet/timeout, server error/retry.
- Permission denied, invalid form, upload progress/failure.
- Saved/unsaved, signed-out protected action.
- Deleted/archived/unavailable item.
- Duplicate submission prevention.
- No messages/notifications, no search matches.
- Long Arabic titles and missing optional fields.

## 15. Final handoff deliverables
Create these frames/documents in the same project:
1. Four separate full-size Home screens.
2. Shared app shell and sector switcher.
3. Design System with exact HEX values, typography, spacing, components, icon names.
4. Information architecture/navigation map.
5. Five cross-sector user-flow diagrams.
6. Screen inventory and each screen's purpose.
7. Component inventory and states.
8. RTL and future LTR notes.
9. Architecture modules/boundaries.
10. Conceptual data model and relationships.
11. API contract outline.
12. Security/privacy checklist.
13. Acceptance criteria and testing checklist.
14. Assumptions/open questions requiring product-owner approval.

Use frame names:
- `Home / Real Estate`
- `Home / Building Materials`
- `Home / Services & Contracting`
- `Home / Projects & Investment`
- `Design System / Foundations`
- `Shared / Sector Switcher`
- `Shared / Global Search`
- `Shared / Messages`
- `Shared / Notifications`
- `Architecture / Modules & Boundaries`
- `Architecture / Data Model`
- `Flows / Cross-Sector Journeys`

## 16. Acceptance criteria
The work is incomplete unless:
- Four separate full-size Homes exist—not one collage.
- Homes are distinct in content and accent color but clearly belong to one product.
- Sector switching updates relevant content/navigation and preserves account/shared features.
- Messages, favorites, and notifications work conceptually across sectors.
- Each card type has sector-specific fields.
- Key loading/empty/error states are designed.
- Arabic RTL is correct.
- Actual HEX values, icon names, typography, spacing, and variants are documented.
- Sector modules are separated from shared services.
- Data model, API outline, security requirements, and journeys are documented.
- No unsupported verification, ratings, guarantees, or investment-return claims appear.

## 17. Execution order
1. Inspect the existing Stitch reference and extract its visual language.
2. Define shared design foundations.
3. Complete the four separate Home screens.
4. Build shared app shell and sector switcher.
5. Build search, messages, notifications, favorites, and profile.
6. Build sector details and create/request flows.
7. Map cross-sector journeys.
8. Document architecture, data model, API contracts, security, and tests.
9. Audit all frames for consistency.

If you cannot generate everything at once, complete the current phase thoroughly, list what remains, and continue in the same design language. Do not collapse the task into a single screen.

**Final instruction:** Treat this as one connected modular marketplace—not four disconnected apps and not merely attractive mockups. Prioritize the existing Stitch reference, smooth cross-sector journeys, maintainable architecture, and a clear handoff to implementation.
