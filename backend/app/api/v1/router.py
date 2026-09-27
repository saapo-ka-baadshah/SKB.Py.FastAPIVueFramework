"""Route grouping for the version 1 API."""

from fastapi import APIRouter

from app.api.v1.health import router as health_router

router = APIRouter(prefix="/api/v1")
"""Root router for all version 1 API endpoints."""

router.include_router(health_router)