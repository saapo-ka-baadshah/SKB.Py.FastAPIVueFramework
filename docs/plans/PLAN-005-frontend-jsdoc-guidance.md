# PLAN-005: Frontend JSDoc Guidance

## Goal

Make `frontend/README.md` actionable and consistent with FRONTEND-REQ-003 by clearly explaining when and where to use JSDoc for JavaScript declarations and Vue single-file components. Keep this work documentation-only; do not add source comments or declarations solely to demonstrate JSDoc.

## Feature References

- Requirements: [frontend requirements](../specs/frontend/REQUIREMENTS.md), FRONTEND-REQ-003.
- Existing guidance: [frontend README](../../frontend/README.md) already covers useful-comment criteria, placement, `@param`, `@returns`, redundant comments, and component-level documentation for explicit Vue declarations.
- Frontend context: [PLAN-004: Vue Frontend](PLAN-004-vue-frontend.md).

## Scope and Decisions

- The developer implementation target is `frontend/README.md` only. Preserve its existing prerequisite, install, development, and production-build instructions.
- Phase 1 requirement artifacts, `docs/specs/frontend/REQUIREMENTS.md` and `docs/specs/REQUIREMENTS.md`, are already complete prerequisites and are not implementation targets. `docs/plans/PLAN.md` already indexes this plan and is not an implementation target.
- Refine the current JSDoc guidance only as needed and add one concise JavaScript example showing a JSDoc block immediately before a function declaration, with a real parameter description and return description that match the example's behavior.
- Keep the guidance that JSDoc is for useful, non-obvious contracts, not comments that repeat code or obvious template markup. Use `@param` and `@returns` only where applicable, and avoid inaccurate claims.
- Explain that component-level JSDoc belongs immediately before an explicit component declaration in a Vue `<script>` block. Do not add an artificial `<script>` declaration or component example just to host a comment.
- The current `frontend/src/App.vue` is template-only, and `frontend/src/main.js` has no function declaration. Do not add JSDoc to either file or require function comments in files without functions.

## Expected Files

| Path | Purpose |
|---|---|
| `frontend/README.md` | Clarify the JSDoc guidance and include a concise, accurate JavaScript example without changing setup instructions. |

Completed prerequisite artifacts, not implementation targets: `docs/specs/frontend/REQUIREMENTS.md`, `docs/specs/REQUIREMENTS.md`, and the existing PLAN-005 entry in `docs/plans/PLAN.md`.

## Ordered Implementation Steps

1. **Review the current README guidance against FRONTEND-REQ-003**
   - Preserve the current setup and run sections.
   - Check that the JSDoc prose addresses usefulness, immediate placement, accurate `@param` and `@returns` tags, redundant comments, explicit Vue declarations, and files without functions.
   - Outcome: all requirement criteria are directly addressed without expanding the frontend's behavior.

2. **Make the README example actionable**
   - Add one short function example whose JSDoc comment immediately precedes the declaration.
   - Ensure the parameter and return tags use accurate types, names, and descriptions for the shown implementation.
   - Retain the explicit-component guidance as prose; do not invent a component declaration or annotate application source.
   - Outcome: a reader can follow a correct JSDoc pattern without implying that the current template-only component needs an annotation.

3. **Confirm the plan index entry**
   - Confirm PLAN-005 is linked as the frontend documentation guidance plan and PLAN-004 remains the frontend implementation plan; the index entry already exists.
   - Outcome: both frontend plans remain discoverable and existing plan history remains linked without expanding the implementation target.

4. **Validate the documentation change**
   - From `frontend/`, run `npm run build` to ensure the documentation-only edit leaves the existing frontend build intact.
   - From the repository root, run `git diff --check` to detect whitespace errors.
   - Review the final README to confirm all existing setup/run commands remain unchanged and each FRONTEND-REQ-003 criterion is covered.
   - Outcome: the frontend still builds and the documentation is requirement-complete and clean.

## Dependencies

- FRONTEND-REQ-003 is approved, and its completed requirement artifacts are `docs/specs/frontend/REQUIREMENTS.md` and `docs/specs/REQUIREMENTS.md`.
- The initial README guidance and PLAN-005 index entry are already present. No application-code change is required; implementation is limited to `frontend/README.md`.

## Validation Criteria

Validation is complete when `npm run build` succeeds from `frontend/`, `git diff --check` succeeds from the repository root, the README continues to document the existing setup and run commands, and its JSDoc guidance covers all FRONTEND-REQ-003 acceptance criteria. Confirm the change adds no source comments, functions, or Vue component declarations.

## Scope Guard

Limit developer implementation changes to `frontend/README.md` only. Do not modify the completed requirement artifacts, plan index, Vue or JavaScript application code, add test or lint infrastructure, alter frontend behavior, or change the existing setup instructions.