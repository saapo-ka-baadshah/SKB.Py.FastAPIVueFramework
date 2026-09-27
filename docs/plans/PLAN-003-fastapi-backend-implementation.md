# PLAN-003: FastAPI Backend Implementation

## Goal

Implement a basic, runnable, and documented FastAPI backend with routes grouped by API version and a `GET /api/v1/health` endpoint returning JSON with `message` set to `OK` or `UNHEALTHY`. Add automated endpoint tests, an installable dependency manifest, and user-facing setup, run, and test instructions.

## Feature References

- Source request: create a basic documented FastAPI backend, group API routes for versioning starting at `v1`, and provide a health endpoint returning the required JSON message.
- Requirements: [monorepo requirements index](../specs/REQUIREMENTS.md), [backend requirements](../specs/backend/REQUIREMENTS.md), REQ-001 through REQ-007.
- Frontend and deploy requirements: [frontend requirements](../specs/frontend/REQUIREMENTS.md) and [deploy / infra requirements](../specs/deploy/REQUIREMENTS.md) define no features for this request.
- Prior plans: [PLAN-001: FastAPI Backend Foundation](PLAN-001-fastapi-backend.md) and [PLAN-002: Requirements Documentation Reorganization](PLAN-002-requirements-documentation.md). This plan supersedes PLAN-001 as the implementation guide because it covers the complete, current REQ-001 through REQ-007 set and the relocated specifications.

## Scope and Decisions

- Implement backend code and its local developer-facing documentation only. Do not add Vue features, deployment infrastructure, business endpoints, persistence, authentication, monitoring integrations, or external health probes.
- Keep the backend self-contained under `backend/`. Expose the FastAPI application as `app.main:app`, define a separately includable v1 router, and mount it under `/api/v1`.
- Register the health handler at `/health` within the v1 route group. For the initial availability-only implementation, return `{"message": "OK"}`. Do not invent a condition that returns `UNHEALTHY`; that value remains permitted by the response contract for a future defined condition.
- Use `backend/requirements.txt` for the runtime and test dependencies, consistent with PLAN-001 and the absence of an existing Python packaging convention. Select and document a supported Python baseline compatible with the chosen FastAPI, Uvicorn, pytest, and HTTPX versions.
- Put concise setup, run, test, and endpoint instructions in the root `README.md`, as proposed in PLAN-001, so the instructions are visible from the repository entry point.
- Add useful docstrings for application and route modules, application setup, and route handlers. Use inline comments only to explain non-obvious behavior.

## Expected Files

| Path | Purpose |
|---|---|
| `backend/requirements.txt` | Declare FastAPI and Uvicorn runtime dependencies and pytest and HTTPX test dependencies. |
| `backend/app/__init__.py` | Mark the application package. |
| `backend/app/main.py` | Create the documented FastAPI application instance and register the v1 router. |
| `backend/app/api/__init__.py` | Mark the API package. |
| `backend/app/api/v1/__init__.py` | Mark the v1 API package. |
| `backend/app/api/v1/router.py` | Define the v1 router, prefix `/api/v1`, and include its endpoint routers. |
| `backend/app/api/v1/health.py` | Implement and document `GET /health` and its JSON message response. |
| `backend/tests/test_health.py` | Exercise the mounted `GET /api/v1/health` endpoint using FastAPI `TestClient` or an equivalent HTTP test client. |
| `README.md` | Document the Python prerequisite, environment and dependency setup, working directories, application run command, test command, and health endpoint contract. |

## Ordered Implementation Steps

1. **Establish the backend environment**
   - Add `backend/requirements.txt` with compatible runtime dependencies for FastAPI and Uvicorn and test dependencies for pytest and HTTPX.
   - Choose a supported Python prerequisite compatible with those dependencies and state it in `README.md`.
   - Outcome: the app and test suite can be installed reproducibly from the backend manifest.
   - Requirements: REQ-001, REQ-005, REQ-006, REQ-007.

2. **Create the application and version group**
   - Add the package files in Expected Files.
   - In `backend/app/main.py`, expose `app` as a FastAPI instance and include the v1 router.
   - In `backend/app/api/v1/router.py`, group routes under `/api/v1` and include the health route module.
   - Outcome: `app.main:app` is importable and the route is registered under the exact lowercase `v1` prefix.
   - Requirements: REQ-001, REQ-002, REQ-004.

3. **Implement and test the health response**
   - In `backend/app/api/v1/health.py`, register `GET /health` and return a JSON object with `message` set to `OK` for application availability.
   - In `backend/tests/test_health.py`, request `/api/v1/health` through the application test client and verify a JSON object with a `message` value in `{ "OK", "UNHEALTHY" }`. Also assert `OK` for the initial availability-only behavior. An HTTP 200 check may capture the plan's conservative success-status assumption; no additional status-code behavior is required by the specification.
   - Outcome: the required method, mounted path, and response contract are covered by a focused automated test.
   - Requirements: REQ-002, REQ-003, REQ-005.

4. **Document setup, run, test, and API use**
   - Expand the root `README.md` with the supported Python prerequisite, virtual environment creation and activation, dependency installation from `backend/requirements.txt`, and exact working directories and commands for serving and testing.
   - Document `GET /api/v1/health`, the JSON `message` field, and its allowed values (`OK` and `UNHEALTHY`). Ensure commands are runnable as written and align imports with the documented working directory.
   - Outcome: a user can set up, start, and test the backend using only the README instructions.
   - Requirements: REQ-004, REQ-006, REQ-007.

5. **Run focused validation**
   - From `backend/`, install the declared dependencies and run the documented pytest command.
   - Start the application using the documented Uvicorn command, then issue a live `GET /api/v1/health` request and confirm the JSON response contains `message: "OK"`.
   - Check that README commands match the manifest and actual module paths, all backend modules and handlers have appropriate docstrings, and no frontend or deploy files were changed.
   - Outcome: the implementation, test, and user-facing instructions agree on the same route and setup.
   - Requirements: REQ-001 through REQ-007.

## Dependencies

- Step 1 enables importing and testing the application in Steps 2 and 3, and supplies the install procedure documented in Step 4.
- Step 2 must register the v1 router before the health endpoint can be exercised at its full public path in Step 3.
- Step 3 establishes the actual response contract for Step 4's API documentation.
- Step 5 validates the installed dependencies, application entry point, test command, live route, and documentation together.

## Focused Validation Criteria

From the repository root, create and activate a virtual environment, then install from `backend/requirements.txt` using the documented commands. From `backend/`, run the documented pytest command; the health test must call `GET /api/v1/health`, verify a JSON object and allowed message value, and confirm the initial response is `OK`. Start Uvicorn from the documented working directory using `app.main:app`, then verify the live endpoint at `http://127.0.0.1:8000/api/v1/health` returns JSON containing `message: "OK"`.

Validation is complete when the documented install, test, and run commands are internally consistent and runnable; the focused test passes; and the live request confirms the versioned route and JSON response. No frontend or deployment test is in scope.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| The repository does not specify a Python version or dependency manager. | Choose a supported baseline compatible with selected dependencies and use the minimal `backend/requirements.txt` manifest. |
| Python imports vary with the current directory. | Keep the application import target `app.main:app` and explicitly document running pytest and Uvicorn from `backend/`. |
| The request allows `UNHEALTHY` but defines no unhealthy condition. | Return `OK` for application availability and do not add external probes or invent failure criteria. |
| The README is currently only a repository heading. | Add concise operational instructions at the repository root and verify every command against the implemented paths. |

## Scope Guard

Limit implementation to the expected backend files and the root `README.md`. Do not implement frontend or deploy/infra features, add routes beyond the versioned health endpoint, or expand health semantics beyond application availability.