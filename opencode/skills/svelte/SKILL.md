---
name: svelte
description: Svelte 5 and SvelteKit standards: runes over stores, component and prop design, snippets, the server/client boundary, load functions and form actions, scoped styling with Tailwind, component testing. Load before writing or editing any .svelte or .svelte.ts file, a SvelteKit route, or svelte.config.js, and when asked whether Svelte code is idiomatic or where state belongs.
---

# Svelte 5 and SvelteKit Best Practices

Grounded in the [Svelte docs](https://svelte.dev/docs/svelte/overview), [SvelteKit docs](https://svelte.dev/docs/kit/introduction), and [Svelte 5 migration guide](https://svelte.dev/docs/svelte/v5-migration-guide).

## Load order

| Question | File |
| --- | --- |
| How does reactivity work? Which rune? | `references/runes.md` |
| How do I design this component's surface? | `references/components.md` |
| Where does this state live? | `references/state.md` |
| Routing, loading data, forms, server vs client | `references/sveltekit.md` |
| How do I style this? | `references/styling.md` |
| How do I test this? | `references/testing.md` |

Read only the file that answers the question. Do not preload them.

Read `DESIGN.md` and the theme tokens before writing markup. Aesthetic decisions are already made there; a component that invents its own colours, spacing, or type scale is wrong even when it looks fine.

This skill sits on top of `typescript/SKILL.md`, which owns types, module layout, error handling, and the package allowlist. Read it too when the question is not specifically about Svelte.

## Non-negotiables

1. **Svelte 5 runes only.** No `export let`, no `$:` reactive statements, no `on:click`, no `svelte/store` in new code. Runes are compiler symbols, not functions:

   > "They're not values — you can't assign them to a variable or pass them as arguments to a function"
   > — [svelte.dev](https://svelte.dev/docs/svelte/what-are-runes)

2. **`$derived` for anything computed. `$effect` only for leaving Svelte.** An effect that sets state is almost always a `$derived` written wrong. Effects exist "for things like calling third-party libraries, drawing on `<canvas>` elements, or making network requests" — synchronising one piece of state to another is not on that list. See `references/runes.md`.
3. **No shared mutable state at module scope on the server.** A `let` in a `.svelte.ts` module is one variable for every concurrent user of the process. Alice's data reaches Bob. Request-scoped state goes through `load` return values or `setContext`. See `references/state.md`.
4. **`load` functions are pure.** They return data. They do not write to stores, mutate globals, or perform side effects.
5. **The server/client boundary is explicit and deliberate.** `+page.server.ts` "always run[s] on the server"; `+page.ts` runs "both on the server and in the browser". Secrets, database access, and `$env/static/private` exist only on the server side of that line, enforced by the compiler.
6. **Mutations go through form actions or remote functions, not `fetch` in an event handler.** Progressive enhancement is the default, not a retrofit.
7. **Props are typed and read-only.** `let { x }: Props = $props()` with an explicit `interface Props`. A child never mutates a prop; it calls a callback, or the parent uses `$bindable` deliberately.
8. **Styles are scoped `<style>` or Tailwind utilities.** No global CSS outside the one app-level stylesheet, no `:global` without a comment saying why.
9. **`svelte-check --fail-on-warnings` gates CI**, beside `tsc --noEmit`. `tsc` cannot see inside `.svelte` files.

## Reviewing

Order: machine pass (`svelte-check`, `eslint`) → server/client boundary → state placement → reactivity (`$effect` audit) → component surface → tests.

The first thing to grep in any review is `$effect`. It is where the bugs are.

**Reviewing a Svelte diff:** read `svelte-review/SKILL.md` and follow it. **Scaffolding a new Svelte project:** read `svelte-setup/SKILL.md` and follow it. Both are user-invoked, so they cannot be fired as skills; reach them by path.
