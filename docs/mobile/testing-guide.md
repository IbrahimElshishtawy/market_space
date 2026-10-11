# Testing Guide

## Running Tests
To run all tests in the repository:
```bash
flutter test
```

To run code static analysis:
```bash
flutter analyze
```

## Test Structure
- Unit tests: Located under `test/unit/`
- Widget tests: Located under `test/` (e.g. `test/widget_test.dart`)
- Test fakes: Use `InMemoryPreferencesService`, `InMemorySecureStorageService`, and `FakeApiClient` to isolate tests without touching platform channels or network sockets.
