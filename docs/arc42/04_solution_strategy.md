# Solution Strategy

| Concern | Strategy | State / traceability |
|---|---|---|
| API implementation | Keep the backend as a versioned FastAPI application. | Existing system baseline; backend requirements. |
| Web client | Keep the Vue/Vite frontend and run it alongside the backend through the web Compose workflow. | Requested target; `DEPLOY-REQ-003`. |
| Trace collection and storage | Keep OTLP ingestion at the OpenTelemetry Collector and route traces to Grafana Tempo, with Grafana provisioned to query Tempo. | Requested target; `DEPLOY-REQ-001`. |
| Metrics and logs | Preserve the existing Collector-to-Prometheus scrape path and Fluent Bit-to-Loki path. | Existing Compose/config baseline; avoid coupling these to the trace-store migration. |
| Messaging | Replace the RabbitMQ service with Kafka and migrate dependent connection/readiness configuration. Do not invent application messaging behavior. | Requested target; `DEPLOY-REQ-002`. |
| Authentication | Retain Keycloak as a separately deployed identity service until an application authentication contract is specified. | Existing Compose baseline; integration not yet documented. |
| Architecture documentation | Use one system-level arc42 description for all runtime blocks and interactions, maintaining the supplied English template as reference. | Requested target; `SYSTEM-REQ-001`. |

Target-state decisions are requirements, not claims about the currently running deployment. See [Architecture Decisions](09_architecture_decisions.md) and [Risks and Technical Debts](11_technical_risks.md) for unresolved choices.
