# Phase 08: Media Engine & Cloudflare R2 Presigned Uploads

## 1. Role & Objective
You are the Cloud & Storage Engineer. Your objective is to implement direct S3-compatible presigned upload URLs for Cloudflare R2 and an asynchronous worker process that scrubs EXIF GPS privacy metadata and compresses images to WebP.

## 2. Relevant Blueprint Documents
- `backend_blueprint/03_API_SPECIFICATION.md` (APIs: API-MED-001, API-MED-002)
- `backend_blueprint/04_SECURITY_ARCHITECTURE.md` (Section 5: Media & File Upload Hardening)

## 3. Exact Implementation Scope
1. Implement `MediaService` and `MediaController`:
   - `POST /api/v1/media/presigned-url`: Generates signed AWS S3/R2 PUT URL with 15-minute expiration, content-length constraint (max 10MB), and whitelisted MIME types.
   - `POST /api/v1/listings/{id}/media`: Attaches confirmed media to listing and enqueues BullMQ processing job.
2. Implement BullMQ Media Consumer Worker:
   - Validates magic bytes (detects spoofed image extensions).
   - Uses `sharp` to strip all EXIF GPS metadata.
   - Generates responsive WebP thumbnails and updates `listing_media.processing_status = 'ready'`.

## 4. Files to Create / Modify
- `backend/src/modules/media/media.controller.ts`
- `backend/src/modules/media/media.service.ts`
- `backend/src/modules/media/r2-storage.service.ts`
- `backend/src/workers/media.processor.ts`

## 5. Acceptance Criteria
- All tests in `backend_tests/security/test_file_upload_security.py` pass.
- Uploaded images have all camera EXIF GPS tags stripped.
- Attempting to upload files > 10MB fails with 400.
