# PLAN-006: Deployment Modernization

## Goal

Implement DEPLOY-REQ-001 through DEPLOY-REQ-003 and bring the existing system-level arc42 chapters into agreement with the verified implementation. Replace Jaeger with Grafana Tempo and RabbitMQ with Apache Kafka, and make the existing FastAPI and Vue applications buildable and runnable through one documented Compose workflow. Keep application messaging and frontend API behavior unchanged.

## Feature References

- Requirements: [monorepo requirements index](../specs/REQUIREMENTS.md), [deploy / infra requirements](../specs/deploy/REQUIREMENTS.md), DEPLOY-REQ-001 through DEPLOY-REQ-003 and SYSTEM-REQ-001.
- Application contracts: [backend requirements](../specs/backend/REQUIREMENTS.md) and [frontend requirements](../specs/frontend/REQUIREMENTS.md).
- Architecture baseline: all 12 system-level chapters in `docs/arc42/`; `arc42-template-EN.md` remains the canonical reference.

## Findings and Scope

- `deploy/` is currently untracked in the worktree. Treat its existing files as user-provided content: make focused changes in place, preserve files and useful behavior, and do not replace or remove deployment files wholesale.
- `deploy/docker-compose.yml` currently defines Jaeger, RabbitMQ, and the observability services. The Collector trace exporter and Grafana datasource still target Jaeger. Prometheus is invoked with `/etc/prometheus/prometheus.yml` but its mounted file is `/etc/prometheus/prometheus.yaml`.
- `deploy/docker-compose.web.yml` defines only `webapi`, references a root Dockerfile that is absent, and depends on RabbitMQ, Keycloak, and Grafana without defining those services itself. `deploy/2_deploy.sh` and `deploy/3_stop.sh` name an absent `docker-compose.cleanwebapi.yml`.
- No Dockerfiles or broker client code exist. `backend/requirements.txt` contains only FastAPI/Uvicorn and test dependencies; the backend serves the versioned health route. `frontend/` is a static Vue/Vite page and its usage documentation confirms it makes no backend calls.
- Phase 1 modified all 12 `docs/arc42/` chapters and marked requested architecture as target state. Preserve that work and refine it only where verified deployment details or current/target status need correction. Do not create per-service arc42 copies.

## Scope and Decisions

- **Compose invocation:** support one coherent full-stack command, run from `deploy/`: `docker compose -f docker-compose.yml -f docker-compose.web.yml up --build -d`. The base file supplies infrastructure and the overlay supplies both application services, so every service reference resolves. Update helper scripts and docs to use this same pair and working directory. The web file is an overlay, not a promised standalone configuration.
- **Kafka:** use the official Apache `apache/kafka` image at a pinned release, configured as a single-node KRaft broker/controller for local development. Use an internal bootstrap listener `kafka:9092` and a host listener bound to `127.0.0.1:29092` and advertised as `localhost:29092`; do not publish the controller listener. Persist broker state in a named volume and set single-node replication factors to one. Configure no SASL or TLS: document that plaintext has no client authentication/encryption and is suitable only for trusted local development, not a shared network or production. Add a broker API health check. No current application service needs Kafka, so do not add Kafka dependencies, clients, topics, producers, or consumers.
- **Tempo:** use a pinned official Grafana Tempo image with single-process local filesystem storage (WAL and blocks) on a named volume and explicitly bounded local retention (24 hours unless image/config constraints require a documented equivalent). Use OTLP receivers on container ports 4317 and 4318 and the query/readiness HTTP API on 3200; publish only the local query port if direct developer inspection is useful. Configure `/ready` readiness and a Compose health check using a probe supported by the selected image; make the Collector wait for Tempo readiness. Export Collector traces to `tempo:4317` over OTLP/gRPC with local-development insecure transport. Provision Grafana's Tempo datasource at `http://tempo:3200`. Keep Loki and Prometheus pipelines independent.
- **Web containers:** add `backend/Dockerfile` and `frontend/Dockerfile`. Build the API from `backend/` on a supported Python base, install `requirements.txt`, and run Uvicorn on `0.0.0.0:8080`; serve the Vite production build from a small Nginx runtime on container port 80. Publish backend `8080` and frontend `8081` on localhost. Add context-local `.dockerignore` files for Python caches/virtual environments and Node modules/build output. Add health checks for the API health endpoint and the static frontend. The current Vue page makes no API requests, so do not add an API proxy or frontend feature; document that any future browser request needs a browser-resolvable URL or same-origin proxy.
- **Service dependencies/readiness:** use health conditions only where a service consumes another service's readiness. At minimum, Collector waits for Loki, Prometheus, and Tempo to be healthy; Grafana waits for the data sources it queries to be ready. Kafka has its own readiness check but no application dependency in the current repository. The web apps do not wait for Keycloak, Grafana, or Kafka because no such integration exists. Retain startup ordering for other real existing dependencies, remove dangling/unneeded `depends_on` references, and correct the Prometheus config path. Do not add health checks that depend on tools absent from the selected container image.
- **Environment and scripts:** remove the RabbitMQ password variable/generation; unauthenticated local Kafka requires no broker credential. Keep Grafana and Keycloak secrets out of source control. Make GitHub package credentials optional for Compose startup because the new app builds do not consume the old Compose build secrets; preserve any useful credential helper behavior rather than deleting unrelated user tooling. Resolve helper-script paths relative to `deploy/` and align start, deploy, and stop with the supported two-file Compose invocation.
- **Documentation state:** document these as development-local choices, not production recommendations. Update the root README with a link to the infrastructure guide; place complete prerequisites, exact commands, host/container endpoints, local persistence/authentication implications, and shutdown behavior in `docs/usage/infra/USAGE.md`.

## Expected Files

| Path | Purpose |
|---|---|
| `deploy/docker-compose.yml` | Replace Jaeger and RabbitMQ; add Tempo and official Kafka services, volumes, listeners, health/readiness, and correct Prometheus config path. |
| `deploy/docker-compose.web.yml` | Define FastAPI and Vue builds, published ports, health checks, and the shared network without dangling service dependencies. |
| `deploy/configs/tempo/tempo.yaml` | Configure Tempo's local storage, OTLP receivers, query endpoint, and local retention. |
| `deploy/configs/otel-collector/otel-collector-config.yaml` | Export OTLP traces to Tempo; leave log and metric pipelines intact. |
| `deploy/configs/grafana/provisioning/datasources/datasources.yaml` | Replace Jaeger provisioning with Tempo at the Compose-reachable query URL. |
| `backend/Dockerfile`, `backend/.dockerignore` | Build and run the existing FastAPI application without adding broker dependencies. |
| `frontend/Dockerfile`, `frontend/.dockerignore` | Build the existing Vue app and serve its production assets. |
| `deploy/0_create_env.sh` | Generate only required Compose credentials and make unrelated GitHub package credentials optional. |
| `deploy/1_start_dev.sh`, `deploy/2_deploy.sh`, `deploy/3_stop.sh` | Use the supported Compose pair from a path independent of caller working directory. |
| `README.md`, `docs/usage/infra/USAGE.md` | Link and document the complete local workflow and its security/availability limits. |
| `docs/arc42/01_introduction_and_goals.md` through `docs/arc42/12_glossary.md` | Audit every Phase 1 chapter and update target/current claims to match the implemented system and chosen local defaults. Keep the canonical template unchanged. |
| `docs/plans/PLAN-006-deployment-modernization.md`, `docs/plans/PLAN.md` | Record this implementation plan and index it as the current deployment plan. |

Do not change backend/frontend application source, `backend/requirements.txt`, package dependencies, or requirement documents unless implementation reveals a direct mismatch with the approved requirements. In particular, do not add a Kafka client in the absence of an application messaging requirement.

## Ordered Implementation Steps

1. **Make service topology and stateful infrastructure coherent**
   - Update the base Compose definition with Tempo and Kafka; configure local persistence, ports/listeners, health checks, and readiness. Correct Prometheus's command path to the mounted filename.
   - Keep existing Loki, Prometheus, Grafana, Fluent Bit, and Keycloak configuration unless required for the unified invocation. Remove Jaeger/RabbitMQ references from active Compose services and remove only obsolete broker/build-secret wiring.
   - Outcome: infrastructure Compose is internally consistent; Kafka and Tempo are explicit local-development services with documented limitations.
   - Requirements: DEPLOY-REQ-001, DEPLOY-REQ-002.

2. **Connect the trace pipeline end to end**
   - Add `deploy/configs/tempo/tempo.yaml`; update the Collector exporter and trace pipeline to supported OTLP settings for Tempo. Replace the Grafana Jaeger datasource with Tempo.
   - Ensure Collector starts after required backends are healthy and validate Tempo's `/ready` probe against the chosen image before relying on `service_healthy`.
   - Outcome: Collector -> Tempo -> Grafana endpoints agree; Loki and Prometheus paths remain independent.
   - Requirements: DEPLOY-REQ-001.

3. **Build and orchestrate the current web applications**
   - Add project-scoped Dockerfiles and `.dockerignore` files. Replace the unresolved `webapi` build definition with a backend service and add the frontend service to `docker-compose.web.yml`.
   - Publish `127.0.0.1:8080` for FastAPI and `127.0.0.1:8081` for Vue/Nginx. Configure app health checks and only real service dependencies. Keep the static frontend static.
   - Outcome: the documented two-file Compose invocation builds and starts both apps plus the defined infrastructure.
   - Requirements: DEPLOY-REQ-003.

4. **Align environment setup, helper scripts, and user documentation**
   - Remove `RABBIT_ADMIN_PASSWORD` generation, retain required Grafana/Keycloak credential generation, and make stale GitHub build credentials non-blocking while preserving any independent helper behavior.
   - Make all three lifecycle scripts resolve paths consistently and use both Compose files; stop with the same project definition used to start it.
   - Document Docker/Compose prerequisites, invocation, published endpoints, host and in-network Kafka bootstrap addresses, no-auth local implications, state-volume behavior, Tempo readiness/storage, and clean shutdown. Link the guide from the root README.
   - Outcome: setup, script, and manual workflows describe the same runnable system.
   - Requirements: DEPLOY-REQ-002, DEPLOY-REQ-003.

5. **Audit the complete arc42 set against implementation**
   - Revisit `01_introduction_and_goals.md`, `02_architecture_constraints.md`, `03_context_and_scope.md`, `04_solution_strategy.md`, `05_building_block_view.md`, `06_runtime_view.md`, `07_deployment_view.md`, `08_concepts.md`, `09_architecture_decisions.md`, `10_quality_requirements.md`, `11_technical_risks.md`, and `12_glossary.md`.
   - Keep one repository-level architecture. Update service/building-block diagrams, runtime and deployment workflows, ports/listeners, storage/readiness, local security, Compose invocation, and ADR status. Remove Jaeger/RabbitMQ as active target claims while retaining them only where useful to explain the verified previous baseline. Mark implemented choices as current only after verification; leave production security/HA outside scope and avoid implying an application messaging or frontend API workflow.
   - Outcome: every chapter agrees on current implementation, target status, and remaining non-goals; the English arc42 template reference is unchanged.
   - Requirements: SYSTEM-REQ-001.

6. **Validate the complete local stack and focused application checks**
   - Run static Compose validation, independent app tests/builds, shell syntax and Markdown/whitespace checks before attempting container startup. If Docker is available, build and start using the documented command, then verify service health and host endpoints. Exercise trace ingestion and Grafana datasource connectivity when the local stack is running.
   - Search active deployment and user docs for stale Jaeger/RabbitMQ configuration; historical arc42 baseline references may remain clearly marked as history.
   - Outcome: docs, Compose model, container builds, existing app tests, and runtime endpoints are mutually consistent.

## Dependencies

- Step 1 establishes the infrastructure services and volumes referenced by Step 2 and the full Compose invocation.
- Step 2's Tempo service and Collector configuration must be ready before Grafana datasource verification.
- Step 3 can be implemented independently of Kafka and observability because the applications have no such integration; it joins the supported invocation after the shared network exists.
- Step 4 must follow the chosen ports and Compose command from Steps 1-3.
- Step 5 should describe verified implementation facts after Steps 1-4; it must not convert an assumption into a fact.
- Step 6 validates the earlier steps; if Docker is unavailable, report Compose static validation and app-level checks separately and state the runtime gap.

## Validation Commands and Criteria

Run from the repository root unless a working directory is shown:

```sh
(cd deploy && docker compose -f docker-compose.yml -f docker-compose.web.yml config --quiet)
(cd deploy && docker compose -f docker-compose.yml -f docker-compose.web.yml build)
(cd backend && python -m pytest)
(cd frontend && npm ci && npm run build)
bash -n deploy/0_create_env.sh deploy/1_start_dev.sh deploy/2_deploy.sh deploy/3_stop.sh
git diff --check
```

After configuring `deploy/.env` using the setup script, run the documented stack command:

```sh
(cd deploy && docker compose -f docker-compose.yml -f docker-compose.web.yml up --build -d)
(cd deploy && docker compose -f docker-compose.yml -f docker-compose.web.yml ps)
curl -fsS http://127.0.0.1:8080/api/v1/health
curl -fsSI http://127.0.0.1:8081/
curl -fsS http://127.0.0.1:3200/ready
```

Verify Kafka readiness from Compose using the configured broker API health check and confirm the documented bootstrap endpoints are `kafka:9092` in-network and `localhost:29092` on the host. Verify the Collector trace exporter resolves to Tempo, the Grafana datasource URL is `http://tempo:3200`, and a sample OTLP trace reaches Tempo and is queryable through Grafana. Confirm Prometheus reaches ready with its mounted configuration, the existing Loki/log and Prometheus/metrics paths remain intact, and no web service references an undefined service. Shut down with the same two-file `docker compose ... down` command; do not use `down -v` as a routine validation because it removes local data.

If the Docker engine or network is unavailable, still run `docker compose ... config --quiet` when the Compose CLI is installed, backend tests, frontend production build, `bash -n`, and `git diff --check`; clearly report unrun image-build and live-service checks.

Validation is complete when Compose parses with all references resolved; both app images build; the existing backend tests pass without infrastructure running; the frontend builds; API/frontend/Tempo readiness checks pass in the running stack; Kafka health is healthy; the trace pipeline is verified; helper scripts parse; and active config/docs contain no stale Jaeger/RabbitMQ contract.

## Assumptions and User Input Before Coding

No user decision blocks implementation under the approved development-local assumptions. Proceed with one repository-level arc42 set, the official Apache Kafka single-node KRaft mode, unauthenticated localhost-only plaintext Kafka, local named-volume Kafka/Tempo storage, and the documented two-file Compose invocation.

Ask for user input before implementation only if any of these defaults are not acceptable: the stack is intended for a shared/untrusted network or production (which changes Kafka security, topology, and Tempo storage/retention requirements); a different Kafka distribution/topology or authentication scheme is mandatory; or the request actually requires separate arc42 sets per service. Production-grade HA, backups, external storage, TLS/SASL, and multi-broker behavior are explicitly out of scope otherwise.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Kafka listener advertisement works inside Docker but not from the host, or vice versa. | Configure distinct internal and localhost listeners and test both advertised bootstrap endpoints. |
| The chosen Tempo image lacks a shell or HTTP probe utility. | Verify the health check against the pinned image before making dependents wait on `service_healthy`; use an image-supported probe and keep `/ready` as the definitive check. |
| Compose merges relative paths differently from expectations. | Keep invocation working directory fixed at `deploy/`, use build contexts relative to that directory, and validate the merged config and actual image build. |
| Existing helper scripts or Compose logging drivers fail before services are ready. | Align script paths and startup order, test health and logs, and adjust only the implicated existing configuration. |
| Plaintext single-node Kafka could be mistaken for a production recommendation. | Bind host access to loopback, document no TLS/auth and no HA, and keep production choices explicitly out of scope. |
| Architecture edits could erase Phase 1 user changes or claim unverified state. | Preserve the existing chapter work, make focused evidence-based edits, and label any unverified target accurately. |

## Scope Guard

Do not introduce application Kafka producers/consumers, message schemas or workflows; do not change backend or Vue behavior; do not add authentication integration, production infrastructure, or separate arc42 document sets; do not pin or refactor unrelated services merely for cleanup. Preserve existing untracked deployment files and limit their edits to the requirements and this plan.
