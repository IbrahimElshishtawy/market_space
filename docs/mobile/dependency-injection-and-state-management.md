# Dependency Injection and State Management

## Composition Root Pattern
Dependencies are instantiated during app initialization and grouped inside `AppDependencies`:

```dart
final dependencies = AppDependencies(
  appConfig: config,
  logger: logger,
  networkInfo: networkInfo,
  preferencesService: preferencesService,
  secureStorageService: secureStorageService,
  tokenProvider: tokenProvider,
  apiClient: apiClient,
  mockDataProvider: mockDataProvider,
  platformInfo: platformInfo,
  localeController: localeController,
  themeController: themeController,
);
```

## Accessing Dependencies in UI
Widgets access shared dependencies via the `AppDependenciesScope` InheritedWidget:

```dart
final dependencies = AppDependencies.of(context);
```

## Testing Overrides
In test environments, you can replace real network or storage services with in-memory implementations such as `InMemoryPreferencesService`, `InMemorySecureStorageService`, and `FakeApiClient`.
