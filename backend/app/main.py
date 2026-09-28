"""Application entry point for the FastAPI backend."""

import os
from fastapi import FastAPI
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

from app.library.core.logging import setup_logging

setup_logging()

from app.api.v1.router import router as v1_router

# Initialize OpenTelemetry
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Set up OTLP exporter
otlp_exporter = OTLPSpanExporter(endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT"), insecure=True)
span_processor = BatchSpanProcessor(otlp_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

app = FastAPI(
    title="SKB FastAPI Backend",
    description="Backend service for the SKB FastAPI and Vue framework.",
    version="1.0.0",
    docs_url="/api/v1/docs",
    redoc_url=None,
)
"""FastAPI application instance exposed for Uvicorn as ``app.main:app``."""

app.include_router(v1_router)

FastAPIInstrumentor.instrument_app(app)