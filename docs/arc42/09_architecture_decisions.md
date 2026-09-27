# Architecture Decisions

This section records the configured local architecture and the remaining verification gap. The merged Compose model and edited YAML files parse, but the Docker Engine was unavailable for image builds or live service checks.

## Replace Jaeger with Grafana Tempo

**Decision:** Use Tempo as the trace storage/query backend, keep the OpenTelemetry Collector as the OTLP ingress/export boundary, and provision Grafana to query Tempo.

**Rationale:** This directly satisfies `DEPLOY-REQ-001` and maintains the existing Collector/Grafana architecture. The Collector exporter and Grafana datasource must change together.

**Status:** Configured: Tempo 2.7.2 uses local WAL/block storage, a 24-hour block retention, OTLP receivers on 4317/4318, and query/readiness on 3200. Collector export and Grafana datasource endpoints agree. Live ingestion/query verification remains pending.

## Replace RabbitMQ with Kafka

**Decision:** Use Kafka as the replacement Compose broker and migrate broker-related deployment configuration.

**Rationale:** This directly satisfies `DEPLOY-REQ-002`. The request specifies a product replacement but not broker topology or application message semantics.

**Status:** Configured: Apache Kafka 3.9.1 runs as a single-node KRaft broker with a named data volume, `kafka:9092` internal and loopback `localhost:29092` host listeners, and no TLS or client authentication. This is for trusted local development only. No producer/consumer workflow is implied; broker health remains unverified at runtime.

## Orchestrate the Web Application in Compose

**Decision:** `docker-compose.web.yml` is the web application composition point for both FastAPI and Vue.

**Rationale:** One documented Compose workflow should build and start both services, with network connectivity and browser-reachable addresses configured explicitly (`DEPLOY-REQ-003`).

**Status:** Configured: the overlay defines backend and frontend builds, loopback ports 8080 and 8081, and app health checks. The supported invocation combines both Compose files from `deploy/`; the frontend remains static and makes no API call. Container builds and health remain unverified at runtime.

## Maintain One System-Level arc42 Set

**Decision:** Extend the existing 12-chapter `docs/arc42/` system architecture rather than create duplicate arc42 documents per service.

**Rationale:** The repository already contains one chapter set and the canonical `arc42-template-EN.md`; a repository-level view can describe all runtime components and their relationships (`SYSTEM-REQ-001`).

**Status:** Current documentation decision. One repository-level chapter set covers all system blocks; `arc42-template-EN.md` remains unchanged as the canonical reference. This satisfies `SYSTEM-REQ-001` without per-service copies.
