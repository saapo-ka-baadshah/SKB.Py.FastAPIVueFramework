# Quality Requirements

## Quality Requirements Overview

| Quality | Importance | System response |
|---|---|---|
| Reproducible development startup | High | Provide a documented Compose invocation that starts the backend and frontend and resolves required dependencies. |
| Diagnosability | High | Preserve logs and metrics pipelines; route OTLP traces through the Collector to Tempo and make them queryable in Grafana. |
| Configurability | Medium | Keep service endpoints and credentials configurable without committing secrets; use Kafka settings rather than RabbitMQ settings after migration. |
| Change traceability | Medium | Keep a single system-level arc42 description aligned with approved requirements and distinguish current from target state. |

No quantitative throughput, startup-time, retention, availability, or recovery target is specified. The local stack is not a production availability commitment.

## Quality Scenarios

| Scenario | Stimulus | Expected response |
|---|---|---|
| Start the web application | A developer invokes the documented Compose workflow from the documented directory. | Both frontend and backend build/start without manually launching either process; published endpoints and required infrastructure are reachable as documented. |
| Inspect a distributed trace (target) | An instrumented service emits an OTLP trace. | The Collector exports it to Tempo and a developer can query it through Grafana. |
| Inspect a log | A container emits a log through Docker's configured forward driver. | Fluent Bit receives it and forwards it to Loki for querying in Grafana. |
| Replace the broker | A broker-dependent service starts with Kafka configured. | It resolves the Kafka bootstrap endpoint and does not require RabbitMQ-only service names or credentials. If no application broker client exists, service readiness/configuration is the scope of this scenario. |
| Read the architecture | A developer consults the arc42 chapters. | They can identify every relevant runtime block, its current/target status, key communication paths, and unresolved deployment choices. |
