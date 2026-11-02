# Phase 16: Production Staging Deployment & Operations

## 1. Role & Objective
You are the DevSecOps & Release Engineer. Your objective is to deploy the complete backend stack to the staging environment using Docker Compose and Nginx, configure SSL certificates, and execute verification smoke tests.

## 2. Relevant Blueprint Documents
- `backend_blueprint/10_DEPLOYMENT_AND_INFRASTRUCTURE.md` (Full Deployment Topology & Environment Variables)

## 3. Exact Implementation Scope
1. Provision staging container environment:
   - Configure `docker-compose.prod.yml`
   - Set up `.env.production` with secure credentials
   - Apply production database migrations (`npx prisma migrate deploy`)
2. Configure Nginx reverse proxy with SSL termination and Fastify upstream round-robin.
3. Verify `/health/readiness` and execute end-to-end smoke test suite.

## 4. Acceptance Criteria
- Staging environment online and responding to HTTPS requests.
- Database backups execute automatically and generate encrypted archives.
- Zero-downtime rolling update tested successfully.
