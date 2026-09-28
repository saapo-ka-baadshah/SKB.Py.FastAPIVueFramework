"""Availability endpoint for the version 1 API."""

from fastapi import APIRouter

from app.library.core.logging import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/health", status_code=200)
def health() -> dict[str, str]:
    """Return the current application availability status."""

    logger.info("Health check endpoint called.")
    return {"message": "OK"}