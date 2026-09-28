"""Logging functionality for the FastAPI backend."""

import json
import logging
import logging.config
import os
from pathlib import Path

from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter
from opentelemetry.instrumentation.logging.handler import LoggingHandler
from opentelemetry.sdk._logs import LoggerProvider
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor, LogRecordExporter
from opentelemetry.sdk.resources import Resource

_logger_provider: LoggerProvider | None = None
_otel_handler: LoggingHandler | None = None


def setup_logging(log_exporter: LogRecordExporter | None = None) -> LoggerProvider:
    """Configure console logging and batched OTLP export for application logs."""
    global _logger_provider, _otel_handler

    config_file = Path(__file__).resolve().parents[4] / "logging_config.json"
    with config_file.open(encoding="utf-8") as file:
        logging.config.dictConfig(json.load(file))

    app_logger = logging.getLogger("app")
    if _otel_handler is not None:
        app_logger.removeHandler(_otel_handler)
    if _logger_provider is not None:
        _logger_provider.shutdown()

    provider = LoggerProvider(
        resource=Resource.create(
            {"service.name": os.getenv("OTEL_SERVICE_NAME", "backend")}
        )
    )
    exporter = log_exporter if log_exporter is not None else OTLPLogExporter(
        endpoint=os.getenv("OTEL_EXPORTER_OTLP_LOGS_ENDPOINT")
        or os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT"),
        insecure=True,
    )
    provider.add_log_record_processor(BatchLogRecordProcessor(exporter))
    handler = LoggingHandler(level=logging.INFO, logger_provider=provider)
    app_logger.addHandler(handler)

    _logger_provider = provider
    _otel_handler = handler
    return provider