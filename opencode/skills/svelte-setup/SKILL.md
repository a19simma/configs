---
disable-model-invocation: true
name: svelte-setup
description: Scaffold a new Svelte or SvelteKit project from the svelte skill: short interview, then svelte.config.js, adapter, Tailwind, app.d.ts, hooks, the lib/server boundary and CI.
---

# Svelte Project Setup

Interview, then write the configuration. Rules come from the `svelte` skill. Read `svelte/references/sveltekit.md`, `svelte/references/state.md`, and `svelte/references/styling.md` before writing anything.

**Run `typescript-setup` first.** It owns `tsconfig`, ESLint, Prettier, the dependency gate, and CI. This skill adds the Svelte layer on top and assumes those exist. If they do not, stop and do that first.

## 1. Interview

Ask only what changes the output. Skip a question whose answer is already visible in the repo or was given in the request. Prefer `AskUserQuestion` — one call, all open questions at once.

| Question | Changes |
| --- | --- |
| App or component library? | `@sveltejs/adapter-node` and a route tree, or `@sveltejs/package` and an `exports` surface |
| Deploy target: our own Node host, or a platform? | which adapter; `adapter-node` is the default and the only one on the allowlist |
| Auth: session, token, or none yet? | whether `hooks.server.ts` and the `locals` types in `app.d.ts` get written now |
| Datastore or backend RPC? | what goes behind `$lib/server/`; whether `@connectrpc/connect` appears |
| Mostly static, or dynamic per user? | `prerender` defaults in the root layout |

Defaults when the user says "just pick": app, `adapter-node`, session auth stubbed in `hooks.server.ts`, Tailwind, dynamic.

## 2. Write

State the file list before writing, then write them.

### `svelte.config.js`

`vitePreprocess`, the chosen adapter, and nothing speculative. No preprocessor for CSS — Tailwind plus scoped `<style>` is the whole styling story, per `svelte/references/styling.md`.

### `vite.config.ts`

`sveltekit()` and `@tailwindcss/vite`. Vitest config lives here: a `client` project with the `browser`/jsdom environment matching `*.svelte.test.ts`, and a `server` project for plain `.test.ts`. The split exists because component tests need a DOM and `load`/action tests do not.

### `src/app.d.ts`

The `App.Locals` interface, typed with the request-scoped capabilities `hooks.server.ts` will attach. Write it at setup even if it starts nearly empty — it is the contract every `load` and action reads through, and the alternative people reach for when it is missing is a module singleton.

### `src/hooks.server.ts`

`handle` resolving the session once and populating `event.locals`. `handleError` logging the cause chain and returning a message safe to render. Both stubbed is fine; the shape is what matters.

### `src/lib/server/`

Create the directory with a `.gitkeep` or the first real module, and say what it is for: every credentialed client, database handle, and secret-reading module lives here, and SvelteKit fails the build if client code imports it. This is the one boundary the compiler enforces for you — use it from the first commit rather than moving things in later.

### `src/app.css`

Tailwind v4: `@import "tailwindcss"` and an `@theme` block for the design tokens. No `tailwind.config.js` — v4 configures in CSS.

### `src/routes/+layout.svelte`

The shell. `{@render children()}` — a snippet, not a slot.

### `src/routes/+error.svelte`

Written at setup. A project that adds its error boundary after the first production error has already paid for it.

### CI

Add to the workflow `typescript-setup` wrote:

```yaml
- run: npx svelte-check --fail-on-warnings
```

`--fail-on-warnings` is the point: the a11y warnings are merge blockers, and without the flag they scroll past.

## 3. Report

List what was written, then state explicitly:
- that `$lib/server/` is the enforced boundary and what belongs there;
- that state placement follows the ladder in `state.md`, and that module-scope mutable state in `.svelte.ts` is banned on the server;
- that mutations go through form actions, not `fetch` in a handler;
- anything the interview deferred.

## Existing projects

Same files, but do not overwrite silently. Read what is there, show a diff of the intended change, and get approval before touching a config the project already has.

A Svelte 4 project is a migration, not a setup. Report what is on the old API — stores, slots, `on:` directives, `createEventDispatcher`, `use:` actions — with counts, and propose the migration as its own change. Do not start rewriting components inside a setup task.
