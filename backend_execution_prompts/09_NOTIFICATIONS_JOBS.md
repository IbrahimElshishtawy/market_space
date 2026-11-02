# Phase 09: Notifications, Quotas Engine & Background Workers

## 1. Role & Objective
You are the Systems & Infrastructure Engineer. Your objective is to build the daily quota tracking engine with atomic Redis counters resetting at Cairo midnight, the in-app notification center, and Firebase Cloud Messaging (FCM) push dispatching.

## 2. Relevant Blueprint Documents
- `backend_blueprint/01_BACKEND_ARCHITECTURE.md` (Section 1.8 Background Jobs, Section 1.9 Notifications)
- `backend_blueprint/03_API_SPECIFICATION.md` (APIs: API-QTA-001, API-NOT-001, API-NOT-002)

## 3. Exact Implementation Scope
1. Implement `QuotasService`:
   - Redis-backed sliding counters for daily listings, chat initiations, and contact reveals.
   - Atomic Lua script check-and-increment.
   - Automatic expiration set to `00:00:00 Africa/Cairo` timezone.
   - Syncs daily historical stats to database table `daily_quotas`.
2. Implement `NotificationsService`:
   - Persists in-app notifications to table `notifications`.
   - Enqueues BullMQ push notification jobs.
3. Implement BullMQ FCM Push Worker:
   - Queries `user_devices` for active FCM tokens.
   - Sends multicast notifications using Firebase Admin SDK.
   - Cleans up unregistered/invalid device tokens.

## 4. Files to Create / Modify
- `backend/src/modules/quotas/quotas.service.ts`
- `backend/src/modules/quotas/quotas.controller.ts`
- `backend/src/modules/notifications/notifications.service.ts`
- `backend/src/modules/notifications/notifications.controller.ts`
- `backend/src/workers/notification.processor.ts`

## 5. Acceptance Criteria
- All tests in `backend_tests/functional/test_quotas.py` and `test_notifications.py` pass.
- Quotas correctly decrement and return 429 when exhausted.
- FCM push worker processes notifications asynchronously in < 2 seconds.
