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

## Readiness and Data

The OpenTelemetry Collector waits for Loki, Prometheus, and Tempo health. Tempo uses local WAL/block storage in the `tempo_data` named volume and retains blocks for 24 hours. Grafana provisions Prometheus, Loki, and Tempo datasources. Kafka stores broker state in `kafka_data`; Prometheus, Loki, Grafana, and Keycloak also use named volumes.

Normal Compose shutdown preserves named volumes. Recreate services with:

```sh
docker compose -f docker-compose.yml -f docker-compose.web.yml down
```

To remove persisted development data deliberately, append `-v`; doing so deletes the stack's named volumes. The lifecycle stop helper runs `down` without removing data.