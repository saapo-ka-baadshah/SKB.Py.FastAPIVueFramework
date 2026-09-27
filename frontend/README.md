# Frontend

The frontend is a Vue 3 application built with Vite. It displays a static overview of the application's backend and frontend technologies; it does not connect to the backend.

## Prerequisite

Install Node.js 22.12 or newer from a supported LTS release line (Node.js 22 or 24). Vite 8 requires Node.js `^20.19.0` or `>=22.12.0`.

## Install

Run these commands from the `frontend/` directory:

```sh
npm ci
```

## Development

```sh
npm run dev
```

## Production build

```sh
npm run build
```

## JavaScript and Vue documentation

Use JSDoc block comments (`/** ... */`) immediately before JavaScript declarations when their purpose, inputs, outputs, or non-obvious contract would not be clear from the code. Document function parameters with `@param {Type} name` and return values with `@returns {Type}` when applicable. Include other tags, such as `@throws`, only when they describe real behavior. Do not add comments that merely repeat the implementation or document obvious template markup.

```js
/**
 * Creates a greeting for a person.
 * @param {string} name - The person's name.
 * @returns {string} A greeting that includes the person's name.
 */
function greetingFor(name) {
	return `Hello, ${name}!`;
}
```

In a Vue single-file component, attach a component-level JSDoc comment directly to an actual component declaration in its `<script>` block. A template-only component has no explicit declaration to annotate; do not put a JSDoc comment in its template and imply that it documents the generated component. Add function-level JSDoc only when a function exists and needs documentation.