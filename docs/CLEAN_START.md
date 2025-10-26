Clean start and Kibana preconfiguration

This document explains how to start the entire stack from a truly clean state (no anonymous Docker volumes) and import a preconfigured Kibana data view for `filebeat-*`.

Files added:

- `scripts/recreate.sh` — stops the compose stack, removes anonymous volumes, brings the services up (build), waits for Elasticsearch and Kibana, then imports Kibana saved objects.
- `scripts/setup_kibana.sh` — imports `kibana/filebeat-data-view.ndjson` into Kibana using the saved_objects import API.
- `kibana/filebeat-data-view.ndjson` — a minimal saved object (data view / index pattern) for `filebeat-*` which sets `@timestamp` as the time field.

How to use

1. Make the scripts executable (one-time):

```bash
cd /home/epicuro/repo/activemq-app
chmod +x scripts/recreate.sh scripts/setup_kibana.sh
```

2. Run the recreate script. This will tear down any existing compose stack and anonymous volumes, build images, start services, wait for ES/Kibana, and then import the Kibana data view:

```bash
./scripts/recreate.sh
```

3. Generate test traffic after the stack is up (example):

```bash
curl -s -X POST http://localhost:8000/send -H 'Content-Type: application/json' -d '{"body":"hello from test"}'
```

4. Open Kibana (http://localhost:5601), go to Discover and select the `filebeat-*` data view. If the saved object import worked, the data view should exist and `@timestamp` will be registered as the time field.

Notes and caveats

- The import uses Kibana's `api/saved_objects/_import` endpoint which requires Kibana to be reachable at `http://localhost:5601` and to accept the import without authentication. If your Kibana is secured, you'll need to provide credentials or use the appropriate API tokens.
- The NDJSON added is minimal and lets Kibana create the data view. You can extend `kibana/filebeat-data-view.ndjson` with additional saved objects (dashboards, visualizations, index patterns). To create these exports, use Kibana > Stack Management > Saved Objects > Export.
- `docker compose down -v` removes anonymous volumes created by compose; named volumes defined explicitly in `docker-compose.yml` will also be removed when using the same compose project name. If you want to preserve named volumes, do not use `-v`.

If you want, I can also:
- Add additional prebuilt dashboards and visualizations (export NDJSON from your Kibana and commit it).
- Add healthchecks and longer wait loops to the scripts to make the start process more robust.

