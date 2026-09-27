# Monorepo Requirements Index

This index assigns requirements to the repository's independently scoped units. Requirements belong with the unit that owns the behavior or deliverable. A requirement's approval status does not claim that its implementation is complete or verified.

| Unit | Scope | Requirements |
|---|---|---|
| Backend | FastAPI application, API versioning, health endpoint, tests, dependencies, and run documentation | [Backend requirements](backend/REQUIREMENTS.md) |
| Frontend | Vue application and frontend-owned behavior | [Frontend requirements](frontend/REQUIREMENTS.md) |
| Deploy / infra | Deployment/infrastructure behavior and repository-wide system architecture documentation | [Deploy / infra requirements](deploy/REQUIREMENTS.md): DEPLOY-REQ-001 through DEPLOY-REQ-003; SYSTEM-REQ-001 |

## Source Requests

The backend source request asks for a basic, well-documented FastAPI backend implementation, API routes grouped by version with initial version `v1`, and a `GET /api/v1/health` endpoint returning JSON with a `message` value of `OK` or `UNHEALTHY`. The backend requirements include tests and documented setup/run commands. Detailed backend acceptance criteria are in [backend/REQUIREMENTS.md](backend/REQUIREMENTS.md).

The frontend source requests ask for a Vue frontend in `frontend/` whose initial page simply presents the application's backend and frontend technology stacks, and developer-facing guidance on correct JSDoc usage for JavaScript and Vue code. The frontend requirements are in [frontend/REQUIREMENTS.md](frontend/REQUIREMENTS.md).

The deployment/system source request asks to replace Jaeger with Grafana Tempo and RabbitMQ with Kafka, orchestrate the existing FastAPI backend and Vue frontend in `deploy/docker-compose.web.yml`, and extend the arc42 documentation to cover the system. Its requirements and acceptance criteria are in [deploy/REQUIREMENTS.md](deploy/REQUIREMENTS.md). The single system-level arc42 interpretation is assumed for planning; separate per-service documentation remains an open clarification, not a blocker.