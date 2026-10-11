# Bootstrap and Environments Guide

## Startup Flow Sequence

```mermaid
sequenceDiagram
    participant Main as main.dart
    participant Bootstrap as bootstrap.dart
    participant Validator as ConfigValidator
    participant Storage as SharedPreferences & SecureStorage
    participant Observer as BootstrapObserver
    participant App as MarketSpaceApp

    Main->>Bootstrap: bootstrap(AppConfig.development())
    Bootstrap->>Validator: ConfigValidator.validate(config)
    Validator-->>Bootstrap: OK
    Bootstrap->>Observer: attachGlobalErrorHooks()
    Bootstrap->>Storage: Initialize storage instances & load settings
    Bootstrap->>App: runApp(MarketSpaceApp(dependencies))
```

## Environment Profiles
- `AppEnvironment.development`: Local development URL (`http://localhost:3000/api/v1`), logging enabled, mock mode enabled.
- `AppEnvironment.staging`: Staging server URL (`https://staging-api.marketspace.eg/api/v1`), logging enabled, mock mode disabled.
- `AppEnvironment.production`: Production server URL (`https://api.marketspace.eg/api/v1`), logging disabled, mock mode disabled.
