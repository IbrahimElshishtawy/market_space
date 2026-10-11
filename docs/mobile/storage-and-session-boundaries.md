# Storage and Session Boundaries

## Storage Separation

### Preferences Storage
- Implementation: `SharedPreferencesServiceImpl`
- Intended for non-sensitive data:
  - App locale (`ar`, `en`)
  - Theme mode (`light`, `dark`, `system`)
  - Onboarding status

### Secure Storage
- Implementation: `FlutterSecureStorageServiceImpl` backed by Android Keystore / iOS Keychain
- Intended for sensitive session material:
  - JWT Access Token
  - Refresh Token
  - Authenticated User Identifier
