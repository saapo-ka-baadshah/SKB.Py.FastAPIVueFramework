"""Availability endpoint for the version 1 API."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/health", status_code=200)
def health() -> dict[str, str]:
    """Return the current application availability status."""

    return {"message": "OK"}