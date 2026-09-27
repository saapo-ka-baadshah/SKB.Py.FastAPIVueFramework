# Cross-cutting Concepts

## Service Discovery and Network Boundaries

Compose service names address containers on their shared Compose network. Host-published ports serve developer tools and browsers. A browser-side API URL must be host-resolvable or routed through a frontend proxy; an internal service name alone is insufficient.

## Configuration and Secrets

Service endpoints and environment-specific settings belong in Compose/environment configuration. Credentials must be supplied outside committed source. The current setup script generates Grafana, RabbitMQ, and Keycloak password variables; the Kafka replacement must remove or replace RabbitMQ-specific configuration with settings matching the selected Kafka mode. Whether Kafka requires authentication is unresolved.

## Telemetry Separation

Traces, metrics, and logs use separate configured paths: OTLP traces go through the Collector to the trace backend; Collector metrics are scraped by Prometheus; Docker-forwarded logs enter Fluent Bit and are sent to Loki. Replacing Jaeger with Tempo changes trace exporter and Grafana datasource configuration, not the independent log and metrics pipelines.

## Broker Client Configuration

Kafka service availability and application messaging are separate concerns. If application clients are present or added under a separately approved requirement, their bootstrap servers, security properties, and topic contract must be configured explicitly. The current project requirements do not mandate producer or consumer behavior.

## Readiness and Persistence

Compose startup ordering is not equivalent to service readiness. Use health checks and readiness conditions where consumers require a ready dependency. Local persistent volumes support stateful infrastructure where configured; development persistence does not establish production retention or recovery guarantees.

*\<explanation\>*
