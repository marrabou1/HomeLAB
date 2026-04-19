#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# TrueNAS Config Backup
# -----------------------------

# CONFIGURATION
TRUENAS_HOST="<http or https>"     # e.g. https://192.168.1.10
API_KEY="<API key from the TrueNAS>"
BACKUP_DIR="<Where to store the backups>"
RETENTION_DAYS=30

# Export options
EXPORT_SECRET_SEED=true
EXPORT_ROOT_AUTH_KEYS=false

# If you use a self-signed cert, set this to true (better: install proper CA)
INSECURE_TLS=false

mkdir -p "$BACKUP_DIR"

DATE="$(date +"%Y-%m-%d_%H-%M-%S")"
OUTPUT_FILE="$BACKUP_DIR/truenas_config_${DATE}.tar"
TMP_FILE="${OUTPUT_FILE}.tmp"

CURL_TLS_ARGS=()
if [[ "$INSECURE_TLS" == "true" ]]; then
  CURL_TLS_ARGS+=(--insecure)
fi

echo "Backing up TrueNAS configuration from: $TRUENAS_HOST"
echo "Output: $OUTPUT_FILE"

# POST /api/v2.0/config/save 
HTTP_CODE="$(
  curl -sS --fail \
    "${CURL_TLS_ARGS[@]}" \
    -o "$TMP_FILE" \
    -w "%{http_code}" \
    -X POST \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"secretseed\": ${EXPORT_SECRET_SEED}, \"root_authorized_keys\": ${EXPORT_ROOT_AUTH_KEYS}}" \
    "$TRUENAS_HOST/api/v2.0/config/save"
)"

# Basic sanity checks
if [[ "$HTTP_CODE" != "200" ]]; then
  echo "Backup failed (HTTP $HTTP_CODE)."
  rm -f "$TMP_FILE"
  exit 1
fi

if [[ ! -s "$TMP_FILE" ]]; then
  echo "Backup failed: downloaded file is empty."
  rm -f "$TMP_FILE"
  exit 1
fi

mv "$TMP_FILE" "$OUTPUT_FILE"
echo "✅ Backup saved to: $OUTPUT_FILE"

echo "Pruning backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -name "truenas_config_*.tar" -mtime +"$RETENTION_DAYS" -delete

echo "Done."
