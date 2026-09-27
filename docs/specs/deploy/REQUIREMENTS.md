# Deploy / Infra Requirements

## Purpose

Define infrastructure and repository-wide architecture-documentation requirements for the requested observability and messaging substitutions and the web Compose deployment. Approval does not assert that the changes have been implemented or verified.

## Source

User request: “Replace jaeger with tempo, replace rabbitmq with Kafka. Add arc42 template for all. Also orchastrate the backend and frontend within docker-compose.web.yml”. This is a Phase 1 requirements definition; no application or deployment code is to be implemented as part of it.

## Unit Scope

These requirements cover deploy-owned Compose services and configuration, orchestration of the existing backend and frontend, and the repository-wide arc42 system architecture documentation. Backend application behavior remains scoped to the [backend requirements](../backend/REQUIREMENTS.md); frontend behavior remains scoped to the [frontend requirements](../frontend/REQUIREMENTS.md).

## Deployment Requirements

### DEPLOY-REQ-001: Replace Jaeger with Grafana Tempo

**Type:** Functional
**Status:** Approved

The observability deployment shall use Grafana Tempo for distributed trace storage and querying in place of Jaeger. The OpenTelemetry Collector and Grafana configuration shall be updated with the service so trace ingestion and user-facing trace queries use Tempo consistently.

**Acceptance criteria:**
- The deployment Compose configuration defines Tempo instead of Jaeger, and the deployment no longer contains Jaeger-specific service dependencies, endpoints, ports, or datasource configuration.
- The OpenTelemetry Collector accepts OTLP traces and exports them to Tempo over the Compose network using a protocol and endpoint supported by both configured components.
- Grafana provisions a Tempo datasource pointing to the Compose-reachable Tempo query endpoint; trace data received through the Collector can be queried from Grafana.
- Tempo's local storage and readiness behavior are configured for the repository's development Compose deployment, and dependent services wait for readiness where required.
- Existing log and metric pipelines remain configured independently of this tracing-backend replacement.

### DEPLOY-REQ-002: Replace RabbitMQ with Kafka

**Type:** Functional
**Status:** Approved

The deployment shall provide Kafka in place of RabbitMQ and update broker-related configuration and startup dependencies accordingly. Any existing application-side broker integration shall use Kafka connection settings rather than RabbitMQ-specific settings; this requirement does not introduce a new producer, consumer, or messaging workflow where none currently exists.

**Acceptance criteria:**
- The deployment Compose configuration defines Kafka in place of RabbitMQ, with a broker endpoint reachable by dependent services on the Compose network.
- Any service that currently depends on RabbitMQ is updated to depend on Kafka using an appropriate readiness condition; stale RabbitMQ service names and connection settings are removed from the deployment configuration and setup scripts.
- Existing broker clients, if present, are configured with Kafka bootstrap and any required security settings through documented configuration. No RabbitMQ-specific username/password variable remains as the Kafka configuration contract.
- The chosen local broker mode, required ports, persistence behavior, and authentication settings are documented so a developer can start and connect to the broker using the supported Compose workflow.
- If no broker client exists in the application, Compose broker availability and documented connection settings satisfy this requirement; adding application messaging behavior is not implied.

### DEPLOY-REQ-003: Orchestrate backend and frontend with web Compose

**Type:** Functional
**Status:** Approved

`deploy/docker-compose.web.yml` shall orchestrate runnable containers for the existing FastAPI backend and Vue frontend so both can be built and started through the documented Compose workflow.

**Acceptance criteria:**
- The web Compose configuration defines both the FastAPI backend and Vue frontend, using build contexts and container build instructions that resolve to the repository's existing `backend/` and `frontend/` projects.
- A single documented Compose invocation starts both application services and any required infrastructure services; service dependencies refer only to services available in that invocation or explicitly documented external prerequisites.
- The backend is reachable on its documented host/container address, and the frontend is served on a documented host port.
- If the frontend makes browser-side API requests, its configured API base URL or proxy makes the backend reachable from the browser; it does not rely on a Compose-only DNS name being resolved by the host browser.
- The Compose network and service configuration allow the frontend and backend to communicate where needed, and startup/shutdown does not require manually launching either application outside Compose.

## System Architecture Documentation Requirement

### SYSTEM-REQ-001: Repository-wide arc42 architecture coverage

**Type:** Non-functional
**Status:** Approved

The existing `docs/arc42/` documentation shall remain the single repository-level arc42 system architecture and shall be completed or extended to describe all relevant runtime components and their interactions, including the FastAPI backend, Vue frontend, Compose deployment, messaging, authentication, and observability stack. The existing `arc42-template-EN.md` remains the canonical template reference.

**Acceptance criteria:**
- The relevant arc42 chapters describe the system context, building blocks, runtime interactions, deployment mapping, cross-cutting configuration, architecture decisions, quality scenarios, risks, and glossary for the repository's complete runtime system.
- Both current and requested target components are identifiable. Jaeger/RabbitMQ are recorded only as current-state context where needed; Tempo/Kafka and backend/frontend web orchestration are identified as requested target state until implementation is verified.
- The documentation traces the requested architecture decisions to `DEPLOY-REQ-001` through `DEPLOY-REQ-003` and identifies unresolved implementation details instead of presenting assumptions as existing facts.
- The architecture is documented once at repository/system level. Separate arc42 documents for each service are not required unless explicitly requested.

## Assumptions

- **arc42 scope:** “Arc42 template for all” means completing the existing system-level arc42 chapters so they cover all relevant runtime components in this monorepo. The repository has a 12-chapter system template and no existing per-service arc42 documents. If the request means a separate full arc42 set for backend, frontend, and every infrastructure service, that is a different documentation scope; it does not block planning under the system-level interpretation.
- **Kafka mode:** Use a development-appropriate Compose Kafka deployment. The user has not specified a Kafka distribution, single- versus multi-broker topology, client authentication, or production durability requirements; those choices must be documented and confirmed during implementation.
- **Tempo mode:** Use local development storage and OTLP ingestion compatible with the current Collector. Production storage, retention, and high availability are not specified.
- **Web Compose invocation:** The request does not state whether `docker-compose.web.yml` must run standalone or be combined with `docker-compose.yml`. The implementation may use either a self-contained definition or a documented multi-file Compose invocation, provided required services resolve and the workflow is reproducible.
- **Application messaging:** The repository's current visible application requirements and source tree do not define an application producer/consumer workflow. Replacing the broker service does not itself authorize adding one.
- **Runtime status:** These requirements are approved based on the source request. Approval does not mean Compose/configuration updates or architecture-documentation edits are implemented or tested.

## Open Questions

- Should Kafka use a specific distribution/topology, require authentication, and persist local broker data?
- Should the web Compose file run by itself, or is a documented multi-file Compose invocation acceptable?
- Does “arc42 template for all” mean one system-level architecture covering the complete runtime (assumed), or separate arc42 documents per service?
- Is the target deployment development-only, or should production-grade Tempo/Kafka persistence, security, and availability be specified?

None of these questions blocks planning Phase 2 under the assumptions above. Kafka deployment/security choices and the supported Compose invocation must be resolved before implementation acceptance criteria are finalized.

## Traceability

| Requirement | Source | Intended implementation/documentation area |
|---|---|---|
| DEPLOY-REQ-001 | User request: “Replace jaeger with tempo” | `deploy/docker-compose.yml`; `deploy/configs/otel-collector/otel-collector-config.yaml`; Grafana datasource provisioning; Tempo configuration |
| DEPLOY-REQ-002 | User request: “replace rabbitmq with Kafka” | `deploy/docker-compose.yml`; broker-dependent Compose services; environment/setup scripts; application broker configuration if present |
| DEPLOY-REQ-003 | User request: “orchastrate the backend and frontend within docker-compose.web.yml” | `deploy/docker-compose.web.yml`; backend and frontend container build/run configuration |
| SYSTEM-REQ-001 | User request: “Add arc42 template for all” | Existing chapters under `docs/arc42/`; canonical reference `docs/arc42/arc42-template-EN.md` |