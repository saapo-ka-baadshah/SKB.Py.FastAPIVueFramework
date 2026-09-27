# Introduction and Goals

## Requirements Overview

This repository provides a starter system composed of a FastAPI backend, a Vue frontend, and a Docker Compose development environment with authentication and observability infrastructure.

The approved deployment change set is defined in [deploy requirements](../specs/deploy/REQUIREMENTS.md):

- `DEPLOY-REQ-001`: replace Jaeger with Grafana Tempo for traces.
- `DEPLOY-REQ-002`: replace RabbitMQ with Kafka as the broker service.
- `DEPLOY-REQ-003`: orchestrate the existing backend and frontend in `deploy/docker-compose.web.yml`.
- `SYSTEM-REQ-001`: document the complete repository runtime in this system-level arc42 set.

The deployment configuration now defines Tempo, Kafka, and the two web application containers. The merged Compose model and configuration syntax have been checked, but images and live service health have not been verified because the Docker Engine is unavailable; see [Risks and Technical Debts](11_technical_risks.md).

## Quality Goals

| Priority | Quality goal | Architectural response |
|---|---|---|
| 1 | Reproducible development startup | Compose coordinates the web applications and required infrastructure using documented configuration. |
| 2 | Observable runtime | The Collector is configured to export traces to Tempo and expose metrics for Prometheus; Fluent Bit carries forwarded logs to Loki; Grafana provisions all three data sources. Application instrumentation remains unspecified. |
| 3 | Clear service boundaries | The Vue browser client, FastAPI API, message broker, identity service, and observability services have explicit network/configuration boundaries. |
| 4 | Maintainable system documentation | One repository-level arc42 description covers all relevant runtime components and marks unverified target state explicitly. |

## Stakeholders

| Role/Name    | Contact         | Expectations        |
|--------------|-----------------|---------------------|
| Application developer | Repository maintainers | Understand, run, and extend the backend, frontend, and local infrastructure. |
| Operator / platform developer | Repository maintainers | Configure and inspect local services and their dependencies. |
| Application user | Not specified | Use the Vue frontend; the API is separately reachable, while the current frontend does not call it. |
