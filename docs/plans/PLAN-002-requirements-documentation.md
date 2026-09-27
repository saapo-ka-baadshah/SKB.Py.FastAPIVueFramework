# PLAN-002: Requirements Documentation Reorganization

## Goal

Organize requirements in `docs/specs/` by monorepo unit, with a root index and backend-specific requirements. Phase 1 has completed this documentation move; this plan records its scope and verification. No application implementation is included.

## Affected Paths

- `docs/specs/REQUIREMENTS.md` — monorepo requirements index and source-request summary.
- `docs/specs/backend/REQUIREMENTS.md` — backend requirements REQ-001 through REQ-004, acceptance criteria, assumptions, and traceability.
- `specs/REQUIREMENTS.md` — former monolithic requirements document; must remain absent.
- `docs/plans/PLAN.md` — plans index pointing to this latest numbered plan while retaining PLAN-001.

The index records no requirements for `frontend/` or `deploy/infra` because the source request is backend-only. No frontend or deployment requirements are to be invented as part of this reorganization.

## Ordered Plan

1. **Establish unit ownership.** Use the repository units `backend/`, `frontend/`, and `deploy/infra` to scope the requirements index. Record backend as the only unit with requirements for this source request; mark frontend and deploy/infra as having no defined requirements.
2. **Split and relocate the requirements.** Keep the monorepo index at `docs/specs/REQUIREMENTS.md` and place backend-specific material at `docs/specs/backend/REQUIREMENTS.md`. Remove the obsolete `specs/REQUIREMENTS.md` path after preserving its applicable requirements in the new documents.
3. **Preserve requirement coverage and traceability.** Keep REQ-001 (FastAPI backend), REQ-002 (versioned API grouping), REQ-003 (health endpoint response), and REQ-004 (code documentation) in the backend unit document, with their acceptance criteria and source traceability. Preserve the `GET /api/v1/health` JSON contract and the allowed `message` values `OK` and `UNHEALTHY`.
4. **Record plan navigation.** Retain PLAN-001 unchanged as the backend implementation plan, add this numbered documentation plan, and update `docs/plans/PLAN.md` to identify the latest plan.
5. **Validate the reorganization.** Confirm both new requirement documents exist and cross-reference each other correctly; confirm REQ-001 through REQ-004 and their acceptance criteria, especially the route contract, remain present; confirm `specs/REQUIREMENTS.md` is absent; and confirm no application source files changed.

## Scope Boundary

This work reorganizes and validates requirement documentation only. It does not implement the FastAPI backend, change route behavior, add frontend or deployment requirements, or modify application code.