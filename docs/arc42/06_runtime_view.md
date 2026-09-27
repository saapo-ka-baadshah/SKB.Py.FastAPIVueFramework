# Runtime View

## Compose Startup

The developer starts the documented Compose workflow. Compose builds and starts the FastAPI and Vue services and any infrastructure selected for that invocation. The web-facing services join a network that can reach required dependencies. Readiness dependencies should be expressed only where a consumer requires a dependency to be ready; starting a container alone does not prove application-level readiness.

This is the target behavior of `DEPLOY-REQ-003`; the existing `docker-compose.web.yml` defines only `webapi` and references RabbitMQ, Keycloak, and Grafana by `depends_on`.

## Browser Request

1. The browser requests the Vue frontend over its published host port.
2. If the page calls the API, browser code uses its configured API URL or same-origin proxy to reach FastAPI. Compose service DNS is usable by containers on the Compose network, not by the host browser.
3. FastAPI handles the versioned API request and returns an HTTP response. The initial defined endpoint is `GET /api/v1/health`.

The initial Vue page is informational and does not currently require an API call; the API path describes the integration boundary, not an existing frontend feature.

## Trace Ingestion and Query (Target)

1. An instrumented application sends traces using OTLP to the OpenTelemetry Collector.
2. The Collector exports traces to Tempo over the Compose network.
3. Grafana queries Tempo through its provisioned datasource.

The current Collector exporter and Grafana datasource target Jaeger. Both must migrate together for the target path in `DEPLOY-REQ-001` to work.

## Metrics and Logs (Existing Configuration)

The Collector exposes Prometheus-format metrics for Prometheus scraping. Container logs forwarded through the Docker Fluent Forward logging driver enter Fluent Bit and are sent to Loki. Grafana has Prometheus and Loki datasources. These paths are independent from the trace-store substitution.

## Message Exchange (Conditional)

If a future application component publishes or consumes messages, it connects to Kafka using the configured bootstrap endpoint, exchanges messages according to an explicitly defined application contract, and exposes relevant connection settings through deployment configuration. The repository does not currently define such an application scenario; the broker service replacement does not create one.
