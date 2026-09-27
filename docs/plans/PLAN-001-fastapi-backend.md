# PLAN-001: FastAPI Backend Foundation

## Feature References

- Feature: initial documented FastAPI backend and versioned health endpoint.
- Requirements: [specs/REQUIREMENTS.md](../../specs/REQUIREMENTS.md), REQ-001 through REQ-004.
- Known issues: none identified. The `backend/` directory is empty, and the architecture documents specify no existing API or test conventions.
- Scope: backend startup, `/api/v1` route grouping, `GET /api/v1/health`, focused tests, and basic run/test documentation. No business endpoints, external health checks, persistence, authentication, deployment, or frontend changes.

## Repository Findings and Decisions

- There is no existing Python dependency manifest, application code, test suite, or established plan sequence. This is the first plan, PLAN-001.
- Keep the backend self-contained under `backend/`. Use `backend/requirements.txt` for the initial runtime and test dependencies so setup does not depend on an absent packaging convention.
- Use FastAPI's `TestClient` for the route contract and Uvicorn to run the application. Run both commands from `backend/` to keep imports simple and predictable.
- Treat the health endpoint as process/application availability only: return `{"message": "OK"}` with HTTP 200. Do not add database or external-service probes. The contract permits `UNHEALTHY` for a future defined condition; no such condition is in scope.
- Preserve a clear version boundary: mount a v1 router at `/api/v1` and define the health route at `/health` within that router.

## Expected Files

| Path | Purpose |
|---|---|
| `backend/requirements.txt` | FastAPI and Uvicorn runtime dependencies plus pytest and HTTPX test dependencies. |
| `backend/app/__init__.py` | Mark the application package. |
| `backend/app/main.py` | Create the documented FastAPI application instance and register the versioned router. |
| `backend/app/api/__init__.py` | Mark the API package. |
| `backend/app/api/v1/__init__.py` | Mark the v1 API package. |
| `backend/app/api/v1/router.py` | Define the v1 `APIRouter` and include its endpoint routers. |
| `backend/app/api/v1/health.py` | Define the documented `GET /health` handler and minimal JSON response. |
| `backend/tests/test_health.py` | Exercise the mounted health endpoint and its status/JSON contract with `TestClient`. |
| `README.md` | Add concise backend setup, run, and test commands and document the health route contract. |

Add module docstrings to public application and route modules, and meaningful handler docstrings. Add inline comments only if an implementation decision is not self-evident. Avoid creating configuration, deployment, or architecture artifacts unrelated to this feature.

## Ordered Implementation Steps

1. **Establish the backend environment**
   - Create `backend/requirements.txt` with FastAPI, Uvicorn, pytest, and HTTPX, using mutually compatible supported versions.
   - Choose and document a supported Python version consistent with the project runtime; no Python version is currently specified by the repository.
   - Outcome: a reproducible local install supports both serving and testing the backend.
   - Requirements: REQ-001; test dependency supports REQ-003 validation.

2. **Create the application and v1 route group**
   - Create the package files listed above.
   - In `backend/app/main.py`, expose `app` as a FastAPI instance and register the v1 router.
   - In `backend/app/api/v1/router.py`, define the version prefix `/api/v1` and include the health router.
   - Outcome: importing `app.main:app` provides a runnable application with an explicit version boundary.
   - Requirements: REQ-001, REQ-002, REQ-004.

3. **Implement the health contract**
   - In `backend/app/api/v1/health.py`, register `GET /health` and return a JSON object with `message` set to `OK` when the application can serve requests.
   - Keep the success status at HTTP 200; do not add external checks or extra response fields as part of this feature.
   - Outcome: the mounted endpoint is `GET /api/v1/health` and matches the conservative assumptions in REQ-003.
   - Requirements: REQ-002, REQ-003, REQ-004.

4. **Add focused endpoint tests**
   - In `backend/tests/test_health.py`, use FastAPI `TestClient` to call `GET /api/v1/health`.
   - Assert HTTP 200, JSON content, an object response with a `message` field, and a value exactly in `{ "OK", "UNHEALTHY" }`. With the initial availability-only implementation, also verify the returned message is `OK`.
   - Outcome: the required URL, method, status assumption, and message contract are checked without coupling to unspecified extra fields.
   - Requirements: REQ-003; documentation quality of test interfaces follows REQ-004.

5. **Document local use and validate end to end**
   - Update `README.md` with environment setup, dependency installation, application startup, test execution, and the health URL/response.
   - Run the tests and start the server locally; issue a GET request to `/api/v1/health` and confirm the response is JSON containing `message: "OK"`.
   - Outcome: REQ-001 has a documented start command and REQ-004's documentation describes the actual prefix and response.
   - Requirements: REQ-001, REQ-003, REQ-004.

## Dependencies

- Step 1 provides dependencies required by Steps 2-4 and the run/test commands in Step 5.
- Step 2 must mount the v1 router before Step 4 can exercise the complete endpoint path.
- Steps 2 and 3 may be implemented together, but Step 3 depends on the router contract chosen in Step 2.
- Step 5 documents and validates the final paths and commands from the preceding steps.

## Testing and Validation Strategy

From the repository root, install and run the backend as follows:

```sh
python -m venv .venv
. .venv/bin/activate
cd backend
python -m pip install -r requirements.txt
python -m pytest
python -m uvicorn app.main:app --reload
```

With Uvicorn running, verify the live HTTP contract in a second terminal from `backend/`:

```sh
curl -i http://127.0.0.1:8000/api/v1/health
```

Validation is complete when the test passes, the server starts using the documented command, and the live request returns HTTP 200 with a JSON object whose `message` is `OK`. The test should check the allowed message set as well as the initial `OK` behavior; it should not require a response shape beyond the specified `message` field.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| No Python version or dependency-management convention is specified. | Select a currently supported Python baseline compatible with the project's intended runtime, and keep the initial setup to a single backend requirements file and documented commands. |
| Import paths differ depending on the current working directory. | Run Uvicorn and pytest from `backend/`, and use the same documented working directory in the README. |
| “Health” could be interpreted as checking external dependencies. | Follow the explicit conservative assumption in REQ-003: report application availability only; leave dependency probes out of scope. |
| The allowed `UNHEALTHY` value has no defined trigger. | Return `OK` for the initial implementation and do not invent an unhealthy state; add one only with a future requirement defining its condition. |

## Scope Guard

Keep implementation changes to the expected backend files and the root `README.md` documentation. Do not modify Vue code, add business routes, introduce deployment infrastructure, or expand the health endpoint into an operational monitoring system.