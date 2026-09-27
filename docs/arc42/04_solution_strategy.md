# Solution Strategy

| Concern | Strategy | State / traceability |
|---|---|---|
| API implementation | Keep the backend as a versioned FastAPI application. | Existing system baseline; backend requirements. |
| Web client | Build the existing Vue/Vite static page and FastAPI service in the two-file Compose workflow; publish them on loopback ports 8081 and 8080. | Configured; merged Compose model parses. Image build and runtime checks remain unverified. `DEPLOY-REQ-003`. |
| Trace collection and storage | Keep OTLP ingress at the Collector, export traces to Tempo over OTLP/gRPC, and provision Grafana to query Tempo. | Configured with local storage and 24-hour retention. Runtime ingestion/query remains unverified. `DEPLOY-REQ-001`. |
| Metrics and logs | Preserve the existing Collector-to-Prometheus scrape path and Fluent Bit-to-Loki path. | Existing Compose/config baseline; avoid coupling these to the trace-store migration. |
| Messaging | Provide a single-node KRaft Kafka broker with internal and loopback host listeners; do not invent application messaging behavior. | Configured with persistent local state and no client authentication. No application client exists. `DEPLOY-REQ-002`. |
| Authentication | Retain Keycloak as a separately deployed identity service until an application authentication contract is specified. | Configured service; application integration remains unspecified. |
| Architecture documentation | Use one system-level arc42 description for all runtime blocks and interactions, maintaining the supplied English template as reference. | Documented across all 12 chapters; `SYSTEM-REQ-001`. |

The container definitions and merged Compose model are configured, but services have not been started because the Docker Engine is unavailable. See [Architecture Decisions](09_architecture_decisions.md) and [Risks and Technical Debts](11_technical_risks.md) for the remaining verification gap and production non-goals.
