# Infrastructure Usage

This guide starts the FastAPI backend, static Vue frontend, and supporting local infrastructure as one Docker Compose project. The stack is for trusted local development only.

## Prerequisites

- Docker Desktop or another running Docker Engine with the Compose v2 plugin.
- A supported Docker image registry connection for the first image pulls.

Python and Node.js are not required on the host for the container workflow. The frontend build uses Node.js 22 in its image; the backend image uses Python 3.12.

## Configure and Start

From the repository root, create the local Grafana and Keycloak passwords:

```sh
./deploy/0_create_env.sh
```

The script writes `deploy/.env`, which is ignored by Git. It recovers the cluster ID from an existing Kafka data volume or generates one for a fresh setup, then persists it so subsequent runs keep the same cluster identity. GitHub package credentials are not needed for these images. The retained optional credential helper can be invoked with `./deploy/0_create_env.sh --github`.

Start and build the entire stack from `deploy/`:

```sh
cd deploy
docker compose -f docker-compose.yml -f docker-compose.web.yml up --build -d
```

The web Compose file is an overlay and is not intended to run alone. The same pair is used by `./deploy/1_start_dev.sh` and `./deploy/2_deploy.sh` when invoked from any working directory.

## Endpoints

| Service | Host endpoint | Notes |
|---|---|---|
| Vue frontend | `http://127.0.0.1:8081/` | Static production build served by Nginx; it does not currently call the API. |
| FastAPI | `http://127.0.0.1:8080` | Health: `/api/v1/health`. |
| Grafana | `http://127.0.0.1:3000` | Username `admin`; password is `GRAFANA_ADMIN_PASSWORD` in `deploy/.env`. |
| Prometheus | `http://127.0.0.1:9090` | Scrapes the Collector metrics endpoint. |
| Loki | `http://127.0.0.1:3100` | Log storage/query API. |
| Tempo | `http://127.0.0.1:3200` | Query/readiness API; readiness is `/ready`. OTLP receivers are available to containers on ports 4317 (gRPC) and 4318 (HTTP). |
| Kafka | `localhost:29092` | Host bootstrap address, bound to loopback. |
| Keycloak | `http://127.0.0.1:18080` | Development mode; no application authentication integration is configured. |

From another service on the Compose network, Kafka's bootstrap address is `kafka:9092`. Its controller listener is internal and is not published. The Kafka listeners use plaintext with no client authentication or encryption. This single-node development broker is not appropriate for shared/untrusted networks or production.

The app ports, Tempo query port, and Kafka host listener are explicitly loopback-bound. Existing observability, Keycloak, and Fluent Bit ports retain Compose's default host binding and may be reachable from other machines on the host network; use this stack only on a trusted development machine and do not expose it to a shared network.

The current Vue page makes no API requests. If browser-side API calls are added later, configure a browser-resolvable host URL or a same-origin proxy; the browser cannot resolve Compose-only names such as `backend`.

## Backend Logs in Loki

Backend application logs are exported over OTLP/gRPC to the Collector at `otel-collector:4317` using `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`; the backend service identity is `OTEL_SERVICE_NAME=backend`. The Collector forwards logs to Loki. Backend logs also remain on backend stdout (`docker compose logs backend`), but Loki's container stdout/stderr contains Loki diagnostics, not these application events.

With the stack running, ping the health endpoint to generate an application event:

```sh
curl -fsS http://127.0.0.1:8080/api/v1/health
```

The response should be `{"message":"OK"}`. Query Loki's HTTP API for the event:

```sh
curl -G -sS 'http://127.0.0.1:3100/loki/api/v1/query_range' \
  --data-urlencode 'query={service_name="backend"} |= "Health check endpoint called."' \
  --data-urlencode 'limit=20'
```

The result should include the `service_name="backend"` stream label, event timestamp, health message, and INFO severity (`severity_text`). The Collector also attempts to map severity to `log.level`; its current transform matches `Information`, while Python emits `INFO`, so do not rely on a `log_level` metadata field without validating that mapping. The same query is usable in Grafana Explore with the Loki datasource.

The backend Compose health check also calls this endpoint every 10 seconds, so several matching events can be separate health-check requests rather than duplicate delivery. A live request and Loki query have returned the event with no duplicates observed. The proposed 10-second visibility target was not measured, however, and should not be treated as a verified timing guarantee.

After changing backend logging code or its Compose environment, rebuild and recreate the backend from `deploy/`:

```sh
docker compose -f docker-compose.yml -f docker-compose.web.yml up --build -d backend
```

After changing Collector configuration, recreate the Collector so it loads the mounted file:

```sh
docker compose -f docker-compose.yml -f docker-compose.web.yml up -d --force-recreate otel-collector
```

For diagnosis, inspect backend and pipeline component output, not Loki output as proof of delivery:

```sh
docker compose -f docker-compose.yml -f docker-compose.web.yml logs --tail=100 backend otel-collector loki
```

Delivery while the Collector or Loki is unavailable is not guaranteed. The health endpoint should still return its normal response because log export is batched, but diagnostic visibility during a sustained Collector outage has not been verified. A separate tracing limitation remains: the app reads `OTEL_EXPORTER_OTLP_ENDPOINT`, but the web Compose file sets only the logs-specific endpoint. Traces therefore use the OTLP exporter default `localhost:4317` inside the backend container and produce `UNAVAILABLE` errors; this does not change the backend log route described above.

## Readiness and Data

The OpenTelemetry Collector waits for Loki, Prometheus, and Tempo health. Tempo uses local WAL/block storage in the `tempo_data` named volume and retains blocks for 24 hours. Grafana provisions Prometheus, Loki, and Tempo datasources. Kafka stores broker state in `kafka_data`; Prometheus, Loki, Grafana, and Keycloak also use named volumes.

Normal Compose shutdown preserves named volumes. Recreate services with:

```sh
docker compose -f docker-compose.yml -f docker-compose.web.yml down
```

To remove persisted development data deliberately, append `-v`; doing so deletes the stack's named volumes. The lifecycle stop helper runs `down` without removing data.