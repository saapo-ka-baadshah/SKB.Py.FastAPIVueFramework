# PLAN-004: Vue Frontend

## Goal

Create a runnable Vue application in `frontend/` with a simple initial informational page that visibly identifies FastAPI as the backend technology and Vue as the frontend technology. Keep the page static; no API integration or additional workflow is required.

## Feature References

- Requirements: [monorepo requirements index](../specs/REQUIREMENTS.md), [frontend requirements](../specs/frontend/REQUIREMENTS.md), FRONTEND-REQ-001 and FRONTEND-REQ-002.
- Related backend: [backend requirements](../specs/backend/REQUIREMENTS.md) and [PLAN-003: FastAPI Backend Implementation](PLAN-003-fastapi-backend-implementation.md). The frontend only describes the backend stack; it does not call the backend.
- Repository finding: `frontend/` is currently empty. There is no existing frontend framework, package manifest, or JavaScript test convention to preserve.

## Scope and Decisions

- Use Vue 3 with Vite and npm. This is a minimal, widely supported setup for an empty frontend directory and supplies standard local development and production build commands.
- Use the Vite Vue JavaScript template rather than TypeScript, routing, or state-management libraries. The single informational page has no logic that justifies those additions.
- Keep all frontend-owned source and configuration under `frontend/`. Do not change backend code or add root-level JavaScript configuration.
- Render the backend and frontend labels and values directly in the initial page: backend `FastAPI`, frontend `Vue`. Static content is sufficient; do not fetch backend metadata or add more workflows.
- Choose a currently supported Node.js LTS release meeting the selected Vite version's engine requirement, and document the prerequisite and npm commands in `frontend/README.md`.

## Expected Files

| Path | Purpose |
|---|---|
| `frontend/package.json` | Declare Vue and Vite dependencies and `dev`, `build`, and `preview` scripts. |
| `frontend/package-lock.json` | Record the npm dependency resolution for reproducible installs. |
| `frontend/index.html` | Provide the Vite document shell and mount point. |
| `frontend/vite.config.js` | Configure the Vue plugin for Vite. |
| `frontend/src/main.js` | Create and mount the Vue application. |
| `frontend/src/App.vue` | Render the initial setup overview with clearly readable Backend / FastAPI and Frontend / Vue labels. |
| `frontend/src/style.css` | Provide the page's minimal responsive presentation, if the scaffold keeps global styles separate. |
| `frontend/README.md` | Document the Node.js prerequisite and exact install, run, and build commands. |

Keep or remove additional generated scaffold assets as appropriate; do not retain unused starter counter behavior or branding. No dedicated unit-test framework is proposed for this static view because the repository has no frontend test convention and the requirements define no interactive behavior.

## Ordered Implementation Steps

1. **Establish the frontend project**
   - Scaffold the Vue JavaScript application using the Vite Vue template in the existing `frontend/` directory.
   - Confirm the generated manifest provides npm `dev`, `build`, and `preview` scripts and creates a lockfile.
   - Outcome: a self-contained Vue/Vite project with a declared local run command.
   - Requirements: FRONTEND-REQ-001.

2. **Replace the starter view with the setup overview**
   - Update `frontend/src/App.vue` and, if needed, `frontend/src/style.css` to show the two technology labels and values on the initial page.
   - Ensure both `Backend` / `FastAPI` and `Frontend` / `Vue` are visible and readable without interaction. Keep the content static and avoid backend requests, routing, and unrelated workflows.
   - Outcome: the first rendered view communicates the requested current technology stack.
   - Requirements: FRONTEND-REQ-002.

3. **Document local development**
   - Add `frontend/README.md` with the required Node.js version range, `npm ci`, `npm run dev`, and `npm run build` commands, using `frontend/` as the working directory.
   - Outcome: a developer can install, start, and build the frontend from its own unit directory.
   - Requirements: FRONTEND-REQ-001.

4. **Validate the app and acceptance criteria**
   - Install dependencies with `npm ci` from `frontend/`.
   - Start the Vite development server with the documented command and open its local URL. Confirm the page loads and both stack labels and values are visibly readable.
   - Run `npm run build` and confirm Vite completes successfully and emits the production output.
   - Optionally run `npm run preview` and repeat the visible-content check against the built app.
   - Outcome: the declared local run behavior, required initial content, and production build are verified.
   - Requirements: FRONTEND-REQ-001, FRONTEND-REQ-002.

## Dependencies

- Step 1 establishes the application entry point and scripts required by Steps 2 through 4.
- Step 2 supplies the content checked during Step 4.
- Step 3 documents commands that must match the final manifest and project layout; verify them during Step 4.

## Testing and Validation Strategy

From `frontend/`, run:

```sh
npm ci
npm run dev
npm run build
npm run preview
```

Use the development server's displayed local URL to verify that the initial page loads and visibly identifies `Backend` as `FastAPI` and `Frontend` as `Vue`. Confirm that `npm run build` succeeds. If the preview command is used, check the same content in the production preview. No unit-test runner is warranted for this informational, non-interactive page; if frontend behavior grows later, add tests with the corresponding requirements.

Validation is complete when the documented install and run commands work, both required labels and values are readable on the initial page, and the production build succeeds.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Node.js is not specified in the repository, and Vite has a minimum supported engine version. | Select a supported Node.js LTS release compatible with the chosen Vite version and state the range in `frontend/README.md`. |
| Scaffolding may leave unrelated demo content or optional dependencies. | Remove unused starter behavior and avoid adding routing, state management, a test framework, or backend integration. |
| Static stack labels could be mistaken for live backend status. | Present them only as technology names on an informational page; make no health or connectivity claims. |

## Scope Guard

Limit changes to the frontend application, its package metadata and lockfile, and its local README. Do not modify backend behavior, add deployment infrastructure, connect to the API, or introduce workflows beyond the static setup overview.