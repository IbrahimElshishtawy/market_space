# ADR-006: Media Storage & Short-Form Video Processing Strategy

## Status
Approved

## Context
Classifieds listings require high-quality photo galleries and an optional 30-second short video showcase.
Key considerations:
- Storing large images or video binaries directly in PostgreSQL saturates database connections and backup sizes.
- Transcoding video files on the application VPS (e.g. via `ffmpeg`) consumes immense CPU and RAM, risking API response degradation and outages during concurrent uploads.
- Egress bandwidth costs from cloud object storage can become unpredictable.

Options:
1. **Self-Hosted Local File Storage & Local FFmpeg Worker:** Lowest software subscription cost, but saturates VPS disk I/O, CPU, and network egress bandwidth.
2. **AWS S3 + CloudFront + AWS MediaConvert:** Enterprise-grade, but complex configuration and high egress bandwidth costs.
3. **Cloudflare R2 (Images) + Cloudflare Stream (Video):**
   - *Cloudflare R2:* Zero egress bandwidth fees, 100% S3 API compatibility, direct-to-storage presigned upload URLs.
   - *Cloudflare Stream:* Fully managed video encoding, adaptive bitrate HLS/DASH streaming, automated thumbnail extraction, direct-creator upload URLs, and webhook event notifications.

## Decision
We select **Cloudflare R2 for image storage** and **Cloudflare Stream for short video encoding and delivery**.
- Mobile clients upload images directly to Cloudflare R2 using short-lived presigned URLs.
- Short videos (max 30s) are uploaded directly to Cloudflare Stream. Cloudflare webhooks notify the backend worker upon encoding completion, updating the listing record with HLS playback URLs.
- VPS CPU is 100% shielded from video transcoding workloads.

## Consequences
- **Positive:**
  - Zero egress fees for images via Cloudflare R2.
  - Zero CPU spikes on the VPS from video transcoding.
  - Adaptive bitrate streaming guarantees smooth video playback across diverse mobile network connections in Egypt (3G/4G/5G).
- **Negative:**
  - Cloudflare Stream requires a paid plan ($5 per 1,000 minutes stored, $1 per 1,000 minutes streamed). Mitigated by strict 30-second limits and 1 video per listing maximum.
