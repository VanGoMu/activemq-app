#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker/docker-compose.yml"

echo "1/5 - Tearing down compose stack and removing anonymous volumes..."
docker compose -f "$COMPOSE_FILE" down -v --remove-orphans

echo "2/5 - Bringing services up (build + detached)..."
docker compose -f "$COMPOSE_FILE" up -d --build

echo "3/5 - Waiting for Elasticsearch to be ready (http://localhost:9200)..."
until curl -sSf http://localhost:9200/ >/dev/null 2>&1; do
  printf '.'; sleep 2
done
echo "\nElasticsearch reachable."

echo "4/5 - Waiting for Kibana to be ready (http://localhost:5601)..."
until curl -s -H 'kbn-xsrf: true' http://localhost:5601/api/status 2>/dev/null | grep -q 'available'; do
  printf '.'; sleep 2
done
echo "\nKibana is available."

echo "5/5 - Importing Kibana saved objects (data view)..."
if [ -x "./scripts/setup_kibana.sh" ]; then
  ./scripts/setup_kibana.sh
else
  echo "Note: make sure to run 'chmod +x scripts/setup_kibana.sh' then rerun this script to import Kibana saved objects."
  echo "Or run: ./scripts/setup_kibana.sh"
fi

echo "All done. Generate some test traffic to populate Filebeat/Elasticsearch. Example:" 
echo "  curl -s -X POST http://localhost:8000/send -H 'Content-Type: application/json' -d '{\"body\":\"hello\"}'"
