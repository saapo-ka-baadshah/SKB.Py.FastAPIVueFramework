# Backend Usage

This guide covers the implemented FastAPI backend. It provides the versioned
health endpoint `GET /api/v1/health` and currently reports application
availability with `{"message": "OK"}`.

## Prerequisites

- Python 3.10 or newer
- A shell with access to the repository

The commands below assume the repository root is the current directory:

```text
SKB.Py.FastAPIVueFramework/
```

## Set Up the Root Virtual Environment

Create the provided root-level `venv`, then activate it:

```bash
python3 -m venv venv
source venv/bin/activate
```

Install the backend runtime and test dependencies from the repository root:

```bash
venv/bin/python -m pip install -r backend/requirements.txt
```

When the environment is activated, the equivalent command is:

```bash
python -m pip install -r backend/requirements.txt
```

## Run the Backend

Change to `backend/` before starting Uvicorn. The `app.main:app` import path
depends on this working directory:

```bash
cd backend
../venv/bin/python -m uvicorn app.main:app --reload
```

The server listens at `http://127.0.0.1:8000` by default.

## Run the Tests

Run pytest from the `backend/` directory as well:

```bash
cd backend
../venv/bin/python -m pytest
```

## Health Endpoint

| Method | Path | Response |
| --- | --- | --- |
| `GET` | `/api/v1/health` | HTTP 200 with a JSON object containing `message` |

Example request:

```bash
curl http://127.0.0.1:8000/api/v1/health
```

Initial response:

```json
{"message":"OK"}
```

The response contract permits `OK` or `UNHEALTHY`. The initial implementation
returns `OK` when the application is available. It does not perform external
health probes; `UNHEALTHY` is reserved by contract for a future explicitly
defined condition.

## Troubleshooting Import-Path Errors

If Uvicorn or pytest reports `ModuleNotFoundError: No module named 'app'`:

1. Change to the backend directory: `cd backend`.
2. Run the command with the root environment's backend-relative interpreter:
   `../venv/bin/python -m uvicorn app.main:app --reload` or
   `../venv/bin/python -m pytest`.
3. Do not run `pytest` from the repository root for this backend. The test
   imports `app.main`, which is importable when `backend/` is the working
   directory.

If the virtual environment does not exist, return to the repository root and
run `python3 -m venv venv`, then install the dependencies again.