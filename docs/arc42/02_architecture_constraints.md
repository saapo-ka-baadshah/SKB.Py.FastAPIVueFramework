# Architecture Constraints

## Technical Constraints

- The backend is a Python FastAPI application in `backend/`; its initial versioned API prefix is `/api/v1`.
- The frontend is a Vue application built with Vite in `frontend/`.
- Deployment and infrastructure definitions are maintained under `deploy/`, with Compose currently split between `docker-compose.yml` and `docker-compose.web.yml`.
- The Compose configuration defines Grafana Tempo 2.7.2 and Apache Kafka 3.9.1 in single-node KRaft mode. Kafka is plaintext without authentication and is intended only for trusted local development.
- The supported full-stack invocation combines `deploy/docker-compose.yml` and `deploy/docker-compose.web.yml` from `deploy/`; the web file is an overlay, not a standalone project.
- Kafka advertises `kafka:9092` to Compose clients and `localhost:29092` to host clients. The host listener is published on loopback only.
- Services in a Compose network use service discovery on that network. A host browser cannot generally resolve a Compose-only service name; browser-visible API addressing must be configured accordingly.
- Grafana and Keycloak credentials are supplied through `deploy/.env`. GitHub package credentials are optional and are not used by the container builds. Secrets must not be committed to the repository.
- `docs/arc42/arc42-template-EN.md` is the canonical arc42 template reference; the chapter files in this directory are the system-specific documentation, not separate service templates.

## Scope Constraints

- The backend currently specifies a health endpoint; no application-level Kafka producer/consumer contract or user workflow is defined in the application requirements.
- The current frontend is informational and does not require live backend data. Compose orchestration does not imply a new frontend feature or messaging workflow.
- The configured broker is unauthenticated single-node plaintext and Tempo uses local 24-hour retention. Production availability, broker security/HA, backups, and external trace storage are out of scope; these local defaults are not production recommendations.
