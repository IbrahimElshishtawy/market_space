# Phase 12: Security Hardening & Penetration Defense

## 1. Role & Objective
You are the Application Security Engineer. Your objective is to audit and harden the entire application against the OWASP Top 10 vulnerabilities, enforce strict HTTP headers, sanitize inputs, and prevent data leakage.

## 2. Relevant Blueprint Documents
- `backend_blueprint/04_SECURITY_ARCHITECTURE.md` (Threat Mitigation Matrix & Defense Rules)
- `backend_blueprint/08_QUALITY_ASSURANCE.md` (Gate 8: Security Fuzzing)

## 3. Exact Implementation Scope
1. Configure Fastify Helmet with strict Content-Security-Policy, HSTS, and X-Content-Type-Options.
2. Verify all DTOs enforce `forbidNonWhitelisted: true` preventing Mass Assignment.
3. Verify parameterization of all Prisma and raw SQL queries (Zero SQL Injection vulnerabilities).
4. Run automated security fuzzing tests in `backend_tests/security/`:
   - `test_auth_attacks.py` (Brute force & token tampering)
   - `test_bola_idor.py` (Cross-tenant modification attempts)
   - `test_rate_limiting.py` (Rate limit bypass attempts)
   - `test_file_upload_security.py` (Malicious file uploads)

## 4. Acceptance Criteria
- All 15 security automated tests in `backend_tests/security/` pass with zero failures.
- Zero High/Critical vulnerabilities detected in security audit.
