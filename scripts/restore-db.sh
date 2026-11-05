#!/usr/bin/env bash
# Deal One — Database Restore Utility
# Restores a compressed SQL backup produced by backup-db.sh.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <path_to_backup.sql.gz>"
  exit 1
fi

BACKUP_FILE="$1"
DB_CONTAINER="${DB_CONTAINER:-marketspace-postgres}"
DB_NAME="${DB_NAME:-marketspace}"
DB_USER="${DB_USER:-marketspace_app}"

if [ ! -f "${BACKUP_FILE}" ]; then
  echo "❌ Error: Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

echo "===================================================="
echo "⚠️  Restoring Deal One Database from: ${BACKUP_FILE}"
echo "===================================================="

read -p "Are you sure you want to restore to database '${DB_NAME}'? This will overwrite existing data. (y/N): " -r CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Restore aborted by user."
  exit 0
fi

if docker ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER}$"; then
  echo "✔ Restoring into container ${DB_CONTAINER}..."
  gunzip -c "${BACKUP_FILE}" | docker exec -i "${DB_CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}"
else
  echo "✔ Restoring via local connection..."
  gunzip -c "${BACKUP_FILE}" | psql -h "${DB_HOST:-localhost}" -p "${DB_PORT:-5432}" -U "${DB_USER}" -d "${DB_NAME}"
fi

echo "✅ Database restore completed successfully."

