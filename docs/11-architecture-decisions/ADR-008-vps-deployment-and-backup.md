# ADR-008: VPS Deployment Topology, Docker & Automated Backup Strategy

## Status
Approved

## Context
Deploying Market Space requires an operational balance between cost efficiency, ease of maintenance by a small engineering team, and high availability.
Options:
1. **Managed Kubernetes (EKS / GKE) with Cloud SQL:** Over-engineered for MVP; incurs high baseline cloud bills ($200–$400/month) and steep operational complexity.
2. **Platform as a Service (Heroku / Render / Railway):** Convenient, but database add-on costs escalate quickly and persistent storage control is limited.
3. **Dedicated VPS with Docker Compose & Automated Offsite Backup:** Cost-effective ($40–$60/month for a 4-vCPU, 8GB RAM host), full control over system resources, reproducible infrastructure via Docker Compose, isolated networks, and automated offsite snapshots.

## Decision
We select an **initial single VPS deployment running Docker Compose**, fronted by Nginx reverse proxy with automated Let's Encrypt TLS certificates.
- PostgreSQL and Redis run in isolated Docker containers with persistent host volumes.
- Automated daily database dumps (`pg_dump`) are encrypted and pushed to offsite Cloudflare R2 bucket storage.
- A well-documented vertical and horizontal scaling path is established for when active registered users exceed 50,000.

## Consequences
- **Positive:**
  - Highly predictable infrastructure costs.
  - Reproducible environments matching local development.
  - Simple operational model maintainable by a single developer.
- **Negative:**
  - Single point of failure for the physical VPS node. Mitigated by automated offsite R2 daily backups and automated container restart policies.
