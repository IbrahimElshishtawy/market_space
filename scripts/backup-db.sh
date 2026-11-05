#!/usr/bin/env bash
# Deal One — Automated PostgreSQL Database Backup Script
# Adheres to ADR-008 and Production Readiness requirements.

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP="$(date +'%Y%m%d_%H%M%S')"
BACKUP_FILE="${BACKUP_DIR}/marketspace_backup_${TIMESTAMP}.sql.gz"
DB_CONTAINER="${DB_CONTAINER:-marketspace-postgres}"
DB_NAME="${DB_NAME:-marketspace}"
DB_USER="${DB_USER:-marketspace_app}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

mkdir -p "${BACKUP_DIR}"

echo "===================================================="
echo "📦 Initiating Deal One Database Backup at ${TIMESTAMP}"
echo "===================================================="

if docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
  echo "✔ Found running container: ${DB_CONTAINER}"
  docker exec -t "${DB_CONTAINER}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" --clean --if-exists | gzip > "${BACKUP_FILE}"
else
  echo "ℹ Container not found, attempting direct pg_dump via local connection..."
  pg_dump -h "${DB_HOST:-localhost}" -p "${DB_PORT:-5432}" -U "${DB_USER}" -d "${DB_NAME}" --clean --if-exists | gzip > "${BACKUP_FILE}"
fi

BACKUP_SIZE="$(du -h "${BACKUP_FILE}" | cut -f1)"
echo "✅ Backup successfully created: ${BACKUP_FILE} (${BACKUP_SIZE})"

# Prune old backups past retention threshold
echo "🧹 Pruning backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "marketspace_backup_*.sql.gz" -mtime "+${RETENTION_DAYS}" -exec rm -f {} \; || true

echo "✔ Backup routine completed."

