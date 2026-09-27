# Architecture Constraints

## Technical Constraints

- The backend is a Python FastAPI application in `backend/`; its initial versioned API prefix is `/api/v1`.
- The frontend is a Vue application built with Vite in `frontend/`.
- Deployment and infrastructure definitions are maintained under `deploy/`, with Compose currently split between `docker-compose.yml` and `docker-compose.web.yml`.
- The requested tracing backend is Grafana Tempo and the requested message broker is Kafka. Until implemented, the Compose baseline still declares Jaeger and RabbitMQ.
- Services in a Compose network use service discovery on that network. A host browser cannot generally resolve a Compose-only service name; browser-visible API addressing must be configured accordingly.
- Local credentials are supplied through environment configuration. Secrets must not be committed to the repository.
- `docs/arc42/arc42-template-EN.md` is the canonical arc42 template reference; the chapter files in this directory are the system-specific documentation, not separate service templates.

## Scope Constraints

- The backend currently specifies a health endpoint; no application-level Kafka producer/consumer contract or user workflow is defined in the application requirements.
- The current frontend is informational and does not require live backend data. Compose orchestration does not imply a new frontend feature or messaging workflow.
- Production availability, broker authentication/topology, trace retention, and external persistent storage are not specified. This documentation treats the requested deployment as a development setup unless implementation requirements establish otherwise.
