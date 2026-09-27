# Architecture Decisions

This section records approved target direction and explicit unresolved choices. It does not state that the target configuration is already deployed.

## Replace Jaeger with Grafana Tempo

**Decision:** Use Tempo as the trace storage/query backend, keep the OpenTelemetry Collector as the OTLP ingress/export boundary, and provision Grafana to query Tempo.

**Rationale:** This directly satisfies `DEPLOY-REQ-001` and maintains the existing Collector/Grafana architecture. The Collector exporter and Grafana datasource must change together.

**Status:** Approved direction; implementation pending. Local Tempo storage mode and retention remain implementation details.

## Replace RabbitMQ with Kafka

**Decision:** Use Kafka as the replacement Compose broker and migrate broker-related deployment configuration.

**Rationale:** This directly satisfies `DEPLOY-REQ-002`. The request specifies a product replacement but not broker topology or application message semantics.

**Status:** Approved direction; implementation pending. Distribution, listener configuration, authentication, persistence, and any actual application clients remain unresolved. No producer/consumer workflow is implied.

## Orchestrate the Web Application in Compose

**Decision:** `docker-compose.web.yml` is the web application composition point for both FastAPI and Vue.

**Rationale:** One documented Compose workflow should build and start both services, with network connectivity and browser-reachable addresses configured explicitly (`DEPLOY-REQ-003`).

**Status:** Approved direction; implementation pending. Whether this file is standalone or layered with the infrastructure Compose file is unresolved.

## Maintain One System-Level arc42 Set

**Decision:** Extend the existing 12-chapter `docs/arc42/` system architecture rather than create duplicate arc42 documents per service.

**Rationale:** The repository already contains one chapter set and the canonical `arc42-template-EN.md`; a repository-level view can describe all runtime components and their relationships (`SYSTEM-REQ-001`).

**Status:** Assumption for planning. A request for separate arc42 documents per service would expand the documentation scope and should be confirmed before such documents are created.
