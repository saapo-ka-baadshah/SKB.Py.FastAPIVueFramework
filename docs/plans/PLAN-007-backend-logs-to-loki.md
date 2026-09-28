# PLAN-007: Deliver Backend Logs to Loki

## Goal

Record implementation and verification of DEPLOY-REQ-004 and DEPLOY-NFR-001: backend application log records emitted while handling HTTP requests must reach Loki. Use the successful `GET /api/v1/health` event as the minimum end-to-end signal. This is a focused follow-up to [PLAN-006: Deployment Modernization](PLAN-006-deployment-modernization.md), not a replacement for its broader deployment scope.

## Implementation Status

**Review verdict: PASS WITH ISSUES.** Backend tests passed (3 tests); merged Compose configuration and diff checks passed. A live health request returned HTTP 200, and a Loki query returned the event with zero duplicate records observed.

- **P2, tracing configuration:** `app.main` reads `OTEL_EXPORTER_OTLP_ENDPOINT`, but `docker-compose.web.yml` sets only `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`. The trace exporter therefore defaults to `localhost:4317` inside the backend container and produces `UNAVAILABLE` errors. This is separate from the working log export route.
- **P3, stale initial findings:** the Docker image now includes `logging_config.json`, and the application now configures an OpenTelemetry Logs provider/exporter. The original findings below are retained as a record of the pre-implementation investigation, not as current defects.
- The proposed 10-second visibility target was not measured. Diagnostic visibility during a sustained Collector outage was not verified. Neither should be reported as a passed criterion.

## Requirements and Interpretation

- [Monorepo requirements index](../specs/REQUIREMENTS.md) and [deploy / infra requirements](../specs/deploy/REQUIREMENTS.md): DEPLOY-REQ-004 and DEPLOY-NFR-001 (both proposed).
- The expected result is the backend event searchable in Loki. Loki container stdout/stderr is Loki's own operational diagnostic output and is not where an application event should appear.
- The proposed 10-second visibility target and the assumed interpretation need user confirmation before they are treated as final acceptance constraints. For planning, proceed with the documented interpretation and target; do not block implementation on confirmation.
- Delivery during an ingestion outage is not guaranteed. The health request itself must continue to succeed, and delivery failures must remain diagnosable.

## Pre-Implementation Findings (Historical)

The following items describe the initial investigation before the logging implementation was completed. They are not the current state:

1. The initial hypothesis that the image omitted `logging_config.json` is resolved: `backend/Dockerfile` copies the file to `/app/logging_config.json`, and `setup_logging()` resolves it relative to the application module rather than the caller's working directory.
2. The health module logger is `app.api.v1.health`. The current setup attaches an OpenTelemetry handler to the `app` logger, which receives the child logger's propagated records; the root logger retains the console handler.
3. The current logging setup creates a `LoggerProvider`, a `BatchLogRecordProcessor`, and an OTLP log exporter. It sets the resource service name from `OTEL_SERVICE_NAME`, defaulting to `backend`.
4. The current web Compose config sets `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT=http://otel-collector:4317` for the backend. Backend records use this OTLP logs route; the Fluentd logging extension is on Grafana, and Fluent Bit's Forward input is not configured as a second backend route.

The implemented route is backend OTLP Logs SDK -> Collector OTLP receiver -> Loki OTLP export, while preserving backend stdout for `docker compose logs backend`. The independent trace endpoint mismatch is recorded in the implementation status above.

## Original Scope and Decisions (Historical)

- Configure Python logging so the health module's application records reach an OpenTelemetry Logs SDK handler/provider and an OTLP log exporter targeting the Collector on the Compose network. Retain console output for normal container diagnostics.
- Make logging configuration discovery independent of the caller's current working directory and ensure the selected config is included in the backend image. Keep local and container execution behavior aligned.
- Attach OTEL logging to the intended application logger hierarchy exactly once. Preserve timestamp and severity and set backend service identity (for example `service.name=backend`) as an OTLP resource attribute or equivalent metadata.
- Reuse the existing Collector OTLP logs pipeline and Loki exporter if validation confirms their endpoint/path and protocol are supported by the configured images. Use Compose service DNS for the Loki target. Change only what is required to complete and prove this route.
- Do not make backend startup or health responses depend synchronously on Collector/Loki availability. Use asynchronous/batched log export or equivalent non-blocking handling, and expose pipeline failures through Collector/backend diagnostics. Do not imply durable buffering across outages.
- Do not add Uvicorn access logging, new endpoint behavior, trace/metric changes, a Fluentd driver on the backend, or Loki-container-log forwarding as part of this request. The existing health event is the acceptance probe, not a request to invent a broader logging product.

## Files Originally Identified

| Path | Purpose |
|---|---|
| `backend/app/library/core/logging/__init__.py` | Initialize and configure the application logging and OpenTelemetry Logs pipeline without relying on the current working directory. |
| `backend/logging_config.json` | Attach handlers to the logger hierarchy that actually emits application events, exactly once, while retaining console output. |
| `backend/app/main.py` | Initialize logging early enough for application records; share endpoint/resource configuration only where appropriate. |
| `backend/Dockerfile` | Include the effective logging configuration in the runtime image, unless the implementation deliberately packages it with the application instead. |
| `backend/requirements.txt` | Add or correct only the OTLP Logs SDK/exporter dependency if the installed OTEL distribution does not already provide the needed API. |
| `deploy/docker-compose.web.yml` | Set the backend's Collector endpoint and resource identity using Compose service DNS; do not introduce a duplicate container-log route. |
| `deploy/configs/otel-collector/otel-collector-config.yaml` | Correct the existing OTLP-to-Loki route only if runtime validation finds an invalid endpoint, protocol, or metadata mapping. |
| `backend/tests/test_health.py` and/or focused logging tests | Assert the endpoint's existing event is emitted and the logging export wiring handles the event once without requiring live infrastructure. |
| `docs/usage/infra/USAGE.md` | Document the Loki query verification, expected visibility window, service identity/query fields, and the distinction from Loki container diagnostics. |

Avoid broad changes to PLAN-006-owned services and unrelated observability pipelines. `docs/specs/*` records the current proposed criteria; do not silently change requirement status or meaning in the implementation.

## Original Implementation Steps (Historical)

The checklist below records the intended implementation sequence. The review outcome and remaining unverified criteria are summarized in [Implementation Status](#implementation-status); this checklist is not evidence that every proposed acceptance criterion passed.

1. **Confirm effective runtime configuration and route assumptions**
   - Inspect the built backend image's working directory and files; render the merged two-file Compose config and identify the backend's current environment, logger setup, and network.
   - Validate the Collector and Loki image versions' OTLP Logs endpoint/protocol behavior and the current `otlphttp` exporter URL construction. Check readiness/status and relevant component diagnostics.
   - Outcome: verify or falsify each root-cause item above and preserve the existing Collector -> Loki route where it is already valid.

2. **Make backend logging configuration load reliably**
   - Resolve the config from a stable application-relative/package path or explicitly copy it to the resolved image path; do not depend on a shell's working directory.
   - Configure the actual `app.api.v1.health` logger hierarchy for one OTEL handler and one console path. Ensure the endpoint's event is not filtered by logger name or level.
   - Outcome: the health event appears once in backend stdout and is handed to the OTEL Logs SDK.

3. **Complete the OTLP Logs SDK-to-Collector path**
   - Configure a Logs provider, non-blocking/batched record processor, and OTLP log exporter using the project's supported OpenTelemetry APIs. Point the backend to `otel-collector:4317` (gRPC) or the explicitly validated HTTP endpoint, and configure backend service identity.
   - Reuse the Collector's OTLP logs receiver and Loki exporter; correct service DNS, endpoint path, or resource/metadata mapping only if Step 1 shows a defect. Do not configure a parallel Fluentd/Fluent Bit route for backend events.
   - Outcome: one traceable route carries timestamped, severity-bearing backend records with queryable service identity to Loki.

4. **Prove endpoint resilience and guard the logging contract**
   - Add or extend a backend test to assert a health call produces the existing INFO application event. Add a focused provider/exporter test using a fake or mock exporter to prove the OTEL handler forwards one record with severity and service identity without a live Collector.
   - Verify the health response remains HTTP 200 when Collector or Loki is unavailable after startup; export failure is reported diagnostically and is not raised through the endpoint request.
   - Outcome: a fast deterministic regression check covers the backend behavior and the non-blocking resilience criterion.

5. **Verify actual Loki visibility and document the procedure**
   - Build/start the backend with the deployment Compose pair, send `GET /api/v1/health`, and query Loki's HTTP query API (or Grafana Explore) for the event and backend identity. Require visibility within 10 seconds in a healthy stack, subject to user confirmation of that proposed target.
   - Confirm one backend event is sent through only one ingestion route. Account for Compose's backend health check, which itself calls `/api/v1/health` periodically: repeated probe events are separate real calls, not evidence of duplicate ingestion. Compare controlled request activity or isolate probes when checking delivery cardinality.
   - Update the infrastructure usage guide with the actual supported query and fields, the command to generate the event, the timing target, and the fact that `docker logs` on Loki is not the application-log acceptance check.
   - Outcome: the supported local workflow demonstrates the complete backend -> Collector -> Loki path without confusing Loki process diagnostics with stored logs.

## Validation Commands and Criteria

The commands below are retained as a reproduction procedure, not as a claim that all criteria passed. The live endpoint/query result is recorded above; the 10-second target and sustained-outage diagnostic visibility remain unverified.

Run focused backend checks from `backend/`:

```sh
python -m pytest
```

Validate and build the local stack using the documented Compose pair from `deploy/`:

```sh
docker compose -f docker-compose.yml -f docker-compose.web.yml config --quiet
docker compose -f docker-compose.yml -f docker-compose.web.yml build backend
docker compose -f docker-compose.yml -f docker-compose.web.yml up -d backend otel-collector loki
curl -fsS http://127.0.0.1:8080/api/v1/health
```

Then query `http://127.0.0.1:3100/loki/api/v1/query_range` (or Grafana Explore) for the health event using the verified service identity and message fields. The live check passes when the event is queryable within 10 seconds in a healthy stack, its timestamp/severity/service identity are retained, and only one configured route ingests each backend record. Stop or isolate the Collector/Loki after startup and confirm the endpoint still returns its normal response while the pipeline reports the failure. Avoid `down -v`; this focused test should preserve local named volumes.

If Docker is unavailable, still run the backend tests and Compose static validation if the CLI exists. Report the live delivery, outage, and timing criteria as unverified rather than inferring success from stdout or configuration alone.

## Dependencies and Risks

- PLAN-006's Compose network and backend service must exist for the live route check; the plan remains runnable at source/config level if the full PLAN-006 stack is not yet available.
- OpenTelemetry Python Logs APIs and OTLP exporter paths are version-sensitive. Verify against pinned installed packages and avoid adding a duplicate SDK/provider or unsupported private imports.
- The current Compose file uses `latest` for Collector and Loki. Endpoint compatibility may change; if so, record the narrow compatibility fix and coordinate version pinning with PLAN-006 rather than broadening this plan into a stack modernization.
- Loki's OTLP ingestion can expose resource attributes as structured metadata rather than indexed labels. Verify the queryable representation and keep high-cardinality event fields out of indexed labels.
- The healthcheck generates its own valid health events. Integration validation must distinguish separate requests from duplicate copies of one record.
- The 10-second target and precise meaning of “logs for Loki” remain proposed/open in DEPLOY-NFR-001. If the user instead means Loki process diagnostics, that is a different request and does not satisfy the backend-log delivery requirement.

## Scope Guard

Do not change health response behavior, add request/access logging, alter trace or metric pipelines, add production-grade persistence or zero-loss guarantees, modify unrelated services, or send backend events through multiple ingestion routes. Preserve user changes already present in backend, deployment, and requirements files; make only focused additions needed to complete and verify DEPLOY-REQ-004 and DEPLOY-NFR-001.