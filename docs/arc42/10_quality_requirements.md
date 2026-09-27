# Quality Requirements

## Quality Requirements Overview

| Quality | Importance | System response |
|---|---|---|
| Reproducible development startup | High | Provide one documented two-file Compose invocation that builds the backend and frontend and resolves infrastructure services. The merged model parses; image and runtime checks remain unverified. |
| Diagnosability | High | Preserve logs and metrics pipelines; the Collector-to-Tempo trace path and Grafana datasource are configured but have not been exercised with live traces. |
| Configurability | Medium | Keep service endpoints and required credentials in ignored environment configuration; Kafka intentionally uses unauthenticated plaintext only for loopback-bound local development. |
| Change traceability | Medium | Keep one system-level arc42 description aligned with configured files and distinguish configuration facts from unverified runtime behavior. |

No quantitative throughput, startup-time, retention, availability, or recovery target is specified. The local stack is not a production availability commitment.

## Quality Scenarios

| Scenario | Stimulus | Expected response |
|---|---|---|
| Start the web application | A developer invokes the documented Compose workflow from `deploy/`. | Backend and frontend are built and served at ports 8080 and 8081 without separate host processes; this behavior is configured but requires Docker runtime validation. |
| Inspect a distributed trace | An OTLP-capable service emits a trace to the Collector. | The Collector exports it to Tempo and Grafana can query it; configuration agrees, but live trace delivery remains unverified. |
| Inspect a log | A container emits a log through Docker's configured forward driver. | Fluent Bit receives it and forwards it to Loki for querying in Grafana. |
| Connect to the local broker | A developer or future broker client connects using its network location. | Compose clients use `kafka:9092`; host tools use `localhost:29092`. No application broker client currently exists. |
| Read the architecture | A developer consults the arc42 chapters. | They can identify every configured runtime block, key communication paths, unimplemented application integrations, and remaining verification/production limitations. |
