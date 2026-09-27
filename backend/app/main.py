"""Application entry point for the FastAPI backend."""

from fastapi import FastAPI

from app.api.v1.router import router as v1_router

app = FastAPI(
    title="SKB FastAPI Backend",
    description="Backend service for the SKB FastAPI and Vue framework.",
    version="1.0.0",
)
"""FastAPI application instance exposed for Uvicorn as ``app.main:app``."""

app.include_router(v1_router)