# Monorepo Requirements Index

This index assigns requirements to the repository's independently scoped units. Requirements belong with the unit that owns the behavior or deliverable. A requirement's approval status does not claim that its implementation is complete or verified.

| Unit | Scope | Requirements |
|---|---|---|
| Backend | FastAPI application, API versioning, health endpoint, tests, dependencies, and run documentation | [Backend requirements](backend/REQUIREMENTS.md) |
| Frontend | Vue application and frontend-owned behavior | [Frontend requirements](frontend/REQUIREMENTS.md); no requirements defined by the current source request |
| Deploy / infra | Deployment and infrastructure-owned behavior | [Deploy / infra requirements](deploy/REQUIREMENTS.md); no requirements defined by the current source request |

## Source Request

The source request asks for a basic, well-documented FastAPI backend implementation, API routes grouped by version with initial version `v1`, and a `GET /api/v1/health` endpoint returning JSON with a `message` value of `OK` or `UNHEALTHY`. The backend requirements include tests and documented setup/run commands. No frontend or deploy/infra features are specified. Detailed backend acceptance criteria are in [backend/REQUIREMENTS.md](backend/REQUIREMENTS.md).