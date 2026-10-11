# Flutter Mobile App Architecture Master Prompt
## Foundation Only — No Features, No Screens, No UI Implementation

You are acting as a Principal Flutter Architect. Your task is to inspect the existing repository and establish a clean, scalable, production-oriented Flutter application foundation for an Egyptian classifieds marketplace.

**Critical scope boundary:** Build the shared architecture and infrastructure only. Do not implement product features, feature modules, pages, screens, widgets for specific screens, or business workflows. Do not invent or scaffold future feature folders. The goal is to prepare a strong foundation that feature teams can build on later.

The product is a classifieds marketplace: users will eventually browse and search listings, view products, publish advertisements, save favorites, contact sellers, and optionally view short videos. Video is secondary. The app targets Android and iOS, Arabic-first with planned English support and RTL.

## 1. Audit the Repository First

1. Inspect the Flutter project, `pubspec.yaml`, `lib/`, `test/`, assets, localization setup, dependency versions, lint rules, and entry point.
2. Identify existing architecture and working code.
3. Do not delete, rename, or overwrite working code blindly.
4. Preserve application identity, bundle IDs, signing configuration, platform configuration, icons, and unrelated assets.
5. Report important conflicts and risks before disruptive changes.
6. If this is not a Flutter app, stop and explain.
7. If feature screens already exist, leave them untouched unless minimal wiring is required. Do not refactor feature code in this task.

Before implementation, provide a concise plan covering current state, proposed directory tree, state management and DI, configuration, networking, storage, localization, error handling, and tests. Then implement the foundation if no material unresolved decision blocks it.

## 2. Architecture Principles

- Separate app bootstrap, shared core infrastructure, reusable shared code, and future feature modules.
- Apply dependency inversion; business-facing abstractions should not depend on concrete infrastructure.
- Use one predictable composition root for dependency registration.
- Prefer constructor injection; avoid service-locator calls scattered throughout the code.
- Avoid circular dependencies, hidden global mutable state, giant `utils.dart`/`constants.dart`/`services.dart` files, and unnecessary abstractions.
- Use typed models and explicit error/result conventions.
- Keep environment-specific configuration out of source code.
- Follow current Dart/Flutter best practices compatible with the repository SDK.
- Use English identifiers. Do not add Arabic code comments; avoid comments unless they explain a non-obvious decision.
- Never put backend secrets in the mobile application. Client-side configuration is extractable and must be treated as public.

## 3. Suggested Directory Structure

Adapt names to the existing repository where sensible. Do not create empty files just to fill a tree; create only useful foundation code.

```text
lib/
  main.dart
  bootstrap/
    bootstrap.dart
    bootstrap_observer.dart
  app/
    app.dart
    app_router.dart
    app_theme.dart
    app_localization.dart
    app_dependencies.dart
  core/
    config/
      app_config.dart
      environment.dart
      config_validator.dart
    constants/
      app_constants.dart
    errors/
      app_exception.dart
      app_failure.dart
      error_mapper.dart
    logging/
      app_logger.dart
      log_sanitizer.dart
    network/
      api_client.dart
      api_endpoints.dart
      api_headers.dart
      network_info.dart
      interceptors/
        auth_interceptor.dart
        request_id_interceptor.dart
        logging_interceptor.dart
        retry_interceptor.dart
    storage/
      secure_storage_service.dart
      preferences_service.dart
      storage_keys.dart
    security/
      token_provider.dart
      session_state.dart
    localization/
      locale_controller.dart
      supported_locales.dart
    theme/
      app_colors.dart
      app_text_styles.dart
      app_spacing.dart
      app_radii.dart
      app_theme_data.dart
    routing/
      route_names.dart
      route_guards.dart
    platform/
      platform_info.dart
    utils/
      date_time_utils.dart
      input_normalizers.dart
  shared/
    models/
      paginated_response.dart
      api_error_response.dart
    data/
      data_source.dart
      repository.dart
    state/
      async_state.dart
    widgets/
      app_loading_indicator.dart
      app_error_view.dart
      app_empty_state.dart
  l10n/
    app_en.arb
    app_ar.arb

test/
  unit/
  widget/
  integration/
```

This is a boundary map, not a requirement to create every file. Do not create `features/auth`, `features/home`, `features/listings`, `features/profile`, or any other feature folders. Future feature modules may later use `features/<feature_name>/data`, `domain`, and `presentation`, but do not create those folders now.

## 4. Bootstrap and App Layer

Create a deterministic, testable startup flow:
1. Load and validate environment configuration.
2. Initialize Flutter bindings and required platform services.
3. Initialize logging and error-reporting hooks.
4. Configure dependency injection.
5. Initialize localization/theme/router prerequisites.
6. Run the app only after required initialization succeeds.
7. Handle startup failures safely; do not silently swallow fatal initialization errors.

Keep `main.dart` small and orchestration in `bootstrap/bootstrap.dart`. Configure `FlutterError.onError` and `PlatformDispatcher.instance.onError` appropriately, without exposing sensitive details. Avoid network requests before first render unless strictly required. Allow dependencies to be overridden in tests. Treat bundled `.env` values and compile-time defines as extractable, not secret. Do not add production credentials.

## 5. State Management and Dependency Injection

Inspect existing dependencies. If no choice exists, select one approach appropriate for a large Flutter app and use it consistently. Evaluate Riverpod or Bloc against repository fit and current compatibility. Do not mix state-management systems without a documented reason.

Prefer constructor injection. Register shared infrastructure in one composition root. Make dependencies replaceable in tests. Document how future feature modules register data sources, repositories, and state controllers. Do not implement any feature-specific provider, bloc, cubit, controller, or workflow.

## 6. Networking Foundation

Create a reusable configurable HTTP client for a REST backend. Select a maintained package compatible with the repository; evaluate Dio if interceptors are useful.

- Centralize base URL, timeouts, headers, and request configuration.
- Support JSON and consistent typed error mapping.
- Support request/correlation IDs if the backend contract supports them.
- Redact authorization headers, tokens, passwords, OTPs, personal data, and payment-related values from logs.
- Provide a generic auth-interceptor hook only; do not implement login or assume the auth protocol before reviewing backend API docs.
- Never retry non-idempotent requests automatically unless a documented idempotency mechanism protects them.
- Bound retries and use sensible timeouts.
- Handle offline, timeout, cancellation, malformed responses, unauthorized/forbidden, validation, rate-limit, server, and unknown errors consistently.
- Do not fabricate production endpoints or hardcode a real server URL without approved configuration.
- Include a fake/mock client strategy for tests.
- Do not add WebSockets unless approved architecture requires them.

Adapt generic error models to the actual backend OpenAPI contract; do not assume a response envelope that conflicts with existing docs.

## 7. Error Handling

Separate low-level network/storage/platform exceptions, application-friendly failures, safe user-facing messages, and diagnostic logs. Use typed failures or a documented result convention. Never show raw stack traces/internal exceptions to users. Do not log credentials or sensitive payloads. Preserve useful diagnostic context without leaking private data. Avoid catching and ignoring exceptions.

## 8. Storage and Session Boundaries

Provide distinct abstractions for:
- Secure storage for sensitive session material, if required by the approved auth design.
- Preferences storage for non-sensitive settings such as locale/theme.

Use maintained compatible packages. Never store passwords or raw payment credentials. Centralize storage keys. Do not store tokens until the backend auth contract is known. Provide in-memory fakes for tests. Handle platform failures and document Android/iOS backup and migration differences. Never store sensitive personal data in ordinary preferences.

## 9. Environment Configuration

Provide typed `AppConfig` (or equivalent) for development, staging, and production. Select environments explicitly and validate required values at startup. Supply the API URL and non-secret settings through the existing project's supported mechanism. Provide only a placeholder `.env.example` if appropriate. Never silently fall back to production when config is missing or invalid. Validate URL formats. Document that mobile client configuration cannot secure backend secrets.

## 10. Routing — No Screens

Reuse the existing router if suitable; otherwise evaluate a maintained option such as `go_router`. Centralize route names/paths, provide a clean future location for session guards, handle unknown routes, and prepare for deep links if relevant. Keep route configuration testable. Do not create feature routes, screen files, or navigation flows. A neutral placeholder root view is acceptable only to prove the app boots; do not design a home screen.

## 11. Theme and Localization — Foundation Only

Theme:
- Centralize semantic colors, spacing, radii, typography, and light/dark theme configuration.
- Avoid hardcoded visual values in future screens.
- Do not invent final branding unless approved assets/design docs already define it.
- Do not create polished product UI.

Localization:
- Set up Flutter localization and ARB files for English and Arabic.
- Support RTL for Arabic and LTR for English.
- Use generated localization APIs supported by the current SDK.
- Keep user-facing strings out of core logic.
- Add only foundation-level strings needed for startup/fallback states.
- Document localization generation commands.
- Do not create feature copy.

## 12. Shared Foundation Components

Create only genuinely reusable, feature-neutral pieces needed to validate the foundation: generic async state if useful, a pagination model if it matches or is clearly adaptable to the API contract, a generic API error model, and simple loading/error/empty placeholders if needed. Do not create listing cards, category widgets, product widgets, chat widgets, or feature UI.

## 13. Logging and Diagnostics

Use a maintained logging abstraction with readable development logs, configurable production levels, redaction, request IDs where practical, centralized Flutter/async error hooks, and an optional error-reporting integration point. Do not send data to external services unless configured and consent/privacy requirements are addressed. Never print tokens, passwords, OTPs, payment credentials, or sensitive headers.

## 14. Code Quality and Version Control

- Configure Dart formatting and practical lint rules.
- Create unit/widget/integration test structure.
- Test config validation, error mapping, storage abstractions, networking behavior, localization, and bootstrap where feasible.
- Use dependency versions compatible with the repo's Flutter/Dart SDK.
- Remove no existing dependency unless clearly unused and safe to remove.
- Do not create unused dependencies or empty placeholder classes.
- Inspect `.gitignore` and exclude secrets, environment files, build outputs, and local IDE artifacts.
- Do not rewrite Git history or create commits unless requested.

Before adding packages, inspect existing dependencies, compatibility, maintenance status, and minimum viable set. Explain important choices and trade-offs. Run dependency resolution, formatting, analysis, and tests after changes.

## 15. Documentation to Create

Create practical docs:
- `docs/mobile/architecture.md`
- `docs/mobile/folder-structure.md`
- `docs/mobile/bootstrap-and-environments.md`
- `docs/mobile/dependency-injection-and-state-management.md`
- `docs/mobile/networking-and-error-handling.md`
- `docs/mobile/storage-and-session-boundaries.md`
- `docs/mobile/theme-and-localization.md`
- `docs/mobile/testing-guide.md`
- `docs/mobile/adding-a-new-feature.md`

The feature guide should document the future pattern, such as `features/<feature>/data`, `domain`, and `presentation`, repository interfaces, data sources, models, dependency registration, tests, dependency direction, and where shared/core code belongs. **Document the future pattern without creating feature folders or implementing a feature.** Use Mermaid diagrams for startup flow and dependency direction where useful; keep docs aligned with code.

## 16. Acceptance Criteria

The foundation is complete only when:
- The app builds/launches on configured targets, or pre-existing blockers are clearly reported.
- `main.dart` delegates to a testable bootstrap flow.
- Configuration is validated and no production secrets exist in source.
- Dependency registration is centralized and testable.
- HTTP client configuration and safe error handling are centralized.
- Logs redact sensitive values.
- Secure storage and preferences have separate abstractions.
- Routing is ready for future features but contains no feature screens.
- Theme tokens and Arabic/English localization foundations exist.
- Linting and tests are configured and actually executed.
- Documentation matches implementation.
- No feature modules, product screens, business workflows, or backend-specific auth/payment implementations were added.
- No unrelated existing code was deleted or rewritten.

At completion, report architecture choices and rationale, final tree, changed files, added dependencies, commands and actual results, blockers, and exact run/analyze/test/localization-generation instructions. Never claim a command succeeded unless you actually ran it.

## 17. Start Instruction

Begin by auditing the existing Flutter repository. Show the proposed structure and key decisions first. Then implement only the approved shared foundation described above. Do not implement features, screens, or feature-specific UI. If a major decision conflicts with the existing project or requires product/backend assumptions, explain the issue and ask for approval before proceeding.
