# Cross-cutting Concepts

## Service Discovery and Network Boundaries

Compose service names address containers on their shared Compose network. Host-published ports serve developer tools and browsers. A browser-side API URL must be host-resolvable or routed through a frontend proxy; an internal service name alone is insufficient.

## Configuration and Secrets

Service endpoints and environment-specific settings belong in Compose/environment configuration. `deploy/0_create_env.sh` generates Grafana and Keycloak passwords in the Git-ignored `deploy/.env`; GitHub package credentials remain optional. Kafka has no authentication variables because this local configuration uses plaintext without client authentication.

## Telemetry Separation

Traces, metrics, and logs use separate configured paths: OTLP traces go through the Collector to Tempo; Collector metrics are scraped by Prometheus; Docker-forwarded logs enter Fluent Bit and are sent to Loki. The trace backend, Collector exporter, and Grafana datasource are configured together; log and metrics pipelines remain independent.

## Broker Client Configuration

Kafka service availability and application messaging are separate concerns. The broker advertises `kafka:9092` inside Compose and `localhost:29092` to host tools, with its host listener bound to loopback. If application clients are added under a separately approved requirement, their security properties and topic contract must be configured explicitly. The current project requirements do not mandate producer or consumer behavior.

## Readiness and Persistence

Compose startup ordering is not equivalent to service readiness. Collector waits for healthy Loki, Prometheus, and Tempo; Grafana waits for those data sources and for Fluent Bit to start. Tempo uses named-volume WAL/block storage with 24-hour retention; Kafka and other stateful services also use named volumes. These local settings do not establish production retention, security, or recovery guarantees.

*\<explanation\>*
