# Runtime View

## Compose Startup

The developer runs `docker compose -f docker-compose.yml -f docker-compose.web.yml up --build -d` from `deploy/`. The merged model defines the FastAPI and Vue services with the infrastructure. Collector waits for healthy Loki, Prometheus, and Tempo; Grafana waits for those data sources and for Fluent Bit to start. The two app services have independent health checks and no dependency on Kafka, Keycloak, or Grafana.

The merged Compose configuration parses successfully. Image builds and live startup remain unverified because the Docker Engine is unavailable. This workflow implements the configured scope of `DEPLOY-REQ-003` without changing application behavior.

## Browser Request

1. The browser requests the Vue frontend at `http://127.0.0.1:8081/`.
2. The Vue page is static and currently makes no API call. FastAPI is independently reachable at `http://127.0.0.1:8080`; its initial defined endpoint is `GET /api/v1/health`.
3. Any future browser request must use a host-resolvable API URL or same-origin proxy; Compose service DNS is not resolvable by the host browser.

The API is directly available to browser clients, but no frontend-to-backend interaction is currently implemented.

## Trace Ingestion and Query (Configured)

1. An OTLP-capable client sends traces to the Collector at OTLP gRPC port 4317 or HTTP port 4318.
2. The Collector exports traces to `tempo:4317` over OTLP/gRPC after Tempo is healthy.
3. Grafana's provisioned Tempo datasource queries `http://tempo:3200`.

Tempo stores data on local WAL/block paths backed by the `tempo_data` volume and compacts blocks with 24-hour retention. This pipeline is configured but has not been verified with live trace ingestion.

## Metrics and Logs (Existing Configuration)

The Collector exposes Prometheus-format metrics for Prometheus scraping. Container logs forwarded through the Docker Fluent Forward logging driver enter Fluent Bit and are sent to Loki. Grafana provisions Prometheus, Loki, and Tempo datasources. Metrics and logs remain independent from the trace-store path.

## Message Exchange (Conditional)

No current application component publishes or consumes messages. Future clients on the Compose network can use `kafka:9092`; host tools can use `localhost:29092`. The broker is single-node, plaintext, and unauthenticated for trusted local development only. A future message contract requires a separate application requirement.
