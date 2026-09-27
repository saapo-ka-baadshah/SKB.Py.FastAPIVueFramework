# SKB.Py.FastAPIVueFramework
A baseline framework which uses fastapi as backend and vue as frontend.

For the complete backend setup and endpoint guide, see [Backend Usage](docs/usage/backend/USAGE.md).

## Backend

The backend requires Python 3.10 or newer. To create and activate a virtual
environment from the repository root:

```bash
python3 -m venv venv
source venv/bin/activate
```

With the environment activated, install the backend dependencies from the
repository root:

```bash
python -m pip install -r backend/requirements.txt
```

The repository also provides a root `venv` workflow. From the repository root,
install the backend dependencies without activating the environment with:

```bash
venv/bin/python -m pip install -r backend/requirements.txt
```

Run the FastAPI application from the `backend/` directory:

```bash
cd backend
../venv/bin/python -m uvicorn app.main:app --reload
```

Run the backend tests from the `backend/` directory. The `cd backend` command
is required because the tests import the application as `app.main`:

```bash
cd backend
../venv/bin/python -m pytest
```

The backend exposes `GET /api/v1/health`. It returns HTTP 200 and a JSON
object with a `message` field. The allowed values are `OK` and `UNHEALTHY`;
the initial availability-only implementation returns `OK`.
