# Glossary

| Term         | Definition         |
|--------------|--------------------|
| API | Application Programming Interface; here, the HTTP interface exposed by FastAPI. |
| Compose network | Container network through which services discover each other by service name. |
| Kafka bootstrap server | Initial Kafka broker address used by a client to discover the cluster; `kafka:9092` inside Compose and `localhost:29092` on the host in this local setup. |
| KRaft | Kafka's built-in Raft-based metadata quorum mode; this setup uses one broker/controller node. |
| Loki | Log aggregation system configured in the Compose deployment. |
| OTLP | OpenTelemetry Protocol for transporting telemetry data. |
| OpenTelemetry Collector | Service that receives, processes, and exports telemetry. |
| Prometheus | Metrics collection and query service configured in the Compose deployment. |
| Tempo | Grafana distributed tracing backend configured for local WAL/block storage and queried through Grafana. |
| Trace | A correlated record of operations across one or more components. |
| Vue / Vite | Frontend framework and build/development tool used by this repository. |
