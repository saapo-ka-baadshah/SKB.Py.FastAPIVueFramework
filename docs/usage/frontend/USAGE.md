# Frontend Usage

The frontend is a Vue page that presents the application's technology overview: `Backend` / `FastAPI` (Python API framework) and `Frontend` / `Vue` (Progressive JavaScript framework). The labels are static; the page makes no backend API calls.

## Prerequisite

Install Node.js 22.12 or newer from a supported LTS release line (Node.js 22 or 24). Vite 8 requires Node.js `^20.19.0` or `>=22.12.0`.

## Install and run

Run these commands from the repository's `frontend/` directory:

```sh
npm ci
npm run dev
```

Open the local URL printed by Vite. The development server displays the static stack overview; it does not need the backend to be running.

## Build

From `frontend/`, create the production build with:

```sh
npm run build
```