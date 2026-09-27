# Monorepo Requirements Index

This index assigns requirements to the repository's independently scoped units. Requirements belong with the unit that owns the behavior or deliverable. A requirement's approval status does not claim that its implementation is complete or verified.

| Unit | Scope | Requirements |
|---|---|---|
| Backend | FastAPI application, API versioning, health endpoint, tests, dependencies, and run documentation | [Backend requirements](backend/REQUIREMENTS.md) |
| Frontend | Vue application and frontend-owned behavior | [Frontend requirements](frontend/REQUIREMENTS.md) |
| Deploy / infra | Deployment and infrastructure-owned behavior | [Deploy / infra requirements](deploy/REQUIREMENTS.md); no requirements defined by the current source requests |

## Source Requests

The backend source request asks for a basic, well-documented FastAPI backend implementation, API routes grouped by version with initial version `v1`, and a `GET /api/v1/health` endpoint returning JSON with a `message` value of `OK` or `UNHEALTHY`. The backend requirements include tests and documented setup/run commands. Detailed backend acceptance criteria are in [backend/REQUIREMENTS.md](backend/REQUIREMENTS.md).

The frontend source request asks for a Vue frontend in `frontend/` whose initial page simply presents the application's backend and frontend technology stacks. The frontend requirements are in [frontend/REQUIREMENTS.md](frontend/REQUIREMENTS.md). Neither source request defines deployment or infrastructure behavior.