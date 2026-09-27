"""Tests for the version 1 health endpoint."""

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_returns_initial_ok_status() -> None:
    """The health endpoint returns the documented initial availability status."""

    response = client.get("/api/v1/health")

    assert response.status_code == 200
    payload = response.json()
    assert isinstance(payload, dict)
    assert payload["message"] in {"OK", "UNHEALTHY"}
    assert payload["message"] == "OK"