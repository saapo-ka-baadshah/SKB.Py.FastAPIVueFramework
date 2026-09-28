"""Tests for the version 1 health endpoint."""

from fastapi.testclient import TestClient
from opentelemetry.sdk._logs.export import LogRecordExportResult, LogRecordExporter

from app.main import app
from app.library.core.logging import setup_logging

client = TestClient(app)


class CapturingLogExporter(LogRecordExporter):
    def __init__(self, fail: bool = False) -> None:
        self.records = []
        self.fail = fail

    def export(self, batch):
        self.records.extend(batch)
        return LogRecordExportResult.FAILURE if self.fail else LogRecordExportResult.SUCCESS

    def shutdown(self) -> None:
        pass

    def force_flush(self, timeout_millis: int = 30000) -> bool:
        return True


def test_health_returns_initial_ok_status() -> None:
    """The health endpoint returns the documented initial availability status."""

    setup_logging(log_exporter=CapturingLogExporter())
    response = client.get("/api/v1/health")

    assert response.status_code == 200
    payload = response.json()
    assert isinstance(payload, dict)
    assert payload["message"] in {"OK", "UNHEALTHY"}
    assert payload["message"] == "OK"


def test_health_event_is_exported_once_with_service_metadata() -> None:
    exporter = CapturingLogExporter()
    provider = setup_logging(log_exporter=exporter)

    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert provider.force_flush()

    assert len(exporter.records) == 1
    record = exporter.records[0]
    assert record.log_record.body == "Health check endpoint called."
    assert record.log_record.severity_text == "INFO"
    assert record.resource.attributes["service.name"] == "backend"


def test_health_succeeds_when_log_export_fails() -> None:
    exporter = CapturingLogExporter(fail=True)
    provider = setup_logging(log_exporter=exporter)

    response = client.get("/api/v1/health")

    assert response.status_code == 200
    assert provider.force_flush()
    assert len(exporter.records) == 1