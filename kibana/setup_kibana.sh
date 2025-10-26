#!/usr/bin/env bash
set -euo pipefail

NDJSON_FILE="kibana/filebeat-data-view.ndjson"

if [ ! -f "$NDJSON_FILE" ]; then
  echo "ERROR: $NDJSON_FILE not found. Create the file with the Kibana saved objects you want to import." >&2
  exit 1
fi

echo "Importing $NDJSON_FILE into Kibana (saved_objects import)..."

# kbn-xsrf header is required by Kibana for API requests that change state
HTTP_BODY=$(mktemp)
HTTP_STATUS=$(curl -s -w "%{http_code}" -o "$HTTP_BODY" -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" \
  -H "kbn-xsrf: true" \
  --form file=@"$NDJSON_FILE") || true

if [ "$HTTP_STATUS" -eq 200 ] || [ "$HTTP_STATUS" -eq 201 ]; then
  echo "Kibana import finished (HTTP status: $HTTP_STATUS)."
  rm -f "$HTTP_BODY"
  exit 0
fi

echo "Import returned HTTP $HTTP_STATUS. Response:"
cat "$HTTP_BODY" || true

# If Kibana rejects the import due to version mismatch (422), fall back to creating the index pattern via saved_objects API
if [ "$HTTP_STATUS" -eq 422 ]; then
  echo "Detected version mismatch during import. Falling back to creating the index pattern via saved_objects API (compatible with older Kibana)."
  FALLBACK_RESPONSE=$(curl -s -w "%{http_code}" -o /tmp/kbn_fallback_resp -X POST "http://localhost:5601/api/saved_objects/index-pattern" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d '{"attributes": {"title": "filebeat-*", "timeFieldName": "@timestamp"}}') || true

  echo "Fallback API HTTP status: $FALLBACK_RESPONSE"
  cat /tmp/kbn_fallback_resp || true
  rm -f /tmp/kbn_fallback_resp
  rm -f "$HTTP_BODY"
  if [ "$FALLBACK_RESPONSE" -ge 200 ] && [ "$FALLBACK_RESPONSE" -lt 300 ]; then
    echo "Index pattern created via fallback API successfully."
    exit 0
  else
    echo "Fallback creation failed (HTTP $FALLBACK_RESPONSE). Please check Kibana logs and saved objects UI." >&2
    exit 1
  fi
else
  echo "Import failed with HTTP $HTTP_STATUS; not attempting fallback. Please check Kibana saved objects UI for details." >&2
  cat "$HTTP_BODY" || true
  rm -f "$HTTP_BODY"
  exit 1
fi
